---
title: "arch 安装教程"
date: 2023-07-17T09:09:15+08:00
description: "archLinux 安装教程"
featured_image: "https://w.wallhaven.cc/full/g7/wallhaven-g72k6d.png"
comment : false
hidden: false
draft: false
tags: ["arch","linux"]
Categories: "linux"
---

# archLinux 安装教程
- [Arch网站](https://www.archlinuxcn.org/)
- [iso下载](https://mirrors.163.com/archlinux/iso/) 建议下载最新版本
- [Arch安装指南](https://wiki.archlinuxcn.org/wiki/%E5%AE%89%E8%A3%85%E6%8C%87%E5%8D%97)


## 坑
~~~sh
failed to install packages to new root  报错
~~~

1. [grub](https://wiki.archlinuxcn.org/wiki/GRUB)
   `esp` boot 目录 /boot
   ~~~shell
   grub-install --target=x86_64-efi --efi-directory=esp --bootloader-id=GRUB
   ~~~

## 桌面安装
窗口图形系统有两种选择——Xorg和Wayland。
虽然可以使用 Wayland 启动 KDE Plasma，但仍存在一些缺失的功能和已知问题。建议使用 Xorg 以获得最完整和稳定的体验。
执行下面命令安装 Xorg 的一些组件
[xorg](https://wiki.archlinuxcn.org/wiki/Xorg)

~~~bash
pacman -S xorg 

~~~


~~~bash
pacman -S kde-applications
~~~
[kde应用](https://apps.kde.org/zh-cn/)

登陆管理器

~~~bash
pacman -S sddm
sudo systemctl enable sddm 
sudo systemctl start sddm 
~~~

安装火狐
~~~bash
 pacman -S firefox 
~~~