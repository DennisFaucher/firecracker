# firecracker
Learning Firecracker "Serverless" MicroVMs

## Why?
I have been reading about simple, fast, programmatic virtual machines. First, I learned Ubuntu Multipass (full-fat, but quick to deploy VMs), and then moved on to Firecracker. If you have ever used an AWS serverless function, or written an AWS serverless function, the function runs on a short-lived VM. That VM uses the firecracker technology.

Here is the description of firecracker from https://firecracker-microvm.github.io/

"Firecracker enables you to deploy workloads in lightweight virtual machines, called microVMs, which provide enhanced security and workload isolation over traditional VMs, while enabling the speed and resource efficiency of containers. Firecracker was developed at Amazon Web Services to improve the customer experience of services like AWS Lambda and AWS Fargate.

Firecracker is a virtual machine monitor (VMM) that uses the Linux Kernel-based Virtual Machine (KVM) to create and manage microVMs. Firecracker has a minimalist design. It excludes unnecessary devices and guest functionality to reduce the memory footprint and attack surface area of each microVM. This improves security, decreases the startup time, and increases hardware utilization. Firecracker is generally available on 64-bit Intel, AMD and Arm CPUs with support for hardware virtualization."

### Challenges
Many of the public firecracker tutorials failed for me at some point in the tutorial. I took the working portions of the first few tutorials I tried and combined them into a process that works for me

### Goals
- A running VM
- Ability to login to the VM
- Ability for VM to access the Internet

### Tutorials Used
- https://github.com/firecracker-microvm/firecracker/blob/main/docs/getting-started.md
- https://github.com/firecracker-microvm/firecracker/blob/main/docs/network-setup.md#in-the-guest
- https://github.com/rgl/firecracker-playground/blob/main/provision-firecracker-vm-alpine.sh (Fixed rootfs that would not mount)
- https://wiki.alpinelinux.org/wiki/Writing_Init_Scripts

## How?
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
(I commented out the PKI sections of this script as they are for a different rootfs tutorial and failed)

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
- Do this in a dedicated terminal session. We'll call this Terminal01
```
API_SOCKET="/tmp/firecracker.socket"

# Remove API unix socket if left over from before
sudo rm -f $API_SOCKET

# Run firecracker
sudo ./firecracker --api-sock "${API_SOCKET}"
```
- You will get a console output like this
```
2025-08-07T16:15:45.558235536 [anonymous-instance:main] Running Firecracker v1.12.1
2025-08-07T16:15:45.558365147 [anonymous-instance:main] Listening on API socket ("/tmp/firecracker.socket").
2025-08-07T16:15:45.558635012 [anonymous-instance:fc_api] API server started.
```

### Start the VM
- Open a new terminal tab on the host. We'll call this Terminal02
```
./start_the_vm_firecracker.sh
```
- This will set up NAT on the host, start the VM, show all the console messages on Terminal01 and then bring you to a login prompt like this:

```
[snip]

 * Checking local filesystems  ... [ ok ]
 * Remounting filesystems ... [ ok ]
 * Starting sshd ... [ ok ]

Welcome to Alpine Linux 3.20
Kernel 6.1.128 on an x86_64 (/dev/ttyS0)

(none) login: 

```
- Login with the username root and the password root. Alpine Linux will be running but eth0 will not be active yet

### Dennis' Hacky Crap to Get Guest Networking Working
There are much more elegant ways to do this, but this is what worked for me
Basically, I want to configure eth0 on the guest, and start the ssh-server on boot.
All these commands are run in the VM once it is booted, and you have logged into the console as root/root
Commands are from this tutorial: https://github.com/firecracker-microvm/firecracker/blob/main/docs/network-setup.md#in-the-guest

##### Create an init.d script
```
# cat /etc/init.d/networkconfig 
#!/sbin/openrc-run
description="Configure eth0"

depend() {
	need root
}

start() {
        ip addr add 172.16.0.2/30 dev eth0
        ip link set eth0 up
        ip route add default via 172.16.0.1 dev eth0
}
```

#### Enable the init.d script
```
# rc-update add networkconfig
```

#### Enable the sshd that was installed during create_rootfs.sh
```
# rc-update add sshd

# rc-status
Runlevel: default
 sshd
 [  stopped  ]
 networkconfig
 [  started  ]
Dynamic Runlevel: hotplugged
Dynamic Runlevel: needed/wanted
 modules
 [  started  ]
 fsck
 [  started  ]
 root
 [  started  ]
Dynamic Runlevel: manual
```

