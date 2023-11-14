if [ "$2" ]; then #If scripts started from setup.sh
  if [ "$(uname)" = "Darwin" ]; then
    osascript -e 'display notification "Argo-CD configuration is finished" with title "App Ready"'; say "App Ready"
  fi
fi
if [ -z "$1" ]; then #If scripts was not started by another script
  #We refresh the argo-cd connection because it tends to slow down. After testing it indeed makes everything instantly faster and prevents bugs.
  kill $(ps | grep -v 'grep' | grep 'kubectl port-forward svc/argocd-server' | cut -d ' ' -f1) 2>/dev/null #We delete port-forward process if it already exists
  kubectl port-forward svc/argocd-server -n argocd 9393:443 &>/dev/null & #We run it in background and hide the output because benign error messages and other undesirable messages appear from it
fi

echo "\033[0;32m======== Connect to Argo CD user-interface (UI) ========\033[0m"
read -p 'Do you want to be redirected to the argo-cd UI? (y/n): ' input
if [ $input = 'y' ]; then
  ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo)
	echo " ARGO CD USERNAME: admin"
	echo " ARGO CD PASSWORD: $ARGOCD_PASSWORD (we PASTED it on CLIPBOARD)"
  echo $ARGOCD_PASSWORD | xsel --clipboard --input
  printf ' Remember those credentials. Login here https://localhost:9393 for the Argo CD UI\n'
  sleep 20
    #xdg-open 'https://localhost:9393' &>/dev/null
fi

echo "\033[0;32m======== Verify automated synchronization ========\033[0m"
echo "WAIT until will-app pods are ready before starting... (This can take up to 4minutes)"
SECONDS=0 #Calculate time of sync (https://stackoverflow.com/questions/8903239/how-to-calculate-time-elapsed-in-bash-script)
kubectl wait pods -n dev --all --for condition=Ready --timeout=600s
if [ $? -eq 1 ] #protect from pods in dev who are not ready yet before making the verifications
then
  echo "An error occurred. The creation of will-app pods timed out."
	exit 1
fi
echo "$(($SECONDS / 60)) minutes and $(expr $SECONDS % 60) seconds elapsed since waiting for will-app pods creation."
fi
kubectl config set-context --current --namespace=dev
kill $(ps | grep -v 'grep' | grep 'kubectl port-forward svc/will-app-service' | cut -d ' ' -f1) 2>/dev/null
#From my understanding we should be able to access the app running in kubernetes from outside by using a service of type LoadBalancer, subsequently calling `curl http://<external-ip>:<port>` (find 'external-ip:port' with `get services -n dev will-app-service`).
#However this did not work for me. To resolve the problem I forwarded the service's access point on localhost:8888. This means by calling localhost:8888 I am redirected to the service which finally redirects me to the pod containing app.
kubectl port-forward svc/will-app-service -n dev 8888:8888 &>/dev/null &
imageVersion=$(kubectl describe deployments will-app-deployment | grep 'Image')
imageVersion=$(echo $imageVersion | cut -c 26-26)
if [ $imageVersion -eq 1 ]; then
  newImageVersion=2
else
  newImageVersion=1
fi
echo "\033[0;36mOur current app uses the version $imageVersion of following image\033[0m"
echo "> kubectl describe deployments will-app-deployment | grep 'Image'"
kubectl describe deployments will-app-deployment | grep 'Image'
echo "> curl http://localhost:8888"
curl http://localhost:8888
exit 0
