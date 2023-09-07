---
title: "linux权限快速了解"
date: 2023-08-07T15:16:10+08:00
draft: false
description: "linux权限快速了解"
featured_image: "https://w.wallhaven.cc/full/l8/wallhaven-l83o92.jpg"
comment : true
hidden: false
tags: ["linux"]
Categories: "linux"
---

## linux权限

### 文件权限
基本的权限表示
![权限](/linux/permissions.jpg)

文件类型分几种：
- `-` 则表示文件 
- `l` 则表示链接文件，
- `b` 则表示设备文件中的可随机存取设备，
- `c` 则表示为设备文件中的一次性读取设备(键盘、鼠标)。

### 改变系统权限和属性
我们现在知道文件权限对于一个系统安全的重要性了，现在就要聊一聊如何修改文件权限了。常用的修改文件权限的指令有
- chgrp ：改变文件所属群组
- chown：改变文件所有者
- chmod：改变文件权限

#### chgrp
chgrp 就是 change group 的缩写，我觉得李纳斯把缩写用到了极致，这也许是我们现在对于缩写这么流行的原因。chgrp 能够改变文件群组，不过，要改变群组的话，要被改变的群组名称要在 /etc/group 文件内存在才行，否则就会显示错误。

#### chown
既然 chgrp 能够改变文件群组，那么 chown 能够改变文件所有者，同样也需要注意的是，文件所有者必须是系统中存在的账号，也就是在 /etc/passwd 这个文件中有记录的使用者名称才可改变。除此之外，chown 还可以直接修改群组名称。

语法:
> chown [可选项] user[:group] file...
~~~bash
使用权限：root
 
说明：
[可选项] : 同上文chmod
user : 新的文件拥有者的使用者 
group : 新的文件拥有者的使用者群体(group)
~~~

示例:
- 置文件 d.key、e.scrt的拥有者设为 users 群体的 ubuntu
~~~bash
chown ubuntu:users file d.key e.scrt
~~~
- 设置当前目录下与子目录下的所有文件的拥有者为 users 群体的 James
~~~bash
chown -R James:users  *
~~~



#### chmod
变更文件权限使用的是 chmod 这个指令，但是，权限的设置有两种方式，可以分别使用数字或者符号进行权限变更。

使用数组修改权限
如：
- rwx = 4 + 2 + 1 = 7
- rw = 4 + 2 = 6
- rx = 4 +1 = 5

即:

- 若要同时设置 rwx (可读写运行） 权限则将该权限位 设置 为 4 + 2 + 1 = 7
- 若要同时设置 rw-（可读写不可运行）权限则将该权限位 设置 为 4 + 2 = 6
- 若要同时设置 r-x（可读可运行不可写）权限则将该权限位 设置 为 4 +1 = 5

上面我们提到，每个文件都可以针对三个粒度，设置不同的rwx(读写执行)权限。即我们可以用用三个8进制数字分别表示 拥有者 、群组 、其它组( u、 g 、o)的权限详情，并用chmod直接加三个8进制数字的方式直接改变文件权限。语法格式为 ：
>chmod \<ugo> file...
~~~bash
其中
u,g,o各为一个数字，分别代表User、Group、及Other的权限。
相当于简化版的
chmod u=权限,g=权限,o=权限 file...
而此处的权限将用8进制的数字来表示User、Group、及Other的读、写、执行权限
~~~

示例:

- 设置所有人可以读写及执行
~~~bash
chmod 777 file  (等价于  chmod u=rwx,g=rwx,o=rwx file 或  chmod a=rwx file)
~~~

- 设置拥有者可读写，其他人不可读写执行
~~~bash
chmod 600 file (等价于  chmod u=rw,g=---,o=--- file 或 chmod u=rw,go-rwx file )
~~~

>参考文章: https://blog.csdn.net/u013197629/article/details/73608613