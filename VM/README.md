> The VM is not a real phase, it is a phase to start the host VM and prepare it

1. Run the `Makefile` to download an ISO image, create the virtual disk and start the VM. (downloading in ~/sgoinfre/ by default)

2. en root : 
    - apt-get update
    - apt-get install vim
    - mettre %sudo (ALL:ALL) ALL
    dans /etc/sudo.conf
3. ensuite:
    $>su -
    usermod -aG sudo debian
4. 
    sudo apt-get install git make tree btop gcc perl curl wget

5. cloner le repot

6. Run :
    ./install-vbox.sh
    ./install-vagrant.sh

N.B. on peut sauvegarder le fichier iotdebian-12.2.0-amd64-netinst.iso.qcow2
pour sauvegarder l'image de la VM