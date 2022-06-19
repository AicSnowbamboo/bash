#!/bin/bash
localIP=`ifconfig |grep "inet"|awk -F "[: ]+" '{print $3}'|head -n1`
function Minitialization(){
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF
swapoff -a
rm -f /swap.img
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
sudo sysctl --system
echo -e "K8s-M`ifconfig |grep "inet"|awk -F "[: ]+" '{print $3}'|head -n1|awk -F "[. ]+" '{print $4}'`">/etc/hostname
#hosts Configuration
echo -e "`ifconfig |grep "inet"|awk -F "[: ]+" '{print $3}'|head -n1`  K8s-M`ifconfig |grep "inet"|awk -F "[: ]+" '{print $3}'|head -n1|awk -F "[. ]+" '{print $4}'`" >> /etc/hosts
#打印当前状态
echo "当前主机名:" `hostname`
echo "hosts解析：" `tail -1 /etc/hosts`	
}
function Ninitialization(){
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF
swapoff -a
rm -f /swap.img
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
sudo sysctl --system
echo -e "K8s-N`ifconfig |grep "inet"|awk -F "[: ]+" '{print $3}'|head -n1|awk -F "[. ]+" '{print $4}'`">/etc/hostname
#hosts Configuration
echo -e "`ifconfig |grep "inet"|awk -F "[: ]+" '{print $3}'|head -n1`  K8s-N`ifconfig |grep "inet"|awk -F "[: ]+" '{print $3}'|head -n1|awk -F "[. ]+" '{print $4}'`" >> /etc/hosts
#打印当前状态
echo "当前主机名:" `hostname`
echo "hosts解析：" `tail -1 /etc/hosts`	
}

function k8sinstall(){
apt-get -y update
systemctl restart docker
apt install containerd -y 
systemctl restart containerd
VERSION="v1.23.0"wget https://github.com/kubernetes-sigs/cri-tools/releases/download/$VERSION/crictl-$VERSION-linux-amd64.tar.gzsudo tar zxvf crictl-$VERSION-linux-amd64.tar.gz
cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://mirrors.aliyun.com/kubernetes/apt/ kubernetes-xenial main
EOF
curl https://mirrors.aliyun.com/kubernetes/apt/doc/apt-key.gpg | apt-key add - 
apt-get update
apt-cache madison kubelet
#安装指定版本
apt-get install -y kubelet=1.22.0-00 kubeadm=1.22.0-00 kubectl=1.22.0-00
#设置开机启动
sudo systemctl enable kubelet && sudo systemctl start kubelet
}

function k8sinit (){
 kubeadm init --apiserver-advertise-address=$localIP --image-repository registry.aliyuncs.com/google_containers --kubernetes-version v1.22.0 --service-cidr=10.1.0.0/16 --pod-network-cidr=10.244.0.0/16

    
}

Minitialization
k8sinit
