packer {
  required_version = ">= 1.7.0"
  required_plugins {
    qemu = {
      version = "~> 1.0"
      source  = "github.com/hashicorp/qemu"
    }
  }
}

variable "debian_filename" {
  type        = string
  default     = "debian.tar.gz"
  description = "The filename of the tarball to produce"
}

variable "iso_url" {
  type = string
  default = "https://cdimage.debian.org/cdimage/archive/11.7.0/amd64/iso-cd/debian-11.7.0-amd64-netinst.iso"
  #default = "https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-12.0.0-amd64-netinst.iso"
}

variable "iso_name" {
  type = string
  default = "debian-11.7.0-amd64-netinst.iso"
  #default = "debian-12.0.0-amd64-netinst.iso"
}

variable "iso_checksums" {
  type = string
  default = "https://cdimage.debian.org/cdimage/archive/11.7.0/amd64/iso-cd/SHA256SUMS"
  #default = "https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/SHA256SUMS"
}

variable "name" {
  type    = string
  default = "debian"
}

variable "debian_version" {
  type    = string
  default = "11"
}

variable "http_directory" {
  type = string
  default = "http"
}

variable "ovmfcode" {
  type = string
  default = "/usr/share/OVMF/OVMF_CODE.fd"
}

variable "ovmfvars" {
  type = string
  default = "/usr/share/OVMF/OVMF_VARS.fd"
}

variable "user" {
  type = string
  default = "test"
}

variable "password" {
  type = string
  default = "test"
}

source "qemu" "debian" {
  #boot_command     = ["<esc><wait>", "auto <wait>", "console-keymaps-at/keymap=us <wait>", "console-setup/ask_detect=false <wait>", "debconf/frontend=noninteractive <wait>", "debian-installer=en_US <wait>", "fb=false <wait>", "install <wait>", "kbd-chooser/method=us <wait>", "keyboard-configuration/xkb-keymap=us <wait>", "locale=en_US <wait>", "netcfg/get_hostname=${var.name}${var.version} <wait>", "preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/${var.config_file} <wait>", "<enter><wait>"]
  /*boot_command = [
    "<down>", "<down>",
    "<enter><wait>",
    "<down><down><down><down><down><enter>",
    "<wait1m>",
    "http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.txt<enter>"

  ]*/
  boot_wait       = "10s"
  cpus            = "2"
  disk_size       = "12G"
  format          = "raw"
  headless        = "false"

  #http_directory  = "http"
  http_content = {
    "/preseed.txt" = templatefile("${path.root}/http/preseed-template.pkrtpl", 
    {
      user = var.user
      password = var.password
    })
  }


  ### MUST BE CHANGED TO RELEVANT DEBIAN CONFIG ### 

  /* Debian base netinstall */

  iso_checksum = "file:${var.iso_checksums}"
  iso_target_path = "packer_cache/${var.iso_name}"
  iso_url = "${var.iso_url}"


  # output_directory = "./output" # isn't doing anything
  memory          = 2048
  net_device       = "virtio-net"
  qemuargs = [
    ["-vga", "qxl"],

    #Operating system can't find devices. Will play with these
    /*Currently, I have tried
    virtio-blk-pci: debian can't see disks. Will test if ubuntu can see disks later
    nvme,serial=deadbeef1: debian won't even boot like this
    Now try USB? */
    
    ["-device", "ide-hd,drive=drive0,bootindex=0"],
    ["-device", "virtio-blk-pci,drive=cdrom0,bootindex=1"],
    

    #Seeds-flat.iso, idk what this is.
    #["-device", "virtio-blk-pci,drive=drive1,bootindex=2"],
    
    ["-drive", "if=pflash,format=raw,readonly=on,file=${var.ovmfcode}"],
    ["-drive", "if=pflash,format=raw,file=${var.ovmfvars}"],
    
    #This is where the error — solved, needs sudo to run.
    ["-drive", "file=output-debian/packer-debian,if=none,id=drive0,cache=writeback,discard=ignore,format=raw"],
    
    #Dunno what this is right now.
    #["-drive", "file=seeds-flat.iso,format=raw,cache=none,if=none,id=drive1,readonly=on"],

    ["-drive", "file=packer_cache/${var.iso_name},if=none,id=cdrom0,media=cdrom"]
  ]
  shutdown_command       = "echo 'test' | sudo -S shutdown -P now"

  ### DEBIAN DOES NOT HAVE SSH, ONLY PRESEED. How to make this work?   ####
  ssh_handshake_attempts = 1
  ssh_password           = "${var.password}"
  ssh_timeout            = "45m"
  ssh_username           = "${var.user}"
  ssh_wait_timeout       = "45m"
}

build {
  sources = ["source.qemu.debian"]
  
  /*provisioner "shell" {
    inline = [
      "apt update && apt install ansible"
    ]
    inline_shebang = "/bin/bash -e"
  }*/
  provisioner "file" {
    destination = "/tmp/"
    sources = [
      "${path.root}/scripts/shell/install-ansible.sh"
    ]
  }
  provisioner "shell" {
    #environment_vars  = ["HOME_DIR=/home/ubuntu", "http_proxy=${var.http_proxy}", "https_proxy=${var.https_proxy}", "no_proxy=${var.no_proxy}"]
    execute_command   = "echo '${var.password}' | sudo -S -E sh -eux '{{ .Path }}'"
    expect_disconnect = true
    scripts           = ["${path.root}/scripts/shell/install-ansible.sh", "${path.root}/scripts/shell/passwordless-sudo.sh"]
  }
  provisioner "shell" {
    execute_command = "sh -eux '{{ .Path}}'"
    scripts = ["${path.root}/scripts/shell/groups.sh"]
  }

  provisioner "ansible-local" {
    #command = "ansible-playbook" is the default
    #command = "echo 'test' | sudo -S ansible-playbook"
    playbook_file = "${path.root}/ansible/test-playbook.yml"
    #extra_arguments = ["--extra-vars", "'username=${var.username}'"]
  }

  ### OLD PACKER MAAS UBUNTU CONFIGS ##
  /*provisioner "file" {
    destination = "/tmp/"
    sources = [
      "${path.root}/scripts/curtin-hooks",
      "${path.root}/scripts/install-custom-packages",
      "${path.root}/scripts/setup-bootloader",
      "${path.root}/packages/custom-packages.tar.gz"
    ]
  }
  
  */

  post-processor "shell-local" {
    inline = [
      "SOURCE=flat",
      "PACKER_OUTPUT=output-debian/packer-debian",
      "IMG_FMT=raw",
      "ROOT_PARTITION=2",
      "OUTPUT=${var.debian_filename}",
      "source ./scripts/shell-local/fuse-nbd",
      "source ./scripts/shell-local/fuse-tar-root"
    ]
    inline_shebang = "/bin/bash -e"
  }
  ###

  
}

