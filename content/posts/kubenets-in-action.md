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
> 
> 所有资源来自 kubernets in action，只折抄个人需要的

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

### 3.3 使用标签组织pod

#### 3.3.2 创建pod标签labels

创建pod

~~~bash
kubectl create -f kubia-manual-with-labels.yaml
~~~

查看标签

~~~bash
kubectl get po --show-labels
~~~

查看指定的标签 labels,然后分组出来

~~~bash
kubectl get po -L creation_method,env
~~~
![img](/kubernet-in-action/3.3.2/2023-05-06_17-08.png)

#### 3.3.3 修改添加pod 标签 labels

新增标签

~~~bash
kubectl label po kubia-manual creation_method=manual
#pod/kubia-manual labeled
~~~

> 标签也可以在现有 pod 上进行添加和修改。 由于 pod kubia -manual 也是手动创建的， 所以为其添加 creation_method=manual 标签：

修改标签

~~~bash
kubectl label po kubia-manual-v2 env=debug --overwrite
~~~
>修改现有的标签需要添加 --overwrite

![img](/kubernet-in-action/3.3.3/2023-05-06_17-20.png)

### 3.4 通过标签选择器列出pod子集

#### 3.4.1 使用标签选择器列出pod

~~~bash
kubectl get po -L creation_method=manua
~~~

查询不包括`env`的pod

~~~bash
kubectl get po -l '!env'
~~~

查询不包括`env`的pod

~~~bash
kubectl get po -l 'env'
~~~
> 加入 --show-labels 显示lables信息

多种查询条件

~~~bash
kubectl get po -l 'run=kubia' --show-labels

kubectl get po -l 'run!=kubia' --show-labels
~~~
![img](/kubernet-in-action/3.4.1/2023-05-06_17-42.png)

#### 3.4.2 在标签选择器中使用多个条件

~~~bash
kubectl get po -l 'creation_method=manual,method=manual' --show-labels

kubectl get po -l 'creation_method=manual,method!=manual' --show-labels
~~~

![img](/kubernet-in-action/3.4.2/2023-05-06_17-45.png)

### 3.5 使用标签和选择器来约束pod调度

#### 3.5.1 使用标签分类工作节点

假如node1 是SSD,node2 是hdd，某些环境需要ssd，可以通过labels 置顶调度到某个节点

假设我们集群中的 一个节点刚添加完成， 它包含一个用于通用GPU计算的GPU。 我们希望向节点添加标签来展示这个功能特性， 可以通过将 标签gpu=true添加到其中一个节点来实现（只需从kubectl get nodes返回的列表中选择一
个）：

~~~bash
kubectl label node node1 gpu=true
~~~
![img](/kubernet-in-action/3.5.1/2023-05-06_18-00.png)

查询拥有gpu labels的node
~~~bash
kubectl get node -l gpu
~~~

#### 3.5.2 将pod调度到特定节点

~~~bash
apiVersion: v1
kind: Pod
metadata:
  name: kubia-gpu
spec:
  nodeSelector:
    gpu: "true" #node节点有gput=true的，则会调度到这个节点
  containers:
  - image: luksa/kubia
    name: kubia
~~~

### 3.6 注解pod

####  3.6.1 查找对象的注解

![img](/kubernet-in-action/3.6.1/2023-05-06_18-10.png)

#### 3.6.2 添加和修改注解

给 `kubia-manual` pod添加注解
~~~bash
kubectl annotate pod kubia-manual mycompany.com/someannotation="foo bar"
~~~

查看注解
~~~bash
kubectl describe pod kubia-manual
#注解信息
Annotations:  mycompany.com/someannotation: foo bar
~~~

![img](/kubernet-in-action/3.6.2/2023-05-06_18-15.png)


### 3.7 使用命名空间对资源进行分组

#### 3.7.2 发现其他命名空间及其 pod

查看所有命名空间

~~~bash
kubectl get ns
~~~

