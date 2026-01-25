---
title: "PgSQL数据库迁移记录"
date: 2026-01-25T21:17:16+08:00
description: "PGSQL在使用docker环境下面迁移出现的问题"
featured_image: "https://w.wallhaven.cc/full/qr/wallhaven-qrjmgl.jpg"
comment : true
hidden: false
draft: false
tags: ["SQL","PGSQL"]
Categories: "database"
---



## PostgreSQL 跨环境迁移故障修复手册

### 1. 故障现象与原因

* **现象**：容器启动不断重启，日志显示 `FATAL: could not open directory "pg_notify"` 或 `pg_replslot`。
* **根本原因**：
1. **目录缺失**：从群晖 (Synology) 或通过某些 GUI 工具拷贝时，空文件夹（如 `pg_notify`）可能被过滤掉。
2. **权限不匹配**：群晖 Docker 的 UID（通常是 1024）与标准 Postgres 镜像所需的 UID（999）不一致，导致容器无法读取数据。



---

### 2. 标准修复流程 (SSH 执行)

如果以后再次迁移，请在数据目录下执行以下“三步走”：

#### 第一步：补全系统子目录

PostgreSQL 启动时强制要求以下目录必须存在（即使是空的）：

```bash
mkdir -p pg_commit_ts pg_dynshmem pg_logical/mappings pg_logical/snapshots \
         pg_notify pg_replslot pg_serial pg_snapshots pg_stat pg_stat_tmp \
         pg_tblspc pg_twophase pg_wal/archive_status

```

#### 第二步：修正用户归属 (Owner)

PostgreSQL 官方镜像内部运行用户是 `postgres`，其 UID 固定为 `999`：

```bash
# 将当前目录及其下所有文件交给 UID 999 
sudo chown -R 999:999 .

```

#### 第三步：修正访问权限 (Permission)

Postgres 对安全极其敏感，数据目录权限必须设为 `700`（仅允许所有者读写）：

```bash
sudo chmod -R 700 .

```

---

### 3. 推荐的 `compose.yaml` 配置

为了路径清晰，建议采用以下结构映射：

```yaml
services:
  db:
    image: postgres:18
    container_name: pgsql
    restart: always
    environment:
      - POSTGRES_USER=pgsql
      - POSTGRES_PASSWORD=pgsql
      - POSTGRES_DB=pgsql
      - PGDATA=/var/lib/postgresql/data/pgdata # 指定数据子目录
    volumes:
      - ./docker:/var/lib/postgresql/data/pgdata # 宿主机目录 : 容器路径
    ports:
      - "6432:5432" # 仅映射 TCP 即可

```

---

### 4. 迁移小贴士

* **打包备份**：在原环境迁移前，建议使用 `tar -zcvf backup.tar.gz [目录名]` 打包，这样可以完整保留空目录和权限信息。
* **版本匹配**：确保新旧环境的 `PG_VERSION` 一致。
* **网络检查**：如果使用了自定义子网（如 `172.x.x.x`），确保不与 NAS 所在物理局域网段冲突。

---

