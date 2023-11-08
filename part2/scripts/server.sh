curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--write-kubeconfig-mode=644 --tls-san $(hostname) --node-ip $1  --bind-address=$1 --advertise-address=$1" sh -

echo "alias k='kubectl'" >> /etc/profile.d/00-aliases.sh

kubectl create deployment nginx-app1 --image="apps/app1.yaml"
