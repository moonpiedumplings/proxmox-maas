FROM ubuntu:kinetic

RUN apt-get update && apt-get install -y curl gnupg software-properties-common lsb-core \
&& curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add - \
&& apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
&& apt-get update \
&& apt-get install -y packer ovmf cloud-image-utils qemu-utils qemu-system libnbd-bin nbdkit fuse2fs fuse \
&& rm -rf /var/lib/apt/lists/*

# The apt packer packer version is too old. I will remedy later, after I fix up debian automated install.