### Reboot the VM and the network should come up automagically
- On Terminal01
```
(none):~# reboot
(none):~#  * Stopping sshd ... [ ok ]
The system is going down NOW!
Sent SIGTERM to all processes
Sent SIGKILL to all processes
Requesting system reboot
[ 4020.685071] reboot: Restarting system
[ 4020.688440] reboot: machine restart
```
- The VM does not actually restart, it shuts down. To get the VM running again, follow the instructions again in "Start Firecracker" and "Start the VM". You should now have networking on boot
- Terminal 01
```
sudo rm -f $API_SOCKET
sudo ./firecracker --api-sock "${API_SOCKET}"
```
- Terminal 02
```
./start_the_vm_firecracker.sh
```
- Terminal 01 (after login)
```
(none):~# ip a
1: lo: <LOOPBACK> mtu 65536 qdisc noop state DOWN qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000
    link/ether 06:00:ac:10:00:02 brd ff:ff:ff:ff:ff:ff
    inet 172.16.0.2/30 scope global eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::400:acff:fe10:2/64 scope link 
       valid_lft forever preferred_lft forever

(none):~# ping -c1 google.com
PING google.com (142.251.40.206): 56 data bytes
64 bytes from 142.251.40.206: seq=0 ttl=113 time=28.163 ms

--- google.com ping statistics ---
1 packets transmitted, 1 packets received, 0% packet loss
round-trip min/avg/max = 28.163/28.163/28.163 ms
```

## Function as a Service (FaaS) - Dad Jokes
- What's an AWS Lambda clone without a function to run? Back in the arly days of Lambda, I learned FaaS by writing a "Dad Jokes Skill" for Alexa in Lambda. Let's create a simple Dad Joke web page to query on our firecracker VM.
### Add nginx
- Terminal01 (After logging in)
```
Lighttpd
# apk add lighttpd
# chown -R lighttpd:lighttpd /var/www/localhost/ /var/log/lighttpd 
# rc-update add lighttpd default

(So, the lighttpd service depends on the networking service. The slimmed down Alpine VM cannot start the networking service. Need to comment out the "need net" in the lighttpd service script.)

# vi /etc/init.d/lighttpd 
depend() {
#       need net
        use mysql logger spawn-fcgi ldap slapd netmount dns
        after firewall
        after famd
        after sshd
}

# rc-service lighttpd restart

echo "Hello, World!" > /var/www/localhost/htdocs/index.html


```
- Terminal02 - Test nginx
```
$ curl 172.16.0.2
Hello, World!
```

### Get the Dad Jokes Function Page
- Terminal 01 - Pull the Dad Jokes HTML
```
# cd /var/www/localhost/htdocs/
# wget https://raw.githubusercontent.com/DennisFaucher/firecracker/refs/heads/main/dad_joke_generator.html

Connecting to raw.githubusercontent.com (185.199.111.133:443)
saving to 'dad_joke_generator.html'
dad_joke_generator.h 100% |********************************|  7883  0:00:00 ETA
'dad_joke_generator.html' saved
```
### Test the Dad Jokes Function Page
<img width="1248" height="805" alt="DadJokePage2" src="https://github.com/user-attachments/assets/d4c070fe-9682-463e-b66f-2a120103943b" />

## Performance and Resource Usage
### Performance
- I wrote a little script that captures the time, starts firecracker, waits for the login:, captures the time again and subtracts.
```
$ ./time_boot.sh 
Boot time: 3.261094768 seconds.
```
- This includes the time for Dennis to switch to a second terminal session and run ./start_the_vm_firecracker.sh, so maybe subtract a second for that.
- My simple, full-fat, Ubuntu Multipass VM booted quickly but took 12 whole seconds!
  
### Resource Utilization
#### CPU Usage - Very little at rest on a single CPU core
```
# grep processor /proc/cpuinfo
processor	: 0

# mpstat 5 1
Linux 6.1.128 ((none))	08/06/25	_x86_64_	(1 CPU)

Average:     CPU    %usr   %nice    %sys %iowait    %irq   %soft  %steal  %guest   %idle
Average:     all    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00  100.00

```

#### Memory Usage - About 13 MB

```
# grep MemTotal /proc/meminfo 
MemTotal:         109464 kB

# free -m
              total        used        free      shared  buff/cache   available
Mem:            107          13          89           1           5          89
Swap:             0           0           0
```

#### Disk Usage - 25 MB
```
# df -h
Filesystem                Size      Used Available Use% Mounted on
/dev/root               103.9M     25.7M     69.3M  27% /
```