查看指定的命名空间pod,`kube-system`

~~~bash
kubectl get po --namespace kube-system

kubectl get po -n kube-system
~~~

#### 3.7.3 创建一个命名空间 


~~~bash
apiVersion: v1
kind: Namespace #定义命名空间
metadata:
  name: custom-namespace # 命名空间名称
~~~

直接创建 

~~~bash
kubectl create -f custom-namespace.yaml

#手动创建命名空间

kubectl create namespace custom-namespace
~~~

查看所有命名空间

~~~bash
kubectl get namespace


NAME               STATUS   AGE
custom-namespace   Active   57s
default            Active   4d
kube-node-lease    Active   4d
kube-public        Active   4d
kube-system        Active   4d
~~~

#### 3.7.4 管理其他命名空间中的对象


在创建资源的时候，如果yaml文件没指定，可以在创建时候指定`命名空间`

~~~bash
kubectl create -f kubia-manual.yam1 -n custom-namespace
~~~

切换命名空间
~~~bash
#获取所有
kubectl get namespace
#
kubectl config set-context --current --namespace=<namespace>

kubectl config set-context --current --namespace=custom-namespace
#指定操作命名空间
kubectl get pods -n <namespace>
#
~~~

### 3.8 停止和移除 pod

####  3.8.1 按名称删除 pod

~~~bash
kubectl delete po kubia-gpu
#删除多个po 

kubectl delete po podl pod2

~~~

#### 3.8.2 使用标签选择器删除 pod

删除带 `creation_method=manua` 的labels的pod
~~~bash
kubectl delete po -l creation_method=

#pod "kubia-manual" deleted
#pod "kubia-manual-v2" deleted
~~~

#### 3.8.3 通过删除整个命名空间来删除 pod

命名空间不需要的可以直接删除，同时删除里面的pod
~~~bash
kubectl delete ns custom-namespace
~~~

#### 3.8.4 删除命名空间中的所有pod，但保留命名空间

删除所有的pod 
~~~bash
kubectl delete po --all
~~~
再次查看会发现 之前的pod又重启回来,是因为`ReplicationController`，杀死之后会启动与之相同的pod，得得先删除  `ReplicationController`

#### 3.8.5 删除命名空间中的（几乎）所有资源
~~~bash
kubectl delete all --all


pod "kubia-fvn4n" deleted
pod "kubia-lnwdg" deleted
pod "kubia-tgnlk" deleted
replicationcontroller "kubia" deleted #删除了 ReplicationController 所有的资源被删除
service "kubernetes" deleted
service "kubia-http" deleted
~~~
> 命令中的第 一个 all 指定正在删除所有资源类型， 而 --all 选项指定将删除所有资源实例而不是按名称指定它们（我们在运行前一个删除命令时已经使用过此选项）。

>注意 kubectl delete all --all 命令也会删除名为 kubernetes 的Service, 但它应该会在几分钟后自动重新创建。

### 3.9 本章小结
阅读本章之后， 你应该对 Kubemetes 的核心模块有了系统的了解。 在接下来的
几章中学到的概念也都与 pod 有着直接关联。

在本章中， 你应该已经掌握：
- 如何决定是否应将某些容器组合在一个 pod 中。
- pod可以运行多个进程， 这和非容器世界中的物理主机类似。
- 可以编写 YAML 或 JSON 描述文件用于创建 pod, 然后查看 pod 的规格及其
当前状态。
- 使用标签来组织 pod, 并且一 次在多个 pod 上执行操作。
- 可以使用节点标签将 pod 只调度到提供某些指定特性的节点上。
- 注解允许入们、 工具或库将更大的数据块附加到 pod。
- 命名空间可用千允 许不同团队使 用同 一 集 群， 就像它 们使 用单独的
Kubemetes 集群一 样。
- 使用 kubectl explain 命令快速查看任何 Kubernetes 资源的信息。
在下一章， 你将会了解到 ReplicationController 和其他管理 pod 的资源。


