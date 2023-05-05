---
title: "Kubenets in Action cli"
date: 2023-05-05T16:33:24+08:00
draft: false

description: "kubernets in action 所使用的的指令"
featured_image: "https://w.wallhaven.cc/full/ex/wallhaven-ex9gwo.png"
comment : false
hidden: false
tags: ["kubernets","linux"]
Categories: "book"
---

# 常用指令

> 学习中文档不全,慢慢整理.....

## 2.开始使用kubernets 和docker

### 1. 创建、运行及共享容器镜像



~~~bash
docker build -t kubia .
~~~


### 3. 运行第一个程序

#### 2.访问第web 应用

~~~bash
kubectl expose rc kubia --type=LoadBalancer --name kubia-http
~~~

>我们这里用的是replicationtroller的缩写rc。大 多数资源类型都有这样的缩写，所以不必输入全名（例如，pods的缩写是po,service的缩写是SVC，等等）列出服务

~~~bash
kubectl get service
kubectl get svc
~~~

水平伸缩应用

~~~bash
kubectl get replicationcontrollers

NAME    DESIRED   CURRENT   READY  AGE                                                                                                                                                           
kubia   1         1         1      32m
~~~

>DESIRED 副本数量 ,CURRENT 希望运行的pod数量

增加副本数量

~~~bash
kubectl scale rc kubia --replicas=3

NAME    DESIRED   CURRENT   READY   AGE                                                                              
kubia   3         3         1       34m
~~~

如过有多个副本，则会均衡负载

~~~bash 
root@master:/home/ubuntu/kubernetes-in-action-v1-notes/Chapter02# kubectl  get po                                                                               
NAME          READY   STATUS    RESTARTS   AGE                                                                              
kubia-chlfj   1/1     Running   0          2m19s                                                                            
kubia-lrql6   1/1     Running   0          36m                                                                              
kubia-qk7mv   1/1     Running   0          2m19s                                                                                                                                                     
root@master:/home/ubuntu/kubernetes-in-action-v1-notes/Chapter02# kubectl  get service                                                                          
NAME         TYPE           CLUSTER-IP       EXTERNAL-IP   PORT(S)          AGE                                                                              
kubernetes   ClusterIP      10.96.0.1        <none>        443/TCP          56m                                                                              
kubia-http   LoadBalancer   10.104.229.236   <pending>     8080:31338/TCP   11m                                                                              

root@master:/home/ubuntu/kubernetes-in-action-v1-notes/Chapter02# curl 10.104.229.236:8080                                                                         
You've hit kubia-lrql6                                                                      

root@master:/home/ubuntu/kubernetes-in-action-v1-notes/Chapter02# curl 10.104.229.236:8080                                                                         
You've hit kubia-qk7mv                                                                      

root@master:/home/ubuntu/kubernetes-in-action-v1-notes/Chapter02# curl 10.104.229.236:8080                                                                         
You've hit kubia-qk7mv                                                                      

root@master:/home/ubuntu/kubernetes-in-action-v1-notes/Chapter02# curl 10.104.229.236:8080                                                                         
You've hit kubia-lrql6                                                                      

root@master:/home/ubuntu/kubernetes-in-action-v1-notes/Chapter02# curl 10.104.229.236:8080                                                                         
You've hit kubia-qk7mv                                                                      

root@master:/home/ubuntu/kubernetes-in-action-v1-notes/Chapter02# curl 10.104.229.236:8080                                                                         
You've hit kubia-qk7mv         

oot@master:/home/ubuntu/kubernetes-in-action-v1-notes/Chapter02# curl 10.104.229.236:8080                                                                         
You've hit kubia-chlfj
~~~

列出 pod 时显示 pod IP 和 pod 的节点
~~~bash
kubectl get pods -o wide



NAME          READY   STATUS    RESTARTS   AGE     IP          NODE    NOMINATED NODE   READINESS GATES 
kubia-chlfj   1/1     Running   0          8m49s   10.40.0.2   node2   <none>           <none>
kubia-lrql6   1/1     Running   0          42m     10.40.0.1   node2   <none>           <none>
kubia-qk7mv   1/1     Running   0          8m49s   10.38.0.1   node1   <none>           <none>
~~~

查看pod详细信息

~~~bash
kubectl describe pod kubia-chlfj


Name:         kubia-chlfj                           
Namespace:    default                             
Priority:     0           
Node:         node2/192.168.0.201
Start Time:   Fri, 05 May 2023 09:04:47 +0000
Labels:       run=kubia                                    
Annotations:  <none>                       
Status:       Running
IP:           10.40.0.2
IPs:                                                                         
  IP:           10.40.0.2                                 
Controlled By:  ReplicationController/kubia
~~~

访问GKE集群dashbord
~~~bash
kubectl cluster-info | grep dashboard
~~~
>如果你正在使 用 Google Kubemetes Engine


## 3.运行于Kuberntes 中的容器

## 3.2 以YAML或者JSON文件创建pod

#### 3.2.1 检查现有的yaml描述
 ~~~bash
kubectl get po kubia-zxzij -o yaml
 ~~~

 ![yaml](/kubernet-in-action/2023-03-29_14-37.png)
 ![yaml](/kubernet-in-action/2023-05-05_17-41.png)

- metadata包括名称、命名空间、标 签和关于该容器 的其他信息。
- spec包含p od内容的实际说明，例如p od的容器、卷和其他数据。
- status包含运行中的pod的当前信息，例如po d所处的条件、每个容器的描述和状态，以及内部IP和其他基本信息


使用 kubectl explain 来发现可能的 API 对象字段
~~~bash
#在准备 manifest 时，可以转到 http: //kubemetes.io / docs /api 上的 Kubemetes参考文档查看每个 API 对象支持哪些属性，也可以使用 kubectl explain 命令 。例如，当从头创建一个 pod manifest 时，可以从请求 kubectl 来解释 pod 开始：
kubectl explain pods

kubectl explain pod.spec
~~~

#### 3.2.3 kubectl create 创建pod
~~~bash
kubectl create -f kubia-manual.yam
~~~
得到pod完整定义

~~~bash
kubectl get po kubia-manual -o yaml

kubectl get po kubia-manual -o json
~~~

查看新建的pod
~~~bash
kubectl get pods
~~~

#### 3.2.4 查看应用程序日志

~~~bash
kubectl logs kubia-manual
~~~

如果包含多个pod 的日志时指定容器名称

如果我们的pod包含多个容器， 在运行kubectl logs命令时则必须通过包含-c <容器名称＞选项来显式指定容器名称。 在kubia-manual pod中， 我们将容器的名称设置为kubia, 所以如果该pod中有其他容器， 可以通过如下命令获取其日志
~~~bash
kubectl logs kubia-manual -c kubia
~~~

#### 3.2.5 向pod发送请求

将本地网络端口转发到 pod 中的端口

~~~bash
kubectl  port-forward kubia-manual 8888:8080
~~~