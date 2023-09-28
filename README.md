# proxmox-maas
Proxmox MAAS image, created via packer

This repo contains code that automates creation of a prommox 8 image for use with MAAS. 

Most of this code is based on Canonical's original work: <https://github.com/canonical/packer-maas> 

I've dockerized the steps, since I don't have an ubuntu machine as my main machine, but the packer-maas steps assume you are using Ubuntu. 

# Building

## Requirements

* A linux kernel with KVM support enabled (Just kvm, you don't even need qemu or anything like that, it's in the docker image)
* Docker
* docker-compose/docker compose. docker-compose is usually a seperate package, but the `docker compose` command is included in new enough versions of docker.

## Steps

With this repo as your working directory:

`cd docker`

`docker-compose up`

Or `docker compose up`, either works. 

A proxmox maas image will then be created. 
