---
title: "kubernets 部署"
date: 2023-05-5T01:12:16+08:00
description: "kubernets 部署,1.23.9版本目前遇到的坑"
featured_image: "https://w.wallhaven.cc/full/1p/wallhaven-1pd1o9.jpg"
comment : false
hidden: false
draft: false
tags: ["kubernets"]
Categories: "linux"
---

# Kubernets 部署
> 踩坑更新中
## Docker安装

### 修改docker driver方式
~~~bash
vim /etc/docker/daemon.json
#内容如下所示：
{
    "exec-opts": ["native.cgroupdriver=systemd"]
}
~~~
[相关文章](https://developer.aliyun.com/article/981452)

## 镜像源获取

[阿里云kubernets](https://developer.aliyun.com/mirror/kubernetes)

~~~bash
apt-get update && apt-get install -y apt-transport-https
curl https://mirrors.aliyun.com/kubernetes/apt/doc/apt-key.gpg | apt-key add - 
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb https://mirrors.aliyun.com/kubernetes/apt/ kubernetes-xenial main
EOF
apt-get update
apt-get install -y kubelet kubeadm kubectl

apt install -y kubelet=1.23.9-00 kubectl=1.23.9-00 kubeadm=1.23.9-00
~~~

查询指定版本
~~~bash
apt-cache madison kubect |grep 1.23 
~~~



##  初始化
~~~bash
kubeadm init --image-repository=registry.aliyuncs.com/google_containers 
###获取加入
kubeadm join 192.168.0.199:6443 --token qfczz9.dg5thnmt2ts3aobx  --discovery-token-ca-cert-hash sha256:543bdc5b8d07628e4f83b5754c084956058510e8870867f462971604bb7a3859
~~~
### 常见错误
~~~bash
kubectl get pods
#出现的错误 The connection to the server localhost:8080 was refused - did you specify the right host or port? 
~~~
[相关文章](https://stackoverflow.com/questions/45724889/the-connection-to-the-server-localhost8080-was-refused)

解决方法

~~~bash
sudo mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
~~~
