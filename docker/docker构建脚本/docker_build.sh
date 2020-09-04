#!/bin/sh
sudo curl -fsSL get.docker.com -o get-docker.sh
sudo sh get-docker.sh --mirror Aliyun

sudo systemctl enable docker
sudo systemctl start docker

sudo groupadd docker
sudo usermod -aG docker $USER

cat>/etc/docker/daemon.json<<EOF
{
  "log-driver":"json-file",
  "log-opts": {"max-size":"500m", "max-file":"3"},
  "exec-opts": ["native.cgroupdriver=systemd"],
  "storage-driver": "overlay2",
  "insecure-registries": [ "10.0.52.21:5000"],
  "registry-mirrors": [
    "https://docker.mirrors.ustc.edu.cn",
    "https://registry.docker-cn.com"
  ]
}
EOF

sudo systemctl restart docker