## 4. 副本机制和其他控制器:部署托管的pod

### 4.1 保持pod健康

- 使用 Kubernetes 的一 个主要好处是， 可以给 Kubernetes 一个容器列表来由其 保
持容器在集群中的运行。 可以通过让 Kubernetes 创建 pod 资源， 为其选择 一 个工作
节点并在该节点上运行该 pod 的容器来完成此操作。 但是， 如果其中一个容器终止，
或一 个 pod 的所有容器都终止， 怎么办？
- 只要将 pod 调度到某个节点， 该节点上的 Kubelet 就会运行 pod 的容器， 从此
只要该 pod 存在， 就会保持运行。 如果容器的主进程崩溃， Kubelet 将重启容器。 如
果应用程序中有一 个导致它每隔 一 段时间就会崩溃的 bug, Kubemetes 会自动重启
应用程序， 所以即使应用程序本身没有做任何特殊的事， 在 Kubemetes 中运行也能
自动获得自我修复的能力。
- 即使进程没有崩溃， 有时应用程序也会停止正常工作。 例如， 具有内存泄漏的
Java 应用程序将开始抛出 OutOfMemoryErrors, 但 JVM 进程会一 直运行。 如果有
一种方法， 能让应用程序向 Kubernetes 发出信号， 告诉 Kubemetes 它运行异常并让
Kubemetes 重新启动， 那就很棒了。
- 我们已经说过， 一 个崩溃的容器会自动重启， 所以也许你会想到， 可以在应用
中捕获这类错误， 并在错误发生时退出该进程。 当然可以这样做， 但这仍然不能解
决所有的问题。
- 例如， 你的应用因为无限循环或死锁而停止响应。 为确保应用程序在这种情况
下可以重新启动， 必须从外部检查应用程序的运行状况， 而不是依赖于应用的内部
检测。

#### 4.1.1 介绍存活探针

Kubemetes 有以下三种探测容器的机制：
- HTTPGET 探针对容器的 IP 地址（你指定的端口和路径）执行 HTTP GET 请求。
如果探测器收到响应，并且响应状态码不代表错误（换句话说，如果HTTP
响应状态码是2xx或3xx), 则认为探测成功。如果服务器返回错误响应状态
码或者根本没有响应，那么探测就被认为是失败的，容器将被重新启动。
- TCP套接字探针尝试与容器指定端口建立TCP连接。如果连接成功建立，则
探测成功。否则，容器重新启动。
- Exec探针在容器内执行任意命令，并检查命令的退出状态码。如果状态码
是 o, 则探测成功。所有其他状态码都被认为失败。


#### 4.1.2 创建基于HTTP的存活探针

~~~yml
apiVersion: v1
kind: Pod
metadata:
  name: kubia-liveness
spec:
  containers:
  - image: luksa/kubia-unhealthy #的含么包怎用像知应镜不的^_（掉这了坏
    name: kubia
    livenessProbe: # http get 探针
      httpGet:
        path: / #请求路径
        port: 8080 #端口
~~~

#### 4.1.3 使用存活探针

4.1.2 使用之后pod 报错会重启
~~~bash
kubectl get po kubia-liveness
~~~

查看log日志
~~~bash

#查看当前容器
kubectl logs mypod 


#查看上个容器为啥报错
kubectl logs mypod --previous
#-----
Kubia server starting...
Received request from ::ffff:10.40.0.0
Received request from ::ffff:10.40.0.0
Received request from ::ffff:10.40.0.0
Received request from ::ffff:10.40.0.0
Received request from ::ffff:10.40.0.0
Received request from ::ffff:10.40.0.0
Received request from ::ffff:10.40.0.0
Received request from ::ffff:10.40.0.0
~~~

#### 4.1.4 配置存活探针的附加属性
~~~bash
kubectl get po kubia-liveness

