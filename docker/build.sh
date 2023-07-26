#!/bin/sh
cd /proxmox-maas
ansible-galaxy install -r ansible/requirements.yml
packer init .
PACKER_LOG=1 packer build .
rm -rf output-debian
