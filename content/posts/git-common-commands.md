---
title: "git常用的指令"
date: 2023-04-10T16:25:30+08:00
description: "git常用的指令"
featured_image: "https://w.wallhaven.cc/full/85/wallhaven-853jeo.jpg"
comment : true
hidden: false
draft: false
tags: ["git"]
Categories: "git"
---

## 更新子仓库
```bash
git submodule update --init --recursive
```

- git init 用于初始化本地仓库
- git add . 添加本地仓库的所有文件
- git commit -m ‘commit message’ 保存你对这些文件所做的更改

![](https://www.freecodecamp.org/news/content/images/2022/09/ss1-2.png)

要推送 main 仓库，你首先必须通过运行 `git remote add <url>` 将远程服务器添加到 Git。

要确认已添加远程，请运行 `git remote -v `

[![]()](https://www.freecodecamp.org/news/content/images/2022/09/ss2-2.png)

推送到远程分支
1. 推送当前分支 `git push`

2. 创建新的分支,推送并远程仓库产生新的分支 
    
    1. 先运行 `git branch branch-name` 创建新分支。  运行 `git switch branch-name`  或 `git checkout branch-name` 切到新建分支运行。
    或者 使用 `git checkout -b branch-name` 创建并切到当前分支。
    2. 要将分支推送到远程服务器，请运行 `git push –u origin`。就我而言，该分支的名称是 `bug-fixes`，所以，我需要运行 `git push -u origin bug-`fixes`
    ![](https://www.freecodecamp.org/news/content/images/2022/09/ss4-2.png)
    3. 成功远程新建分支
    
    - ![](https://www.freecodecamp.org/news/content/images/2022/09/ss5-2.png)

> 原文地址: https://www.freecodecamp.org/chinese/news/git-push-local-branch-to-remote-how-to-publish-a-new-branch-in-git/
