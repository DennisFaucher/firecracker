#!/bin/bash
apt-get update
apt-get install containerd

wget https://github.com/containerd/nerdctl/releases/download/v1.5.0/nerdctl-1.5.0-linux-amd64.tar.gz
tar -zxf nerdctl-1.5.0-linux-amd64.tar.gz nerdctl
mv nerdctl /usr/bin/nerdctl
rm nerdctl-1.5.0-linux-amd64.tar.gz

wget https://github.com/containernetworking/plugins/releases/download/v1.3.0/cni-plugins-linux-amd64-v1.3.0.tgz
mkdir -p /opt/cni/bin/
tar -zxf cni-plugins-linux-amd64-v1.3.0.tgz -C /opt/cni/bin/
rm cni-plugins-linux-amd64-v1.3.0.tgz

# https://github.com/moby/buildkit for building images
wget https://github.com/moby/buildkit/releases/download/v0.12.2/buildkit-v0.12.2.linux-amd64.tar.gz
tar -zxvf buildkit-v0.12.2.linux-amd64.tar.gz
mv bin/* /usr/bin/
rm buildkit-v0.12.2.linux-amd64.tar.gz
