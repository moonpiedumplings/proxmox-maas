
source "qemu" "debian" {
  boot_command = [
    "<down>", "<down>",
    "<enter><wait>",
    "<down><down><down><down><down><enter>",
    "<wait1m>",
    "http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.txt<enter>"

  ]
  boot_wait       = "10s"
  cpus            = "2"
  disk_size       = "12G"
  format          = "raw"
  headless        = "true"

  http_content = {
    "/preseed.txt" = templatefile("${path.root}/http/preseed-template.pkrtpl", 
    {
      user = var.user
      password = var.password
    })
  }

  iso_checksum = "file:${var.iso_checksums}"
  iso_target_path = "packer_cache/${var.iso_name}"
  iso_url = "${var.iso_url}"


  memory          = 2048
  net_device       = "virtio-net"
  qemuargs = [
    ["-vga", "qxl"],
    ["-device", "virtio-blk-pci,drive=drive0,bootindex=0"],
    ["-device", "virtio-blk-pci,drive=cdrom0,bootindex=1"],
    ["-drive", "if=pflash,format=raw,readonly=on,file=/usr/share/OVMF/OVMF_CODE.fd"],
    ["-drive", "if=pflash,format=raw,file=/usr/share/OVMF/OVMF_VARS.fd"],
    ["-drive", "file=output-debian/packer-debian,if=none,id=drive0,cache=writeback,discard=ignore,format=raw"],
    ["-drive", "file=packer_cache/${var.iso_name},if=none,id=cdrom0,media=cdrom"]
  ]
  shutdown_command       = "echo 'test' | sudo -S shutdown -P now"

  ssh_handshake_attempts = 1
  ssh_password           = "${var.password}"
  ssh_timeout            = "45m"
  ssh_username           = "${var.user}"
  ssh_wait_timeout       = "45m"
  ssh_read_write_timeout = "5m"

}

build {
  sources = ["source.qemu.debian"]
  
  provisioner "shell" {
    inline = [
      "echo '${var.password}' | sudo -S -E python3 -c \"open('/etc/sudoers.d/99_sudo_include_file', 'w').write('${var.user} ALL=(ALL) NOPASSWD:ALL')\"",
      "echo '${var.password}' | sudo -S -E visudo -cf /etc/sudoers.d/99_sudo_include_file"
    ]
  }
  provisioner "shell" {
    execute_command = "sh -eux '{{ .Path}}'"
    scripts = [
      "${path.root}/scripts/shell/groups.sh", 
      ]
  }

  provisioner "ansible" {
    user = "${var.user}"
    playbook_file = "${path.root}/ansible/lae-proxmox.yml"
    extra_arguments  = [
       "--scp-extra-args", "'-O'"
      ]
  }

  post-processor "shell-local" {
    inline = [
      "SOURCE=flat",
      "PACKER_OUTPUT=output-debian/packer-debian",
      "IMG_FMT=raw",
      "ROOT_PARTITION=2",
      "OUTPUT=${var.output_filename}",
      "source ./scripts/shell-local/fuse-nbd",
      "source ./scripts/shell-local/fuse-tar-root"
    ]
    inline_shebang = "/bin/bash -e"
  }
}

