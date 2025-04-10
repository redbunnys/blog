---
title: "国内镜像站"
date: 2024-03-29T11:07:16+08:00
description: "国内镜像站,系统安装包,npm,git,go,rust代理"
featured_image: "https://w.wallhaven.cc/full/j3/wallhaven-j3m8y5.png"
comment : true
hidden: false
draft: false
tags: ["linux"]
Categories: "www"
---

### 镜像源

[清华源](https://mirrors.tuna.tsinghua.edu.cn/)

~~~bash
https://mirrors.tuna.tsinghua.edu.cn/
~~~

[华为镜像源](https://mirrors.huaweicloud.com/home)

~~~bash
https://mirrors.huaweicloud.com/home
~~~

[阿里源](https://developer.aliyun.com/mirror/)

~~~
https://developer.aliyun.com/mirror/
~~~

[腾讯源]( https://mirrors.cloud.tencent.com/)

~~~bash
https://mirrors.cloud.tencent.com/
~~~

[163源](https://mirrors.163.com/)

~~~bash
https://mirrors.163.com/
~~~

----

### Windows系统下载

[msdn老版](https://msdn.itellyou.cn/)

[msdn新版](https://next.itellyou.cn/)


### Npm源

[阿里源](https://npmmirror.com/)

- 开源镜像: [https://npmmirror.com/mirrors/](https://npmmirror.com/mirrors/?spm=a2c6h.24755359.0.0.6d444dcc7N3fDO)
- Node.js 镜像: https://npmmirror.com/mirrors/node/
- alinode 镜像: https://npmmirror.com/mirrors/alinode/
- ChromeDriver 镜像: https://npmmirror.com/mirrors/chromedriver/
- OperaDriver 镜像: https://npmmirror.com/mirrors/operadriver/
- Selenium 镜像: [https://npmmirror.com/mirrors/selenium/](https://npmmirror.com/mirrors/selenium/?spm=a2c6h.24755359.0.0.6d444dcc7N3fDO)
- electron 镜像: https://npmmirror.com/mirrors/electron/

**使用说明**

1. 你可以使用我们定制的 [cnpm](https://github.com/cnpm/cnpm) (gzip 压缩支持) 命令行工具代替默认的 `npm`:

   ```bash
   $ npm install -g cnpm --registry=https://registry.npmmirror.com
   ```

2. 或者你直接通过添加 `npm` 参数 `alias` 一个新命令:

   ~~~bash
   alias cnpm="npm --registry=https://registry.npmmirror.com \
   --cache=$HOME/.npm/.cache/cnpm \
   --disturl=https://npmmirror.com/mirrors/node \
   --userconfig=$HOME/.cnpmrc"
   
   # Or alias it in .bashrc or .zshrc
   $ echo '\n#alias for cnpm\nalias cnpm="npm --registry=https://registry.npmmirror.com \
     --cache=$HOME/.npm/.cache/cnpm \
     --disturl=https://npmmirror.com/mirrors/node \
     --userconfig=$HOME/.cnpmrc"' >> ~/.zshrc && source ~/.zshrc
   ~~~

3. 安装模块

   ~~~bash
   cnpm install [name]
   ~~~

4. 更新模块

   直接通过 `sync` 命令马上同步一个模块, 只有 `cnpm` 命令行才有此功能

   ~~~bash
   cnpm sync express
   ~~~

   当然, 你可以直接通过 web 方式来同步: [/sync/express](https://npmmirror.com/sync/express)

   ~~~bash
    open https://npmmirror.com/sync/express
   ~~~

5. 其他命令

   支持 `npm` 除了 `publish` 之外的所有命令, 如:

   ```bash
    cnpm info express
   ```

> 官网有更详细的教程使用

----

### Pip源

清华大学：

```text
https://pypi.tuna.tsinghua.edu.cn/simple
```

阿里云：

```text
http://mirrors.aliyun.com/pypi/simple/
```

腾讯云：

```text
https://mirrors.cloud.tencent.com/pypi/simple/
```

中国科技大学：

```text
https://mirrors.cloud.tencent.com/pypi/simple/
```

豆瓣：

```text
https://pypi.doubanio.com/simple/
```

浙江大学：

```text
https://mirrors.zju.edu.cn/pypi/web/simple/
```

 **使用教程**

1. 临时使用

   在pip后面加上参数 `-i`

   ~~~bash
   pip install scrapy -i https://mirrors.aliyun.com/pypi/simple
   ~~~

2. 永久使用

   - Linux

     修改` ~/.pip/pip.conf` (没有就创建一个)， 内容如下:

     ~~~bash
     [global]
     index-url = https://mirrors.aliyun.com/pypi/simple
     ~~~

   - Windows

     直接在user目录中创建一个pip目录，如：C:\Users\xx\pip，新建文件pip.ini，内容如下,或者 win+R ，输入`%homepath%`下面新建 pip文件夹，进入pip文件夹新建 pip.ini

     ~~~bash
     [global]
     index-url = https://mirrors.aliyun.com/pypi/simple
     ~~~

3. 其他

   报错：如果报错 "The repository located at mirrors.aliyun.com is not a trusted … "的情况

   1. 一次性解决：

      ~~~bash ~~~
      pip install scrapy -i http://mirrors.aliyun.com/pypi/simple/ --trusted-host mirrors.aliyun.com
      ~~~

   2. 永久解决：在pip.conf下添加：

      ~~~bash
      [global]
      trusted-host=mirrors.aliyun.com
      ~~~

----

### GoLang源

- 七牛：Goproxy 中国 https://goproxy.cn
- 阿里： https://mirrors.aliyun.com/goproxy/
- 官方： 全球CDN加速 https://goproxy.io/
- 其他：jfrog 维护 https://gocenter.io

 设置代理

1. 类 Unix(linux)

   ~~~bash
   # 启用 Go Modules 功能
   go env -w GO111MODULE=on
   
   # 配置 GOPROXY 环境变量，举一个栗子
   
   go env -w  GOPROXY=https://goproxy.cn,direct
   ~~~

   查看是否完成设置完成

   ~~~bash
   go env | grep GOPROXY
   #显示成功
   GOPROXY="https://goproxy.cn,direct"
   ~~~

2. Windows

   ~~~cmd
   # 启用 Go Modules 功能
   $env:GO111MODULE="on"
   
   # 配置 GOPROXY 环境变量，举一个栗子
   
   $env:GOPROXY="https://goproxy.cn,direct"
   ~~~

   查看是否完成设置完成

   ~~~cmd
   go env
   #找到这一行则可以了
   set GOPROXY=https://goproxy.cn,direct
   ~~~

   

----


### Rust源

中国科学技术大学

~~~bash
#git协议
git://mirrors.ustc.edu.cn/crates.io-index
#http
http://mirrors.ustc.edu.cn/crates.io-index
~~~

上海交通大学

~~~bash
https://mirrors.sjtug.sjtu.edu.cn/git/crates.io-index
~~~

清华大学 

~~~bash
https://mirrors.tuna.tsinghua.edu.cn/git/crates.io-index.git
~~~

rustcc社区

~~~bash
https://code.aliyun.com/rustcc/crates.io-index.git
~~~

1. 类 Unix(Linux)

   创建 `$HOME/.cargo/config`

   ~~~bash
   [source.crates-io]
   registry = "https://github.com/rust-lang/crates.io-index"
   # 指定镜像
   replace-with = '镜像源名' # 如：tuna、sjtu、ustc，或者 rustcc
   #replace-with = 'tuna' 
   # 注：以下源配置一个即可，无需全部
   
   # 中国科学技术大学
   [source.ustc]
   registry = "git://mirrors.ustc.edu.cn/crates.io-index"
   
   # 上海交通大学
   [source.sjtu]
   registry = "https://mirrors.sjtug.sjtu.edu.cn/git/crates.io-index"
   
   # 清华大学
   [source.tuna]
   registry = "https://mirrors.tuna.tsinghua.edu.cn/git/crates.io-index.git"
   
   # rustcc社区
   [source.rustcc]
   registry = "https://code.aliyun.com/rustcc/crates.io-index.git"
   ~~~

2. Windows

   直接在user目录中创建一个pip目录，如：C:\Users\\[用户名]\\.cargo\config，内容如下,或者 win+R ，输入`%homepath%`下面新建 .cargo文件夹，进入pip文件夹新建config

   ~~~txt
   [registry]
   index = "https://mirrors.ustc.edu.cn/crates.io-index/"
   [source.crates-io]
   replace-with = 'ustc'
   [source.ustc]
   registry = "https://mirrors.ustc.edu.cn/crates.io-index/"
   ~~~

-----

### Git加速源

- https://hub.fastgit.org
- https://github.com.cnpmjs.org
- https://gitclone.com/

使用教程

~~~bash
#源git克隆
git clone https://github.com/gin-gonic/gin.git
#加速
git clone https://gitclone/gin-gonic/gin.git
~~~

-----

### 各个源版本大合集

这里只列出常用的几个

更多请点击 [USTC Mirror](https://mirrors.ustc.edu.cn/help/)

~~~bash
https://mirrors.ustc.edu.cn/help/
~~~

