# firecracker
Learning Firecracker "Serverless" MicroVMs

## Why?
I have been reading about simple, fast, programmatic virtual machines. First, I learned Ubuntu Multipass (full-fat, but quick to deplot VMs), and then moved on to Firecracker.

## Challenges
Many of the public firecracker tutorials failed for me at some point in the tutorial. I took the working portions of the first few tutorials I tried and combined them into a process that works for me

## Goals
- Running VM
- Ability to Login to the VM
- Ability for VM to access the Internet

## Tutorials Used
- https://github.com/firecracker-microvm/firecracker/blob/main/docs/getting-started.md
- https://github.com/firecracker-microvm/firecracker/blob/main/docs/network-setup.md#in-the-guest
- https://github.com/rgl/firecracker-playground/blob/main/provision-firecracker-vm-alpine.sh (Fixed rootfs that would not mount)

## How
- Tested using a fresh Ubuntu KVM VM as a host
- KVM Access on Ubuntu Host
```
lsmod | grep kvm

sudo setfacl -m u:${USER}:rw /dev/kvm

getent group kvm

ls -l /dev/kvm

[ $(stat -c "%G" /dev/kvm) = kvm ] && sudo usermod -aG kvm ${USER} \
&& echo "Access granted."
``` 
