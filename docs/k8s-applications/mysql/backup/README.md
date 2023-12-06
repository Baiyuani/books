## xtrabackup（仅mysql。mariadb需使用MariaDB Backup。）

> [下载](https://www.percona.com/downloads/ )

### 1.安装

```shell
tar -xf Percona-XtraBackup-2.4.26-r19de43b-focal-x86_64-bundle.tar
apt install libcurl4-openssl-dev libev4
dpkg -i percona-xtrabackup-24_2.4.26-1.focal_amd64.deb
```

### 2.[使用](https://blog.csdn.net/weixin_45157506/article/details/103834921)


| 常用选项                     | 含义                                        |
| ---------------------------- | ------------------------------------------- |
| --host                       | 主机名                                      |
| --user                       | 用户名                                      |
| --port                       | 端口号                                      |
| --password                   | 密码                                        |
| --databases                  | 数据库名                                    |
| --no-timestamp               | 不用日期命名存储备份文件的子目录名          |
| --redo-only                  | 日志合并                                    |
| --apply-log                  | 准备恢复数据                                |
| --copy-back                  | 拷贝数据                                    |
| --incremental 目录名         | 增量备份                                    |
| --incremental-basedir=目录名 | 增量备份时,指定上一次备份数据存储的目录名   |
| --incremental-dir=目录名     | 准备恢复数据时,指定增量备份数据存储的目录名 |
| --export                     | 导出表信息                                  |

```bash
--databases="库"
--databases="库1 库2"
--databases="库1.表"
```

### 3.场景参考

- 全量备份和恢复
```shell
#备份所有数据,不指定库时为备份所有
innobackupex --host 地址 --port 端口号 --user root --password PASSWORD --databases=库 目录 --no-timestamp  

#恢复:
#
#停止数据库服务
#清空数据目录下的数据
#准备恢复数据
#恢复数据
#修改数据目录下文件的所有者/组为mysql
#启动数据库服务
#管理员登录查看数据
systemctl stop mysqld   #关闭服务
rm -rf /var/lib/mysql/*  #清空数据
innobackupex --apply-log 备份文件路径  #准备恢复数据
innobackupex --copy-back 备份文件路径  #拷贝数据到数据库目录下
chown -R mysql:mysql /var/lib/mysql/*  #修改权限
```

- 增量备份和恢复

增量备份:
备份目录/xtrabackup_checkpoints文件:

- lsn:日志序列号


| backup_type   | 含义                     |
| ------------- | ------------------------ |
| full-backuped | 完全备份                 |
| incremental   | 增量备份                 |
| log-applied   | 已应用(已准备好恢复数据) |

应用实例:

周一:完全备份

```bash
innobackupex --user root --password PASSWORD /allbak --no-timestamp  #备份所有数据
cat /allbak/xtrabackup_checkpoints 
#lsn:日志序列号
backup_type = full-backuped
from_lsn = 0  	    #备份数据开始序列号
to_lsn = 2880259      #备份数据结尾序列号
last_lsn = 2880268      #增量备份时,使用此序列号与数据库目录下的ib_logfile进行比对,确定是否有新数据
compact = 0
recover_binlog_info = 0
```

周二:增量备份

```bash
innobackupex --user root --password PASSWORD --incremental /new1dir --incremental-basedir=/allbak --no-timestamp
cat /new1dir/xtrabackup_checkpoints 
backup_type = incremental
from_lsn = 2880259    #通过上一次备份的结尾确定这一次备份的开始
to_lsn = 2882360  
last_lsn = 2882369    #再次进行增量备份时,同样进行比对
compact = 0
recover_binlog_info = 0
```

周三:增量备份

```bash
innobackupex --user root --password PASSWORD --incremental /new2dir --incremental-basedir=/new1dir --no-timestamp
cat /new2dir/xtrabackup_checkpoints 
backup_type = incremental
from_lsn = 2882360
to_lsn = 2884453
last_lsn = 2884462
compact = 0
recover_binlog_info = 0

```

增量恢复:

1. 停止数据库服务
2. 清空数据库目录下内容
3. 准备恢复数据(合并日志)
4. 拷贝数据到数据库目录下
5. 修改文件所有者/组为mysql
6. 启动数据库服务

```bash
systemctl stop mysqld
rm -rf /var/lib/mysql/*
innobackupex --apply-log --redo-only /allbak  #合并日志
innobackupex --apply-log --redo-only /allbak --incremental-dir=/new1dir  #合并增量日志
innobackupex --apply-log --redo-only /allbak --incremental-dir=/new2dir  #合并增量日志
innobackupex --copy-back /allbak  #拷贝文件
chown -R mysql:mysql /var/lib/mysql/*
systemctl start mysqld
```

### 4.数据迁移方案

1. 从服务器安装mysql,启动服务完成初始化，然后stop服务，删除/var/lib/mysql/下的所有文件，为恢复数据做准备
2. 使用innobackupex工具备份所有数据，并记录当前的binlog日志名和偏移量

```bash
innobackupex  --user root --password PASSWORD  --slave-info  /allbak --no-timestamp  #使用--slave-info参数，备份所有数据，并记录备份数据对应的binlog日志名
```

3. 将备份文档发送到从服务器

```bash
scp -r /allbak root@slave:
```

4. 从服务器使用备份文件恢复数据
5. 启动服务
6. 查看备份文件中记录的binlog日志信息，配置主从`change master to `

```bash
] cat /root/allbak/xtrabackup_info  | grep master11   #master11为当前主服务器的binlog日志前缀
binlog_pos = filename 'master11.000001', position '7700'
```

7. stop从服务器的mysqld服务，卸载，安装pxc，启动pxc，此时该服务器依然为线上服务器的从服务器，数据保证了同步，继续配置其余pxc服务器即可
