#install k3s as server
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--write-kubeconfig-mode=644 --tls-san $(hostname) --node-ip $1  --bind-address=$1 --advertise-address=$1" sh -

#copy token so worker can have access to it
sudo cp /var/lib/rancher/k3s/server/token /vagrant/scripts/

#create alias like in subject example
echo "alias k='kubectl'" >> /etc/profile.d/00-aliases.sh