Liveness:       http-get http://:8080/ delay=0s timeout=1s period=10s #success=1 #failure=3
~~~

delay(延迟）、巨meout(超时）、period(周期）等。delay=Os部分显示在容器启动后立即开始探测。tmeout仅设置为1秒，因此容器必须在1秒内进行响应， 不然这次探测记作失败。每10秒探测一次容器(period=lOs), 并在探测连续三次失败(#falure= 3)后重启容器

添加自定义参数 `initalDelaySeconds`

~~~yml
apiVersion: v1
kind: Pod
metadata:
  name: kubia-liveness
spec:
  containers:
  - image: luksa/kubia-unhealthy
    name: kubia
    livenessProbe:
      httpGet:
        path: /
        port: 8080
      initialDelaySeconds: 15 #Kubernetes会在第—次探测前等待15秒
~~~

>提示务必记得设置一个初始延迟未说明应用程序的启动时间。如果程序启动过久则会重新启动容易，陷入循环

很多场合都会看到这种情况， 用户很困惑为什么他们的容器正在重启。 但是如果使用kubectl describe, 他们会看到容器以退出码137或143结束， 并告诉他们 该pod是被迫终止的。 此外，pod事件的列表将显示容器因liveness探测失败而被终止。 如果你在pod启动时 看到这种情况， 那是因为未能适当设置
initialDelaySeconds。

>注意退出代码137表示进程被外部信号终止， 退出代码为128+9 (SIGKILL)。
同样， 退出代码143对应于128+15 (SIGTERM)。

#### 4.1.5 创建有效的存活探针

对于生产环境中一定要有个存活探针

1. 存活探针应该检查什么
   检查服务是否响应。未响应则重启容器,一般配置特定的url `/health HTTP`
   >提示请确保/health HTTP瑞点不需要认证， 否则探剧会一直失败， 导致你的容器无限重启。
2. 保持探针轻量
   探针只需要知道服务的是否正常运行，不占用大量资源，重量化会影响你的容器运行
   >如果你在容器中运行Java应用程序， 请确保使用HTTP GET存活探针，而不是启动全新NM以荻取存活信息的Exec探针。 任何基于NM或类似的应用程序也是如此， 它们的启动过程需要大量的计算资原。
3. 无须在探针中实现重试循环
  探针失败阈值是可以设置的，你设置为1，但是kubernets 会自动尝试请求多次。因此 在探针中自己实现重试循环是浪费精力。

存活探针小结

- 你现在知道Kubernetes会在你的容器崩溃或其存活探针失败时， 通过重启容器
来保持运行。 这项任务由承载pod的节点上的Kubelet 执行 一— 在主服务器上运行
的KubernetesControl Plane组件不 会参与此 过程。
- 但如果节点本身崩溃， 那么Control Plane 必须为所有随节点停止运行的pod创
建替代品。 它不 会为你直接创建的pod执行此操作 。 这些pod只被Kubelet 管理，
但由于Kubelet 本身运行在节点上， 所以如果节点异常终止，它将无法执行任何操作。
- 为 了 确保你 的应 用 程序在另 一 个 节 点 上 重新启动， 需要使 用
Rep巨ca巨onController或类似机制管理pod, 我们将在本章其余部分讨论该
机制。

### 4.2 了解ReplicationController
   ReplicationController是一 种Kubemetes资源，可确保它的pod始终保持运行状态。
如果pod因任何原因 消失（例如节点从集群中消失或由于该pod已从节点中逐出），
则ReplicationController 会注意到缺少了pod并创建替代pod。

#### 4.2.1 ReplicationController的操作

ReplicationController会持续监控正在运行的pod列表， 并保证相应 ” 类型” 的
pod的数目与期望相符。 如正在运行的pod太少， 它会根据pod模板创建新的副本。
如正在运行的pod太多， 它将删除多余的副本。 你可能会对有多余的副本感到奇怪。
这可能有几个原因：
- 有人会手动创建相同类型的pod。
- 有人更改现有的pod的 ” 类型” 。
- 有人减少了所需的pod的数量， 等等。

![img](/kubernet-in-action/2023-05-10_15-52_4.2.1.png)

##### 了解ReplicationController的三部分
一个ReplicationController有三个主要部分（如图4.3所示）：
- label selector ( 标签选择器）， 用于确定ReplicationController作用域中有哪些
pod
- replica count (副本个数）， 指定应运行的pod 数量
- pod template (pod模板）， 用于创建新的pod 副本
  
![img](/kubernet-in-action/2023-05-10_15-55_4.2.1-2.png)

#### 4.2.2 创建一 个 ReplicationController

~~~yml
apiVersion: v1
kind: ReplicationController #配置 ReplicationController(RC)
metadata:
  name: kubia #配置 ReplicationController 名字
spec:
  replicas: 3 #配置 pod 实例的数量  
  selector: #pod 决定的RC 操作对象
    app: kubia #pod
  template: #创建新的pod 所用的pod模板
    metadata:
      labels:
        app: kubia
    spec:
      containers:
      - name: kubia
        image: luksa/kubia
        ports:
        - containerPort: 8080
~~~

新建时，会创建名kubia的新ReplicationControl，确保 app=kubia的pod始终为三个。pod不够会根据模板创建。并且pod 标签要与RC选择器匹配。不然会永无止境的创建。新启动的不会使实际的副本数量接近期望的副本数量。为了防止出现这种情况，API服务会校验ReplicationController的定义，不会接收错误配置。
>提示定义ReplicationController时不要指定pod选择器，让Kubemetes从pod模板中提取它。这样YAML更简短。

~~~bash
kubectl create  -f kubia-rc.yaml
~~~

#### 4.2.3 使用ReplicationController

查看pod
~~~bash
kubect get pods
~~~
查看 ReplicationController 对已删除的 pod 的响应

~~~bash
kubect delete pod kubia-53thy
~~~

获取有关 ReplicationController 的信息

~~~bash
kubectl get rc
~~~

>注意使用re作为replicationcontroller的简写。

查看rc详细信息
~~~bash
kubect describe get rc

Name:         kubia                                                                                       
Namespace:    default                                                                                     
Selector:     app=kubia                                                                                   
Labels:       app=kubia                                                                                   
Annotations:  <none>                                                                                      
Replicas:     3 current / 3 desired      # pod 实际数量和目标数量                                                                  
Pods Status:  3 Running / 0 Waiting / 0 Succeeded / 0 Failed       #每种状态的pod数量                                        
Pod Template:                                                                                             
  Labels:  app=kubia         
  Containers:                                                                                             
   kubia:                                                                                                 
    Image:        luksa/kubia                                                                             
    Port:         8080/TCP                                                                                
    Host Port:    0/TCP                                                                                   
    Environment:  <none>                                                                                  
    Mounts:       <none>                                                                                  
  Volumes:        <none>                                                                                  
Events:                                         #和这个有关的RC 事件                                                           
  Type    Reason            Age    From                    Message                                        
  ----    ------            ----   ----                    -------                 
  Normal  SuccessfulCreate  32m    replication-controller  Created pod: kubia-wqc7x
  Normal  SuccessfulCreate  32m    replication-controller  Created pod: kubia-hxgzj
  Normal  SuccessfulCreate  32m    replication-controller  Created pod: kubia-hv7px
  Normal  SuccessfulCreate  5m11s  replication-controller  Created pod: kubia-8z4mz
  Normal  SuccessfulCreate  3m1s   replication-controller  Created pod: kubia-jfslp
~~~

#### 4.2.4 将 pod 移入或移出 ReplicationController 的作用域

由ReplicationController创建的pod并不是绑定到ReplicationController。是由标签选择器匹配。如果我们更改pod的标签不与相匹配。可以从RC作用域中删除添加。也可以转移到其他的ReplicationController。

 如果更改了pod的标签，不匹配。异常不会被重新调度，成为手动创建的一样。更改之后旧的ReplicationController 会调度新的保持。

>尽管一个pod没有绑定到一个ReplicationController，但该pod在rnetadata.ownerReferences字段中引用它，可以轻松使用它来找 到一个pod属于哪个ReplicationController


给ReplicationController管理的pod加标签
1. 你向reaplcationController 管理的pod添加其他标签，没有任何影响
   
   ~~~bash
   kubectl label pod kubia-jlm79 type=special

   kubectl  get pod --show-labels

   NAME          READY   STATUS    RESTARTS   AGE   LABELS
   kubia-8z4mz   1/1     Running   0          49m   app=kubia
   kubia-jlm79   1/1     Running   0          30m   app=kubia,type=special
   kubia-wdlc8   1/1     Running   0          30m   app=kubia
   ~~~

2. 更改己托管的od 的标签
   ~~~bash
   kubectl label pod  kubia-wdlc8  app=foo --overwrite

   NAME          READY   STATUS    RESTARTS   AGE   LABELS
   kubia-8z4mz   1/1     Running   0          53m   app=kubia
   kubia-jlm79   1/1     Running   0          35m   app=kubia,type=special
   kubia-qz9dx   1/1     Running   0          7s    app=kubia
   kubia-wdlc8   1/1     Running   0          35m   app=foo
   ~~~
   由此可见，更改之后新建了

3. 从控制器删除pod
   当你想操作特定的 pod 时， 从 ReplicationController 管理范围中移除 pod 的操作很管用。例如，你可能有一个 bug 导致你的 pod 在特定时间或特定事件后开始出问题。如果你知道某个 pod 发生了故障， 就可以将它从 Replication-Controller 的管理范围中移除， 让控制器将它替换为新 pod, 接着这个 pod 就任你处置了。 完成后删除该pod 即可。


#### 4.2.5 修改pod模板

打开现有的模板
~~~bash
kubectl edit  rc  kubia
~~~
打开现有的模板，我们添加一个新的标签

输出`replicationconColler "kubia" edited`

下次新启动的pod就带你添加的 label
>配置kubectl edit使用不同的文本编辑器可以通过设置KUBE_EDITOR环境变量来告诉kubectl使用你期望的文本编辑器。 例如，如果你想使用nano编辑Kubernetes资源，请执行以下命令（或将其放入- /.bashrc或等效文件中）：
>
>export KUBE_EDITOR="/usr/bin/nano"
>
>如果未设置KUBE_EDITOR环境变量， 则kubectl edted会回退到使用默认编辑器（通常通过EDITOR环境变量进行配置）。

#### 4.2.6 水平缩放pod

你已经看到了ReplicationController如何确保待续运行的pod实例 数量保持不变。因为改变副本的所需数量非常简单， 所以这也意味着水平缩放pod很简单。放大或者缩小pod的数量规模就和在ReplicationController资源中更改Replicas字段的值 一样简单。 更改之后，ReplicationController将 会看到存在太多的pod并删除其中的一部分（缩容时）， 或者看到它们数目太少并创建 pod (扩容时）。

1. ReplicationController扩容
   现在的副本一直保持3，现在给扩容到10
   
   ~~~bash
   kubectl scale rc kubia --replicas=10
   ~~~

   但这次你的做法会不一样。通过编辑定义来缩放ReplicationController
   ~~~bash
   kubectl edit rc kubia
   
   apiVersion: v1
   kind: ReplicationController
   metadata:
     creationTimestamp: "2023-05-10T08:09:50Z"
     generation: 4
     labels:
       app: kubia
     name: kubia
     namespace: default
     resourceVersion: "618771"
     uid: 337c97c4-1c94-4aba-885e-27ce02c8a378
   spec:
     replicas: 10 # 这里修改
     selector:
       app: kubia
     template:
   ~~~