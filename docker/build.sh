#!/bin/sh
cd /proxmox-maas
packer init debian.pkr.hcl
PACKER_LOG=1 packer build debian.pkr.hcl
rm -rf output-debian
