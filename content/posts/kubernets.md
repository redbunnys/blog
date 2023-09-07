---
title: "kubernets 部署"
date: 2023-05-05T01:12:16+08:00
description: "kubernets 部署,1.23.9版本目前遇到的坑"
featured_image: "https://w.wallhaven.cc/full/1p/wallhaven-1pd1o9.jpg"
comment : true
hidden: false
draft: false
tags: ["kubernets"]
Categories: "linux"
---

# Kubernets 部署
> 踩坑更新中
>
> 参考教程：[链接](https://k8s.easydoc.net/docs/dRiQjyTY/28366845/6GiNOzyZ/nd7yOvdY)
## Docker安装

### 一键脚本

~~~bash
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
Executing docker install script, commit: 7cae5f8b0decc17d6571f9f52eb840fbc13b2737
<...>
~~~
>https://docs.docker.com/engine/install/ubuntu/

### 修改docker driver方式
查看   
~~~bash
sudo docker info | grep "Cgroup Driver
~~~

如果不是 `Cgroup Driver: systemd`,则使用下面的配置文件更改

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
#apt-mark hold kubelet=1.23.9-00 kubectl=1.23.9-00 kubeadm=1.23.9-00
~~~

查询指定版本
~~~bash
apt-cache madison kubect |grep 1.23 
~~~



##  初始化
~~~bash
# 初始化集群控制台 Control plane
# 失败了可以用 kubeadm reset 重置
kubeadm init --image-repository=registry.aliyuncs.com/google_containers 

# 记得把 kubeadm join xxx 保存起来
# 忘记了重新获取：kubeadm token create --print-join-command

# 复制授权文件，以便 kubectl 可以有权限访问集群
# 如果你其他节点需要访问集群，需要从主节点复制这个文件过去其他节点

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

## 安装网络同步插件

>主节点

~~~bash
# 很有可能国内网络访问不到这个资源，你可以网上找找国内的源安装 flannel
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

# 如果上面的插件安装失败，可以选用 Weave，下面的命令二选一就可以了。
#建议使用这个，这个安装成功
kubectl apply -f https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml


kubectl apply -f http://static.corecore.cn/weave.v2.8.1.yaml

# 更多其他网路插件查看下面介绍，自行网上找 yaml 安装
https://blog.csdn.net/ChaITSimpleLove/article/details/117809007
~~~




## 报错的

1. [kubernetes installation and kube-dns: open /run/flannel/subnet.env: no such file or directory](https://stackoverflow.com/questions/40534837/kubernetes-installation-and-kube-dns-open-run-flannel-subnet-env-no-such-file)
   
   使用其他的cni软件，不使用flannel
    
   ~~~
   rm -f /etc/cni/net.d/*flannel*
   ~~~