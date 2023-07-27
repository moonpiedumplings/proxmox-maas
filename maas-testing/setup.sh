#!/bin/sh



snap install multipass
source /etc/environment
apt-get -y install wget

# no way this fits on my 8 GB ram laptop
wget -qO- https://raw.githubusercontent.com/canonical/maas-multipass/main/maas.yml | multipass launch --name maas -c4 -m8GB -d32GB --cloud-init -


## NOT RELEVANT FOR NOW, old configs
#set up user
# useradd test
# usermod -aG test sudo
# passwd test

# #snap
# apt update
# apt install snapd
# systemctl start snapd
# snap install multipass

# ####

