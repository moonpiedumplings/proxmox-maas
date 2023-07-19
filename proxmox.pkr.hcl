variable "flat_filename" {
  type        = string
  default     = "custom-ubuntu.tar.gz"
  description = "The filename of the tarball to produce"
}

variable "ovmfcode" {
  type = string
  default = "ovmf/OVMF_CODE.fd"
}

variable "ovmfvars" {
  type = string
  default = "ovmf/OVMF_VARS.fd"
}

source "qemu" "flat" {
  #boot_command    = ["<wait>e<wait5>", "<down><wait><down><wait><down><wait2><end><wait5>", "<bs><bs><bs><bs><wait>autoinstall ---<wait><f10>"]
  boot_wait       = "2s"
  cpus            = 2
  disk_size       = "8G"
  format          = "raw"
  headless        = "false"
  http_directory  = "."
  iso_checksum    = "e2b27648a8a91c0da1e8e718882a5ff87a8f054c4dd7e0ea1d8af85125d82812"
  iso_target_path = "packer_cache/proxmox.iso"
  iso_url         = "https://www.proxmox.com/en/downloads?task=callelement&format=raw&item_id=689&element=f85c494b-2b32-4109-b8c1-083cca2b7db6&method=download&args[0]=12f32110b1a5d0ac8b517183fd391892"

  memory          = 2048

  # Break down these arguments
  qemuargs = [
    # Vga is the graphical console, qxl is the qemu paravirtualized one, higher performance I am guessing
    ["-vga", "qxl"],
    # This is the empty drive which eventually gets ubuntu installed onto it. DRIVE 0
    ["-device", "virtio-blk-pci,drive=drive0,bootindex=0"],
    # This is the ubuntu iso which the os is installed from and the vm initially boots from
    ["-device", "virtio-blk-pci,drive=cdrom0,bootindex=1"],
    # I don't know what this is. seeds-flat.iso
    #["-device", "virtio-blk-pci,drive=drive1,bootindex=2"],
    # Firmware stuff. But why is this necessary?
    ["-drive", "if=pflash,format=raw,readonly=on,file=${var.ovmfcode}"],
    ["-drive", "if=pflash,format=raw,file=${var.ovmfvars}"],
    # This is the output disk image, which contains installed ubuntu
    ["-drive", "file=output-flat/packer-flat,if=none,id=drive0,cache=writeback,discard=ignore,format=raw"],
    # What is this? I can't find where it is used from.
    #["-drive", "file=seeds-flat.iso,format=raw,cache=none,if=none,id=drive1,readonly=on"],
    # ubuntu iso
    ["-drive", "file=packer_cache/proxmox.iso,if=none,id=cdrom0,media=cdrom"]
  ]
  shutdown_command       = "sudo -S shutdown -P now"
  ssh_handshake_attempts = 500
  ssh_password           = "test"
  ssh_timeout            = "45m"
  ssh_username           = "ubuntu"
  ssh_wait_timeout       = "45m"
}

build {
  sources = ["source.qemu.flat"]
    /*
  provisioner "file" {
    destination = "/tmp/"
    sources = [
      # scripts to do stuff. 
      "${path.root}/scripts/curtin-hooks",
      "${path.root}/scripts/install-custom-packages",
      # Debian preseed would handle bootloader, and ansible would handle networking
      "${path.root}/scripts/setup-bootloader",
      "${path.root}/packages/custom-packages.tar.gz"
    ]
  }
  

  provisioner "shell" {
    environment_vars  = ["HOME_DIR=/home/ubuntu", "http_proxy=${var.http_proxy}", "https_proxy=${var.https_proxy}", "no_proxy=${var.no_proxy}"]
    execute_command   = "echo 'ubuntu' | {{ .Vars }} sudo -S -E sh -eux '{{ .Path }}'"
    expect_disconnect = true
    scripts           = ["${path.root}/scripts/curtin.sh", "${path.root}/scripts/networking.sh", "${path.root}/scripts/cleanup.sh"]
  }

  post-processor "shell-local" {
    # I need to know what this does. But I think it is scripts that convert the final image to something maas can use. 
    inline = [
      "SOURCE=flat",
      "IMG_FMT=raw",
      "ROOT_PARTITION=2",
      "OUTPUT=${var.flat_filename}",
      "source ../scripts/fuse-nbd",
      "source ../scripts/fuse-tar-root"
    ]
    inline_shebang = "/bin/bash -e"
  }
  */
}
