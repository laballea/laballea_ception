sudo apt update -y
sudo apt install curl net-tools -y

curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--write-kubeconfig-mode=644 --tls-san $(hostname) --node-ip $1 --bind-address=$1 --advertise-address=$1" sh -

echo "alias k='kubectl'" >> /etc/profile.d/00-aliases.sh

kubectl create configmap app1-html --from-file /vagrant/apps/app1/index.html
kubectl apply -f "/vagrant/apps/app1/app.yaml"

kubectl create configmap app2-html --from-file /vagrant/apps/app2/index.html
kubectl apply -f "/vagrant/apps/app2/app.yaml"

kubectl create configmap app3-html --from-file /vagrant/apps/app3/index.html
kubectl apply -f "/vagrant/apps/app3/app.yaml"

kubectl wait pods --all --for condition=Ready --timeout=600s

echo "Deployment completed successfully!"