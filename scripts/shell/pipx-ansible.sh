#!/bin/sh
export DEBIAN_FRONTEND='noninteractive'
sudo apt-get -y update && sudo apt-get -y install pipx
sudo PIPX_HOME=/opt/pipx PIPX_BIN_DIR=/usr/local/bin pipx install --include-deps ansible