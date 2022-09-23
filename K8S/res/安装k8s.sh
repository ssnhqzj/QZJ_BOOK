#!/usr/bin/env bash

yum install  ipvsadm bash-completion iproute-tc -y

sed -i '/^SELINUX=/s/enforcing/disabled/' /etc/selinux/config

systemctl stop firewalld

systemctl disable firewalld

lsmod | grep br_netfilter

cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

modprobe overlay
modprobe br_netfilter


cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sysctl --system


# 关闭交换分区
swapoff -a     # 临时
sed -i '/swap/ s/^/#/' /etc/fstab # 永久

# 安装docker-ce

yum install -y yum-utils device-mapper-persistent-data lvm2
yum-config-manager --add-repo https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo

# https://mirrors.aliyun.com/

# 安装kubeadm 或者 minikube

cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF

yum makecache -y

# 查看版本. 1.24以上不支持docker
yum search kubeadm --showduplicates  

# yum install -y kubelet-1.22.9 kubeadm-1.22.9 kubectl-1.22.9

yum install kubeadm -y


# 生成配置containerd的配置文件，修改
# 61行 sandbox_image = "registry.cn-hangzhou.aliyuncs.com/google_containers/pause:3.7"
# 125行 SystemdCgroup = true
rm /etc/containerd/config.toml -f
containerd config default  > /etc/containerd/config.toml
systemctl restart containerd
systemctl enable containerd

# https://kubernetes.io/zh-cn/docs/setup/production-environment/container-runtimes/   容器运行时设置文档地址


# 设置命令补全
kubeadm completion bash > /usr/share/bash-completion/completions/kubeadm
kubectl completion bash > /usr/share/bash-completion/completions/kubectl
crictl completion bash > /usr/share/bash-completion/completions/crictl


# 查看默认镜像
kubeadm config  images list
kubeadm config  images list --image-repository=registry.cn-hangzhou.aliyuncs.com/google_containers
kubeadm config images pull --image-repository=registry.cn-hangzhou.aliyuncs.com/google_containers

# 初始化集群
kubeadm init --kubernetes-version=1.24.3 --pod-network-cidr=10.253.0.0/16 --service-cidr=180.198.0.0/24 --image-repository=registry.cn-hangzhou.aliyuncs.com/google_containers

# 安装网络插件
kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml

# 查看污点
kubectl describe nodes k8s | grep -A 3 -i taint

# 去掉污点
kubectl taint node k8s node-role.kubernetes.io/control-plane:NoSchedule-
kubectl taint node k8s node-role.kubernetes.io/master:NoSchedule-
kubectl taint node k8s node.kubernetes.io/not-ready:NoSchedule-

# 查看dns服务详情
kubectl -n kube-system describe pod coredns-7f74c56694-fqg4n

# 修改默认的pod地址，同上述的pod地址相同，修改84行"Network": "10.253.0.0/16"，将其改成pod的网络

kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml

kubectl get pod -n kube-system

kubectl delete pod coredns-xxxxxxx -n kube-system

kubectl get pod -o wide


# ipvs代理

yum install ipvsadm -y

kubectl get cm -n kube-system

kubectl edit cm -n kube-system kube-proxy

# iptables默认代理模式


# 生成节点加入集群的命令，node需安装kubelet，kubeadm，kubectl

kubeadm token create --print-join-command