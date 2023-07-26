packer {
  required_version = ">= 1.7.0"
  required_plugins {
    qemu = {
      version = "~> 1.0"
      source  = "github.com/hashicorp/qemu"
    }
    ansible = {
      version = ">= 1.1.0"
      source  = "github.com/hashicorp/ansible"
    }
  }
}

variable "output_filename" {
  type        = string
  default     = "proxmox.tar.gz"
  description = "The filename of the tarball to produce"
}

variable "iso_url" {
  type = string
  default = "https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-12.1.0-amd64-netinst.iso"
}

variable "iso_name" {
  type = string
  default = "debian-12.1.0-amd64-netinst.iso"
}

variable "iso_checksums" {
  type = string
  default = "https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/SHA256SUMS"
}

variable "debian_version" {
  type    = string
  default = "12"
}

variable "http_directory" {
  type = string
  default = "http"
}