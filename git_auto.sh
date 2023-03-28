#!/bin/bash

# 进入 Git 仓库的目录
cd /path/to/your/git/repo

# 获取远程仓库的更新
git remote update

# 检查当前分支与远程分支之间的差异
LOCAL=$(git rev-parse @)
REMOTE=$(git rev-parse @{u})
BASE=$(git merge-base @ @{u})

if [ $LOCAL = $REMOTE ]; then
    echo "仓库已是最新状态，无需拉取。"
elif [ $LOCAL = $BASE ]; then
    echo "检测到远程仓库有更新，正在拉取..."
    git pull
else
    echo "仓库存在分歧，无法自动拉取。"
fi

