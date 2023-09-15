---
title: "linux service编写"
date: 2023-08-10T12:16:10+08:00
draft: false
description: "linux service "
featured_image: "https://w.wallhaven.cc/full/nz/wallhaven-nzmeog.jpg"
comment : true
hidden: false
tags: ["linux"]
Categories: "linux"
---

## 编写脚本

示例: 
~~~bash
[Unit]   
Description=hugo test    
After=network.target    

[Service] 
Type=simple     
User=root        
Group=root       
WorkingDirectory=/home/xxxx/code/blog
KillMode=control-group  
Restart=no        
ExecStart=hugo server -D   
StandardOutput=file:/path/to/service.log
StandardError=file:/path/to/error.log
   
[Install]   
WantedBy=multi-user.target  # 多用户
~~~

可以看见服务的`Target`
~~~bash
#执行
ls -ratl /etc/systemd/system | grep wants
#输出
drwxr-xr-x  2 root root 4096  8月24日 05:20 getty.target.wants
drwxr-xr-x  2 root root 4096  8月24日 05:26 sysinit.target.wants
drwxr-xr-x  2 root root 4096  8月24日 05:26 graphical.target.wants
drwxr-xr-x  2 root root 4096  8月24日 05:26 bluetooth.target.wants
drwxr-xr-x  2 root root 4096  8月24日 05:26 printer.target.wants
drwxr-xr-x  2 root root 4096  8月24日 05:26 systemd-coredump@.service.wants
drwxr-xr-x  2 root root 4096  8月24日 05:26 network-online.target.wants
drwxr-xr-x  2 root root 4096  8月24日 09:02 sockets.target.wants
drwxr-xr-x  2 root root 4096  8月27日 06:09 timers.target.wants
drwxr-xr-x  2 root root 4096  8月27日 06:09 multi-user.target.wants
~~~

### 模块解释
[Unit]区块：启动顺序与依赖关系
#### 服务描述：

- Description：给出当前服务的简单描述
- Documentation：给出文档位置

#### 启动顺序：

- After：定义xxx.service应该在哪些target或service服务之后启动
- Before：定义xxx.service应该在哪些target或service服务之前启动
#### 依赖关系：

- Wants：表示xxx.service与定义的服务存在“弱依赖”关系，即指定的服务启动失败或停止运行不影响xxx的允行
- Requires：则表示”强依赖”关系，即指定服务启动失败或异常退出，那么xxx也必须退出；反之xxx启动则指定服务也会启动

### [Service]区块：启动行为定义
#### 启动命令：
- EnvironmentFile：指定当前服务的环境参数文件(路径)，如EnviromentFile=-/etc/sysconfig/xxx，连词号表示抑制错误，即发生错误时，不影响其他命令的执行
- Environment：后面接多个不同的shell变量，如Environment=DATA_DIR=/dir/data
- User：设置服务运行的用户
- Group：设置服务运行的用户组
- WorkingDirectory：设置服务运行的路径
- Exec*：各种与执行相关的命令
    - ExecStart：定义启动服务时执行的命令
    - ExecStop：定义停止服务时执行的命令
    - ExecStartPre：定义启动服务前执行的命令
    - ExecStartPost：定义启动服务后执行的命令
    - ExecStopPost：定义停止服务后执行的命令
    - ExecReload：定义重启服务时执行的命令
#### 启动类型：
- Type：字段定义启动类型，可以设置的值如下
    - simple（默认值）：ExecStart字段启动的进程为主进程，即直接启动服务进程
    - forking：ExecStart字段将以fork()方式启动，此时父进程将会退出，子进程将成为主进程（例如用shell脚本启动服务进程）
    - oneshot：类似于simple，但只执行一次，Systemd 会等它执行完，才启动其他服务
    - dbus：类似于simple，但会等待 D-Bus 信号后启动
    - notify：类似于simple，启动结束后会发出通知信号，然后 Systemd 再启动其他服务
    - idle：类似于simple，但是要等到其他任务都执行完，才会启动该服务。一种使用场合是为让该服务的输出，不与其他服务的输出相混合
- RemainAfterExit：设为yes，表示进程退出以后，服务仍然保持执行
### 重启行为：

- KillMode：定义 Systemd 如何停止服务，可以设置的值如下
    - control-group（default）：当前控制组里面的所有子进程，都会被杀掉
    - process：只杀主进程
    - mixed：主进程将收到 SIGTERM 信号，子进程收到 SIGKILL 信号
    - none：没有进程会被杀掉，只是执行服务的 stop 命令
- Restart：定义了服务退出后，Systemd 的重启方式，可以设置的值如下（对于守护进程，推荐设为on-failure。对于那些允许发生错误退出的服务，可以设为on-abnormal）
    - no（default）：退出后不会重启
    - on-success：只有正常退出时（退出状态码为0），才会重启
    - on-failure：非正常退出时（退出状态码非0），包括被信号终止和超时，才会重启
    - on-abnormal：只有被信号终止和超时，才会重启
    - on-abort：只有在收到没有捕捉到的信号终止时，才会重启
    - on-watchdog：超时退出，才会重启
    - always：不管是什么退出原因，总是重启
    - RestartSec：表示 Systemd 重启服务之前，需要等待的秒数
- StandardOutput: 输出程序正常日志
- StandardError: 输出程序错误日志
    - file:/path/xx.log：以文件形式保存
### [Install]区块：服务安装定义
- WantedBy：表示该服务所在的 Target

Target的含义是服务组，如WantedBy=multi-user.target指的是该服务所属于multi-user.target。当执行systemctl enable xxx.service命令时，xxx.service的符号链接就会被创建在/etc/systemd/system/multi-user.target目录下。

可以通过systemctl get-default命令查看系统默认启动的target，一般为multi-user或者是graphical。因此配置好相应的WantedBy字段，可以实现服务的开机启动


### 推荐执行
- 如果是shell 启动 service->Type:forking
- 二进制启动 service->Type:simple

>[参考文档1](https://qgrain.github.io/2020/05/12/%E7%BC%96%E5%86%99systemd%E6%9C%8D%E5%8A%A1%E8%84%9A%E6%9C%AC/)

