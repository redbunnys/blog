---
title: "Openwrt主路由使用端口回流失效"
date: 2023-04-10T16:09:04+08:00
description: "Openwrt 端口映射，公网访问正常，内网机器无法用公网访问内网机器"
featured_image: "https://w.wallhaven.cc/full/zy/wallhaven-zyxvqy.jpg"
comment : false
hidden: false
draft: false
tags: ['openwrt']
Categories: "openwrt"
---

## Openwrt 解决方法

1. ssh连接openwrt系统后，编辑/etc/sysctl.d/11-br-netfilter.conf文件。

    `net.bridge.bridge-nf-call-arptables=0`
    
    `net.bridge.bridge-nf-call-ip6tables=0`
    
    `net.bridge.bridge-nf-call-iptables=0`

    保证为后面的赋值为 `0`

2. 编辑`/etc/sysctl.conf`文件。文件内容可能是空的，把第一条的内容复制进sysctl.conf文件，保存退出。
   
3. ssh内输入`sysctl -p`命令，结果输出为第一条的添加的字段
   
4. 输入`/etc/init.d/sysctl restart`

## 方法来源

 - http://www.kennylife.cn/index.php/x86_router/openwrt-NAT.html