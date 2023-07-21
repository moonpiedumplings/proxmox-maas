FROM ubuntu:kinetic

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get -y update && apt-get install -y curl gnupg software-properties-common lsb-core \
&& curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add - \
&& apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
#&& timedatectl set-timezone America/Los_Angeles \
&& apt-get update \
&& apt-get install -y packer pipx ovmf cloud-image-utils qemu-utils sshpass qemu-system libnbd-bin nbdkit fuse2fs fuse \
&& rm -rf /var/lib/apt/lists/*

RUN PIPX_HOME=/opt/pipx PIPX_BIN_DIR=/usr/local/bin pipx install --include-deps ansible

# The apt packer packer version is too old. I will remedy later, after I fix up debian automated install.
