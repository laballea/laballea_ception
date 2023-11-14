#retrieve token file
export TOKEN_FILE="/vagrant/scripts/token"

#install k3s as agent/worker
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="agent --server https://$1:6443 --token-file $TOKEN_FILE --node-ip=$2" sh -

#create alias like in subject example
echo "alias k='kubectl'" >> /etc/profile.d/00-aliases.sh
