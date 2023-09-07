---
title: "hugo github Action 部署"
date: 2023-03-29T15:05:16+08:00
description: "hugo静态一键部署到自己的vps上面"
featured_image: "https://w.wallhaven.cc/full/e7/wallhaven-e7jj6r.jpg"
comment : true
hidden: false
draft: false
tags: ["linux"]
Categories: "www"
---

# Github配置

## 进入自己的仓库
打开 setting ->  Actions -> General, 找到 `Workflow permissions`,选中 `Read and write permissions`, 点击`save`保存
 ![ 步骤1](/2023-03-29_14-37.png)
 ![](/2023-03-29_14-38.png)

## 远程服务器配置 rsync

### 下载rsync
~~~bash
sudo apt install rsync
~~~

添加配置文件

~~~bash
sudo vim /etc/rsyncd.conf

[blog]
path = /var/www/hugo
comment = web root
read only = no
list = yes
uid = 0
gid = 0
auth users = myblog
secrets file = /etc/rsyncd.secrets #用户的密码的文件配置目录
~~~

添加rsync用户登录密码

存放的目录为配置文件里面的目录: rsync 密码格式 [用户名]:[密码]

~~~bash
sudo vim /etc/rsyncd.secrets
##或者 echo
echo "myblog:123321" > /etc/rsyncd.secrets
~~~

修改权限
~~~bash
sudo chmod 0600  /etc/rsyncd.secrets
~~~

启动rsync
~~~bash
sudo systemctl  start rsync
~~~

##  配置Github Actions
配置`RSYNC_PASSWORD`

![](/2023-03-29_14-59.png)


配置`Github Actions`文件
~~~yaml
name: github pages

on:
  push:
    branches:
      - main  # 这里是提交到master分支就立即触发job
  pull_request:

jobs:
  deploy: 
    runs-on: ubuntu-20.04
    steps:
      - uses: actions/checkout@v2
        with:
          submodules: true  # Fetch Hugo themes (true OR recursive)
          fetch-depth: 0    # Fetch all history for .GitInfo and .Lastmod

      - name: Setup Hugo
        uses: peaceiris/actions-hugo@v2
        with:
          hugo-version: '0.111.2' 
          extended: true 

      - name: Build
        run: hugo --minify

      - name: Deploy Github
        uses: peaceiris/actions-gh-pages@v3
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}  # 这里不用动, 默认就好
          publish_dir: ./public  # 注意是hugo的public文件夹
          cname: www.XXXX.com # cname
          
      - name: Deploy to VPS
        env: 
          RSYNC_PWD: ${{ secrets.RSYNC_PASSWORD }}
        run: |
          echo $RSYNC_PWD > rsync.pwd
          sudo chmod 600 rsync.pwd
          rsync -avP --delete public/*   --password-file=rsync.pwd myblog@[ip]::blog
~~~
