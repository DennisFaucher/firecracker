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
- I used the first tutorial except for the creation of the rootfs (which would not mount on boot). https://github.com/firecracker-microvm/firecracker/blob/main/docs/getting-started.md
- Set Up KVM Access on Ubuntu Host
```
lsmod | grep kvm

sudo setfacl -m u:${USER}:rw /dev/kvm

getent group kvm

ls -l /dev/kvm

[ $(stat -c "%G" /dev/kvm) = kvm ] && sudo usermod -aG kvm ${USER} \
&& echo "Access granted."
```
- Download the Firecracker Binary
```
chmod +x get_firecracker_binary.sh
./get_firecracker_binary.sh

$ ls -lh
-rwxrwxr-x 1 dennis dennis 1.8K Aug  6 13:18 create_rootfs.sh
-rwxr-xr-x 1 dennis dennis 2.8M Jun 24 08:19 firecracker
-rwxrwxr-x 1 dennis dennis  403 Aug  6 10:28 get_firecracker_binary.sh
-rwxrwxr-x 1 dennis dennis 1.7K Aug  6 10:26 get_kernel_rootfs.sh
-rwxrwxr-x 1 dennis dennis  765 Aug  6 13:26 get_nerdctl.sh
```

- Download the Rootfs (I had to modify the rootfs download instructions from the tutorial as the rootfs in the tutorial would not mount. I used the instructions form this page: https://github.com/rgl/firecracker-playground/blob/main/provision-firecracker-vm-alpine.sh)
```
chmod +x get_nerdctl.sh (Installs the packages needed by create_rootfs.sh)
./get_nerdctl.sh

chmnod +x create_rootfs.sh
sudo ./create_rootfs.sh
sudo mv /tmp/firecracker-vm-alpine-rootfs .
```

- Download the kernel
```
```
