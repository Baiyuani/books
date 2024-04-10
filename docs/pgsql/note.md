---
tags:
  - pgsql
  - postgresql
  - database
---

# Note

# 1. 常用命令

```shell
-- 登录数据库
psql -U postgres -d database_name -h serverhost
```


```postgresql
-- 列出数据库
\l

-- 列出tablespace
\db

-- 切换数据库
\c database_name

-- 列出当前数据库的所有表
\d

-- 列出所有用户
\du

-- 当前总共正在使用的连接数
select count(1) from pg_stat_activity;

-- 显示系统允许的最大连接数
show max_connections;

-- 创建数据库
CREATE DATABASE dbname

-- 删除数据库
DROP DATABASE dbname

-- 创建新账户
CREATE USER demo WITH PASSWORD 'xxxxxx';
  
-- 创建新数据库并将 OWNER 设置为新创建的帐户
CREATE DATABASE $dbname OWNER $username;

-- 将用户设置为数据库OWNER
ALTER DATABASE demo OWNER TO demo;

-- 给新用户授权
GRANT ALL PRIVILEGES ON DATABASE demo TO demo;

-- 导入文件
psql -U $username -h 10.116.147.14 -d $dbname -f public.sql
```

- 创建只读用户

```postgresql
-- 创建新账户
CREATE USER data_governance_analysis WITH PASSWORD 'qqqqq';

-- 给新用户授权只读模式
alter user data_governance_analysis set default_transaction_read_only=on;
-- 切换到库gra
\c gra
-- 赋权select权限
grant select on all tables in schema public to data_governance_analysis;
```

- 命令行导入sql文件

```shell
psql -d pias -U postgres -f /home/postgres/public.sql
```

- 导出数据

```shell
pg_dump -p 5432 -U postgres -d gravity -t t_corona_org  -f t_corona_org.sql
```

