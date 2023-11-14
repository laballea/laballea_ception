echo "\033[0;32m======== K3D SETUP ========\033[0m"
k3d cluster delete p3
k3d cluster create p3

echo "\033[0;32m======== KUBERNETES NAMESPACE SETUP ========\033[0m"
kubectl create namespace argocd
kubectl create namespace dev

echo "\033[0;32m======== ARGOCD SETUP ========\033[0m"
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "\033[0;32mWAITING FOR ARGOCD PODS TO RUN\033[0m"
sleep 5
kubectl wait pods -n argocd --all --for condition=Ready --timeout=600s

kill $(ps | grep -v 'grep' | grep 'kubectl port-forward svc/argocd-server' | cut -d ' ' -f1) 2>/dev/null #We delete port-forward process if it already exists
kubectl port-forward svc/argocd-server -n argocd 9393:443 &>/dev/null &

ARGOCD_PASSWORD=$(sudo kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo)
argocd login localhost:9393 --username admin --password $ARGOCD_PASSWORD --insecure --grpc-web

kubectl config set-context --current --namespace=argocd

echo "\033[0;32m======== CREATE APP ========\033[0m"
#https://argo-cd.readthedocs.io/en/release-1.8/user-guide/commands/argocd_app_create/
argocd app create will --repo 'https://github.com/laballea/InceptionOfThings.git' --path 'p3/app/' --dest-namespace 'dev' --dest-server 'https://kubernetes.default.svc' --grpc-web
sleep 5

#https://argo-cd.readthedocs.io/en/stable/user-guide/commands/argocd_app_sync/
argocd app sync will --grpc-web
sleep 5

#https://argo-cd.readthedocs.io/en/stable/user-guide/commands/argocd_app_set/
argocd app set will --sync-policy automated --auto-prune --allow-empty --grpc-web #Once git repo is changed with new push, our running will-app will mirror that.
sleep 5

#kill previous existing port and port-forward port 8888
./scripts/expose_app.sh

echo "\033[0;32m"
echo "ARGOCD USERNAME: \033[0m admin \033[0;32m"
echo "ARGOCD PASSWORD: \033[0m $ARGOCD_PASSWORD \033[0;32m( PASTED on CLIPBOARD)"
echo $ARGOCD_PASSWORD | xsel --clipboard --input
echo "ARGOCD accessible at: \033[0m http://localhost:9393 \033[0;32m"
echo "APP accessible at: \033[0m http://localhost:8888"
exit 0
