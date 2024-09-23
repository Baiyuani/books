# redis

## rdb 切换 aof

```shell
redis-cli

# 将当前数据写入rdb
> save 

# 动态开启aof，注意同时修改配置文件，防止重启后失效
> config set appendonly "yes"

# 将数据写入aof文件
> save

# 到数据目录确认文件大小，aof和rdb文件大小应大致相等
cd /data

# 重启redis验证
```
