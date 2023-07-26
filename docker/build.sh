#!/bin/sh
cd /proxmox-maas
ansible-galaxy install -r ansible/requirements.yml
packer init debian.pkr.hcl
PACKER_LOG=1 packer build debian.pkr.hcl
rm -rf output-debian
