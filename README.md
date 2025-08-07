# firecracker
Learning Firecracker "Serverless" MicroVMs

## Why?
I have been reading about simple, fast, programmatic virtual machines. First, I learned Ubuntu Multipass (full-fat, but quick to deplot VMs), and then moved on to Firecracker. If you have every used an AWS serverless function, or written an AWS serverless function, the function runs on a short-lived VM. That VM uses the firecracker technology.

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
### Set Up KVM Access on Ubuntu Host
```
lsmod | grep kvm

sudo setfacl -m u:${USER}:rw /dev/kvm

getent group kvm

ls -l /dev/kvm

[ $(stat -c "%G" /dev/kvm) = kvm ] && sudo usermod -aG kvm ${USER} \
&& echo "Access granted."
```
### Download the Firecracker Binary
```
chmod +x get_firecracker_binary.sh
./get_firecracker_binary.sh

$ ls -l
-rwxrwxr-x 1 dennis dennis      1793 Aug  6 13:18 create_rootfs.sh
-rwxr-xr-x 1 dennis dennis   2892072 Jun 24 08:19 firecracker
-rwxrwxr-x 1 dennis dennis       403 Aug  6 10:28 get_firecracker_binary.sh
-rwxrwxr-x 1 dennis dennis      1669 Aug  6 16:53 get_kernel.sh
-rwxrwxr-x 1 dennis dennis       765 Aug  6 13:26 get_nerdctl.sh

```

### Download the Rootfs
(I had to modify the rootfs download instructions from the tutorial as the rootfs in the tutorial would not mount. I used the instructions form this page: https://github.com/rgl/firecracker-playground/blob/main/provision-firecracker-vm-alpine.sh)
```
chmod +x get_nerdctl.sh (Installs the packages needed by create_rootfs.sh)
./get_nerdctl.sh

chmod +x create_rootfs.sh
sudo ./create_rootfs.sh
sudo mv /tmp/firecracker-vm-alpine-rootfs .

$ ls -l
-rwxrwxr-x 1 dennis dennis      1793 Aug  6 13:18 create_rootfs.sh
-rwxr-xr-x 1 dennis dennis   2892072 Jun 24 08:19 firecracker
-rw------- 1 root   root   134217728 Aug  6 14:45 firecracker-vm-alpine-rootfs.ext4
-rwxrwxr-x 1 dennis dennis       403 Aug  6 10:28 get_firecracker_binary.sh
-rwxrwxr-x 1 dennis dennis      1655 Aug  6 10:26 get_kernel_rootfs.sh
-rwxrwxr-x 1 dennis dennis      1669 Aug  6 16:53 get_kernel.sh
-rwxrwxr-x 1 dennis dennis       765 Aug  6 13:26 get_nerdctl.sh
```

### Download the kernel
```
chmod +x get_kernel.sh
./get_kernel.sh

$ ls -l
-rwxrwxr-x 1 dennis dennis      1793 Aug  6 13:18 create_rootfs.sh
-rwxr-xr-x 1 dennis dennis   2892072 Jun 24 08:19 firecracker
-rw------- 1 root   root   134217728 Aug  6 14:45 firecracker-vm-alpine-rootfs.ext4
-rwxrwxr-x 1 dennis dennis       403 Aug  6 10:28 get_firecracker_binary.sh
-rwxrwxr-x 1 dennis dennis      1655 Aug  6 10:26 get_kernel_rootfs.sh
-rwxrwxr-x 1 dennis dennis      1669 Aug  6 16:53 get_kernel.sh
-rwxrwxr-x 1 dennis dennis       765 Aug  6 13:26 get_nerdctl.sh
-rw-rw-r-- 1 dennis dennis  40944760 Mar 10 10:16 vmlinux-6.1.128
```

### Start Firecracker
- Do this in a dedicated terminal session
```
API_SOCKET="/tmp/firecracker.socket"

# Remove API unix socket if left over from before
sudo rm -f $API_SOCKET

# Run firecracker
sudo ./firecracker --api-sock "${API_SOCKET}"
```
- You will get a console output like this
```


## Function as a Service (FaaS) - Dad Jokes
2025-08-06T14:41:21.599408679 [anonymous-instance:main] Running Firecracker v1.12.1
2025-08-06T14:41:21.599637508 [anonymous-instance:main] Listening on API socket ("/tmp/firecracker.socket").
2025-08-06T14:41:21.600029916 [anonymous-instance:fc_api] API server started.
```
