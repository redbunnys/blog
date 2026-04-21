---
title: "常用脚本"
date: 2025-05-07T16:07:00+08:00
tags: ["网络工具", "bash"]
categories: ["bash"]


featured_image: "https://w.wallhaven.cc/full/9d/wallhaven-9d3181.jpg"
description: "常用脚本"
comment : true
hidden: false
draft: false
---

```python
import os

# Define the content for the Markdown file
md_content = """# 常用 Linux 运维脚本合集：优化、转发与系统管理

在管理 Linux 服务器（尤其是 VPS）时，经常需要进行网络优化、端口转发和系统资源限制。本文整理了五个非常实用的自动化脚本，涵盖了从 IP 优先级调整到 SWAP 虚拟内存开启的常用操作。

---

## 1. 修改 IPv4 优先
在双栈（同时拥有 IPv4 和 IPv6）的服务器上，有时系统会默认优先使用 IPv6。如果 IPv6 路由较差或连接不稳定，可以使用此脚本将系统设置为 **IPv4 优先**。

**执行命令：**
```bash
bash <(curl -sL [https://www.zn.al/sh/ipv4.sh](https://www.zn.al/sh/ipv4.sh))
```

---

## 2. iptables 端口转发管理 (natcfg)
`natcfg` 是一个基于 `iptables` 的端口转发管理脚本。它可以帮助你快速设置流量转发，适用于简单的 NAT 中转场景。

**执行命令：**
```bash
bash <(curl -fsSL [https://www.zn.al/sh/natcfg.sh](https://www.zn.al/sh/natcfg.sh))
```
* **主要功能：** 添加转发规则、删除规则、查看当前转发列表。

---

## 3. realm 安装与管理脚本
`realm` 是一款用 Rust 编写的高性能中转工具，相比于传统的转发工具，它更加轻量且效率极高。此脚本支持一键安装、配置管理和更新。

**执行命令：**
```bash
bash <(curl -fsSL [https://www.zn.al/sh/realm.sh](https://www.zn.al/sh/realm.sh))
```
* **适用场景：** 需要低延迟、高吞吐量的流量中转。

---

## 4. journalctl 系统日志容量限制
Linux 系统日志（journalctl）如果不加限制，可能会占用数 GB 的磁盘空间。该脚本可以将日志大小限制为 **32MB**，有效释放磁盘压力。

**执行命令：**
```bash
bash <(curl -fsSL [https://www.zn.al/sh/rizhi.sh](https://www.zn.al/sh/rizhi.sh))
```
* **优化建议：** 建议在小硬盘 VPS 上首选执行。

---

## 5. 一键开启 SWAP 虚拟内存
对于内存较小（如 512MB 或 1GB）的服务器，开启 SWAP 可以防止因内存不足（OOM）导致的进程崩溃。该脚本支持自定义 SWAP 大小。

**执行命令：**
```bash
bash <(curl -fsSL [https://www.zn.al/sh/swap.sh](https://www.zn.al/sh/swap.sh))
```
* **功能：** 自动创建 swapfile、设置权限并启用挂载。

---

## 注意事项
1.  **权限要求：** 请确保以 `root` 用户运行上述所有脚本。
2.  **安全提醒：** 在执行任何远程脚本前，请确保你信任脚本来源。
3.  **系统兼容：** 这些脚本通常兼容主流的 Debian、Ubuntu 和 CentOS 发行版。

> 脚本来源：zn.al
"""

