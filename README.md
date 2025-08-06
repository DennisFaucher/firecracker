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
mkdir Firecracker
cd Firecracker
chmod +x get_firecracker_binary.sh
./get_firecracker_binary.sh
```

- Download the Kernal and Rootfs (I had to modify the rootfs download instructions from the tutorial as the rootfs in the tutorial would not mount
```
chmod +x get_kernel_rootfs.sh
./get_firecracker_binary.sh

$ ls -lh
total 337M
drwxr-xr-x 2 root   root   4.0K Aug  6 13:26 bin
-rwxrwxr-x 1 dennis dennis 1.8K Aug  6 13:18 create_rootfs.sh
-rwxr-xr-x 1 dennis dennis 2.8M Jun 24 08:19 firecracker
-rw-rw-r-- 1 dennis dennis  13K Aug  6 14:41 firecracker.log
-rw------- 1 root   root   128M Aug  6 14:45 firecracker-vm-alpine-rootfs.ext4
-rwxrwxr-x 1 dennis dennis  403 Aug  6 10:28 get_firecracker_binary.sh
-rwxrwxr-x 1 dennis dennis 1.7K Aug  6 10:26 get_kernel_rootfs.sh
-rwxrwxr-x 1 dennis dennis  765 Aug  6 13:26 get_nerdctl.sh
-rw-rw-r-- 1 dennis dennis  30M Aug  6 13:18 hello-rootfs.ext4
-rw-r--r-- 1 dennis dennis  104 Aug  6 10:27 id_rsa.pub
-rw-r--r-- 1 root   root    16K Aug  6 14:16 mem_file_path
drwxrwxr-x 2 dennis dennis 4.0K Aug  6 10:29 release-v1.12.1-x86_64
-rw-r--r-- 1 root   root   128M Aug  6 14:16 snapshot_path
-rwxrwxr-x 1 dennis dennis  170 Aug  6 10:30 start_firecracker.sh
-rwxrwxr-x 1 dennis dennis 3.2K Aug  6 14:32 start_the_vm_firecracker.sh
-rwxrwxr-x 1 dennis dennis 3.2K Aug  6 10:52 start_the_vm_hello.sh
-rwxrwxr-x 1 dennis dennis 3.2K Aug  6 10:33 start_the_vm.sh
-rw-rw-r-- 1 dennis dennis 400M Aug  6 10:27 ubuntu-24.04.ext4
-rw------- 1 dennis dennis  419 Aug  6 10:27 ubuntu-24.04.id_rsa
-rw-rw-r-- 1 dennis dennis  78M Mar 10 10:16 ubuntu-24.04.squashfs.upstream
-rw-rw-r-- 1 dennis dennis  40M Mar 10 10:16 vmlinux-6.1.128

```
