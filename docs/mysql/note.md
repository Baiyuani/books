---
tags:
  - mysql
  - mariadb
  - database
---

# Note

## 1.授权
```sql
create database `sys` character set 'utf8mb4' collate 'utf8mb4_general_ci';
    
-- create user dashboard@'%' identified by '';
grant all privileges on `sys`.* to  sys@'%' identified by '';
flush privileges;
    
use 
source 
```



## 2.[mysql查看某库表大小](https://www.cnblogs.com/nmap/p/6714142.html)

**查询所有数据库占用磁盘空间大小**：

```sql
select TABLE_SCHEMA, concat(truncate(sum(data_length)/1024/1024,2),' MB') as data_size,
concat(truncate(sum(index_length)/1024/1024,2),'MB') as index_size
from information_schema.tables
group by TABLE_SCHEMA
order by data_length desc;
```

**查询单个库中所有表磁盘占用大小**：

```sql
-- 注意替换TestDB为数据库名
select TABLE_NAME, concat(truncate(data_length/1024/1024,2),' MB') as data_size,
concat(truncate(index_length/1024/1024,2),' MB') as index_size
from information_schema.tables where TABLE_SCHEMA = 'TestDB'
group by TABLE_NAME
order by data_length desc;
```



## 3. 主从异常处理方法

https://database.51cto.com/art/202011/632010.htm


## 4. 查看非sleep进程

select * from information_schema.`PROCESSLIST` p where p.COMMAND != "sleep" ORDER BY p.TIME DESC;


## 5. 后台执行命令

nohup mysql -usa -pabcd1234 -e 'source /db.sql' &
nohup mysql -uroot -p1qaz@WSX -h192.168.1.11 -P32614 -e 'ALTER TABLE `dj1910`.`polls_choice` add INDEX choice_text(`choice_text`)' >/dev/null 2>& 1 &


## 6. mysql:Prepared statement needs to be re-prepared解决办法
https://blog.csdn.net/haibo0668/article/details/81262323



## 7. 备份

```sql
# 排除一些库
mysql -uroot -p'P@ssw0rd01!' -h192.171.225.227 -N -e "show databases;"|grep -Ev "information_schema|performance_schema|mysql"|xargs mysqldump -uroot -p'P@ssw0rd01!' -h192.171.225.227 --databases > yewu-20220928.sql
```


## 8. 恢复
```shell
# 从备份sql中过滤
cat 2023-02-23_all.sql | sed -n '/INSERT INTO `ykpjgl` VALUES/p' > /tmp/xxx.sql
```



## 9. 修改用户密码


```shell
ALTER USER root@'%' IDENTIFIED BY 'xxxx';
```



## 10. 主从恢复
```sql
-- primary执行
show master status;

create user 'replicater1'@'%' identified by 'xxxx';

-- 仅MySQL，遇到报错时
ALTER USER 'replicater1'@'%' IDENTIFIED WITH mysql_native_password BY 'xxxx';
    
grant replication slave on *.* to 'replicater1'@'%';

-- secondary执行
stop slave;
reset slave;
change master to MASTER_HOST='10.81.40.146',MASTER_PORT=3306,MASTER_USER='replicater1',MASTER_PASSWORD='xxxx',MASTER_LOG_FILE='mysql_bin.000012',MASTER_LOG_POS=4112;
start slave;
show slave status \G


stop slave; 
set global sql_slave_skip_counter =1; 
start slave; 
show slave status \G

xtrabackup --defaults-file=/etc/my.cnf --backup --user=root --password=xxxx --target-dir=/mnt/full-$(date +%F-%H%M)
xtrabackup --prepare --target-dir=/home/infoplus/full-2023-07-06-0957
xtrabackup --defaults-file=/etc/my.cnf --copy-back --target-dir=/home/infoplus/full-2023-07-06-0957
```



### [mariadb-backup](https://mariadb.org/download/?t=repo-config&d=CentOS+7+%28x86_64%29&v=10.4&r_m=aliyun)热备和增量备份

> MariaDB基于percona xtrabackup开发了它自己的备份工具：MariaDB Backup。它基于xtrabackup开发，所以所用方法基本和xtrabackup相同，只是有些自己的特性。

```shell
apt install mariadb-backup

yum install MariaDB-backup
```

- [命令使用参考](https://www.modb.pro/db/11297)
[官方文档](https://mariadb.com/kb/en/mariabackup-options/)
```shell
mariabackup --defaults-file=/etc/my.cnf --backup  --user=backupuser  --password='tany' -S /tmp/mysql.sock --target-dir=/data/backup
#全量备份, 需要指定新目录，文件直接放在目录里，不像xtra那样自动新建以日期命名的目录；
mariabackup --defaults-file=/etc/my.cnf --backup  --user=backupuser  --password='tany' -S /tmp/mysql.sock --incremental-basedir=/data/backup/ --target-dir=/data/backup/backup2
#第一次增量备份；
mariabackup --defaults-file=/etc/my.cnf --backup  --user=backupuser  --password='tany' -S /tmp/mysql.sock --incremental-basedir=/data/backup/backup2/ --target-dir=/data/backup/backup3
#第二次增量备份；
service mysqld stop		#恢复前，停止mysql;
mv /data/mysql /data/mysql.bak	#清除原来数据文件；
cp -r /data/backup /data/backup.bak		#备份备份文件；
cd /data/backup
mv backup2 ../			#调整目录位置；
mv backup3 ../			#调整目录位置，备份时指定备份目录/data/backup*更方便；
```

- 备份和恢复案例
```shell
# 全量备份
mariabackup --defaults-file=/mnt/my.cnf --backup --user=root --password='1qaz@WSX' --host=172.19.205.0 --port=3306 --target-dir=/mnt/backup/full-$(date +%F-%H%M)
# 增量备份1
mariabackup --defaults-file=/mnt/my.cnf --backup --user=root --password='1qaz@WSX' --host=172.19.205.0 --port=3306 --incremental-basedir=/mnt/backup/full-$(date +%F-%H%M) --target-dir=/mnt/backup/backup1-$(date +%F-%H%M)
# 增量备份2
mariabackup --defaults-file=/mnt/my.cnf --backup --user=root --password='1qaz@WSX' --host=172.19.205.0 --port=3306 --incremental-basedir=/mnt/backup/backup1-$(date +%F-%H%M) --target-dir=/mnt/backup/backup2-$(date +%F-%H%M)


# 恢复准备
mariabackup --prepare --target-dir=/mnt/backup/full-$(date +%F-%H%M)
# 恢复准备1
mariabackup --prepare --target-dir=/mnt/backup/full-$(date +%F-%H%M) --incremental-dir=/mnt/backup/backup1-$(date +%F-%H%M)
# 恢复准备2
mariabackup --prepare --target-dir=/mnt/backup/full-$(date +%F-%H%M) --incremental-dir=/mnt/backup/backup2-$(date +%F-%H%M)
# 恢复停止数据库
systemctl stop mysqld

cd /var/lib/mysql
rm -rf *

mariabackup --copy-back --target-dir=/mnt/backup/full-$(date +%F-%H%M)

chown -R mysql:mysql /var/lib/mysql/

systemctl start mysqld
```



### 容器化mariadb如何使用mariabackup
> 将mariadb的数据目录挂载进执行备份的容器实现

```shell
# 必须在数据库存储目录所在节点运行
# extraVolumes[0].hostPath.path是数据库数据存储目录在节点上的路径
# extraVolumeMounts[0].mountPath必须是数据库变量datadir（show VARIABLES like 'datadir'）的值
# extraVolumes[1].hostPath.path是备份到主机上的这个目录
# extraVolumeMounts[1].mountPath是备份到这个目录
# extraVolumes[2].configMap.name是mariadb配置文件的cm
# 
helm upgrade --install mariabackup ./demo -n default \
--set nodeAffinityPreset.type='hard' \
--set nodeAffinityPreset.key='kubernetes.io/hostname' \
--set nodeAffinityPreset.values[0]='k8s-master1' \
--set lifecycleHooks.postStart.exec.command[0]='/bin/bash' \
--set lifecycleHooks.postStart.exec.command[1]='-c' \
--set lifecycleHooks.postStart.exec.command[2]='yum -y install MariaDB-backup || yum makecache && yum -y install MariaDB-backup' \
--set extraVolumes[0].hostPath.path='/data/kubernetes/default-data-mariadb-local-0-pvc-7616153b-00dc-421c-9c19-c9afc9db0dd6/data' \
--set extraVolumes[0].name='datadir' \
--set extraVolumeMounts[0].name='datadir' \
--set extraVolumeMounts[0].mountPath='/bitnami/mariadb/data/' \
--set extraVolumeMounts[0].readOnly='true' \
--set extraVolumes[1].hostPath.path='/opt/backup' \
--set extraVolumes[1].name='bakdir' \
--set extraVolumeMounts[1].name='bakdir' \
--set extraVolumeMounts[1].mountPath='/mnt/backup' \
--set extraVolumes[2].configMap.name='mariadb-local' \
--set extraVolumes[2].name='mariadb-config' \
--set extraVolumeMounts[2].name='mariadb-config' \
--set extraVolumeMounts[2].mountPath='/mnt/my.cnf' \
--set extraVolumeMounts[2].subPath='my.cnf'

# 待容器启动后登录容器执行
mariabackup --defaults-file=/mnt/my.cnf --backup --user=root --password='1qaz@WSX' --host=172.19.205.0 --port=3306 --target-dir=/mnt/backup/full-$(date +%F-%H%M)
# 执行完成后备份文件在/opt/backup
```


## 11. 压测


```shell
mysqlslap -h10.96.105.230 -uroot -p'1qaz@WSX' \
--concurrency=200 --iterations=10 --auto-generate-sql --auto-generate-sql-load-type=mixed \
--auto-generate-sql-add-autoincrement --engine=innodb --number-of-queries=150000 


mysqlslap  -h192.168.182.16 -uroot -p'1qaz@WSX' \
--concurrency=200 --iterations=10 --auto-generate-sql --auto-generate-sql-load-type=mixed \
--auto-generate-sql-add-autoincrement --engine=innodb --number-of-queries=150000 
```




```shell
# k8s nfs
root@k8s-node1:~# mysqlslap -h10.96.105.230 -uroot -p'1qaz@WSX' \
> --concurrency=200 --iterations=10 --auto-generate-sql --auto-generate-sql-load-type=mixed \
> --auto-generate-sql-add-autoincrement --engine=innodb --number-of-queries=150000 
Benchmark
        Running for engine innodb
        Average number of seconds to run all queries: 9.370 seconds
        Minimum number of seconds to run all queries: 8.559 seconds
        Maximum number of seconds to run all queries: 10.447 seconds
        Number of clients running queries: 200
        Average number of queries per client: 750

root@k8s-node1:~# mysqlslap -h10.96.105.230 -uroot -p'1qaz@WSX' --concurrency=200 --iterations=10 --auto-generate-sql --auto-generate-sql-load-type=mixed --auto-generate-sql-add-autoincrement --engine=innodb --number-of-queries=150000 
Benchmark
        Running for engine innodb
        Average number of seconds to run all queries: 9.204 seconds
        Minimum number of seconds to run all queries: 8.545 seconds
        Maximum number of seconds to run all queries: 10.759 seconds
        Number of clients running queries: 200
        Average number of queries per client: 750

root@k8s-node1:~# mysqlslap -h10.96.105.230 -uroot -p'1qaz@WSX' --concurrency=200 --iterations=10 --auto-generate-sql --auto-generate-sql-load-type=mixed --auto-generate-sql-add-autoincrement --engine=innodb --number-of-queries=150000 
Benchmark
        Running for engine innodb
        Average number of seconds to run all queries: 9.932 seconds
        Minimum number of seconds to run all queries: 8.094 seconds
        Maximum number of seconds to run all queries: 16.321 seconds
        Number of clients running queries: 200
        Average number of queries per client: 750

# k8s 主机存储
root@k8s-node1:~# mysqlslap -h10.96.250.214 -uroot -p'1qaz@WSX' \
> --concurrency=200 --iterations=10 --auto-generate-sql --auto-generate-sql-load-type=mixed \
> --auto-generate-sql-add-autoincrement --engine=innodb --number-of-queries=150000 
Benchmark
        Running for engine innodb
        Average number of seconds to run all queries: 7.098 seconds
        Minimum number of seconds to run all queries: 6.645 seconds
        Maximum number of seconds to run all queries: 8.038 seconds
        Number of clients running queries: 200
        Average number of queries per client: 750

root@k8s-node1:~# mysqlslap -h10.96.250.214 -uroot -p'1qaz@WSX' --concurrency=200 --iterations=10 --auto-generate-sql --auto-generate-sql-load-type=mixed --auto-generate-sql-add-autoincrement --engine=innodb --number-of-queries=150000 
Benchmark
        Running for engine innodb
        Average number of seconds to run all queries: 7.053 seconds
        Minimum number of seconds to run all queries: 6.571 seconds
        Maximum number of seconds to run all queries: 7.505 seconds
        Number of clients running queries: 200
        Average number of queries per client: 750

root@k8s-node1:~# mysqlslap -h10.96.250.214 -uroot -p'1qaz@WSX' --concurrency=200 --iterations=10 --auto-generate-sql --auto-generate-sql-load-type=mixed --auto-generate-sql-add-autoincrement --engine=innodb --number-of-queries=150000 
Benchmark
        Running for engine innodb
        Average number of seconds to run all queries: 6.695 seconds
        Minimum number of seconds to run all queries: 6.182 seconds
        Maximum number of seconds to run all queries: 7.050 seconds
        Number of clients running queries: 200
        Average number of queries per client: 750


# 虚拟化
root@k8s-node1:~# mysqlslap  -h192.168.182.16 -uroot -p'1qaz@WSX' \
> --concurrency=200 --iterations=10 --auto-generate-sql --auto-generate-sql-load-type=mixed \
> --auto-generate-sql-add-autoincrement --engine=innodb --number-of-queries=150000 
Benchmark
        Running for engine innodb
        Average number of seconds to run all queries: 5.742 seconds
        Minimum number of seconds to run all queries: 5.386 seconds
        Maximum number of seconds to run all queries: 6.781 seconds
        Number of clients running queries: 200
        Average number of queries per client: 750

root@k8s-node1:~# mysqlslap  -h192.168.182.16 -uroot -p'1qaz@WSX' --concurrency=200 --iterations=10 --auto-generate-sql --auto-generate-sql-load-type=mixed --auto-generate-sql-add-autoincrement --engine=innodb --number-of-queries=150000 
Benchmark
        Running for engine innodb
        Average number of seconds to run all queries: 5.741 seconds
        Minimum number of seconds to run all queries: 5.031 seconds
        Maximum number of seconds to run all queries: 6.400 seconds
        Number of clients running queries: 200
        Average number of queries per client: 750

root@k8s-node1:~# mysqlslap  -h192.168.182.16 -uroot -p'1qaz@WSX' --concurrency=200 --iterations=10 --auto-generate-sql --auto-generate-sql-load-type=mixed --auto-generate-sql-add-autoincrement --engine=innodb --number-of-queries=150000 
Benchmark
        Running for engine innodb
        Average number of seconds to run all queries: 5.594 seconds
        Minimum number of seconds to run all queries: 5.067 seconds
        Maximum number of seconds to run all queries: 6.030 seconds
        Number of clients running queries: 200
        Average number of queries per client: 750
```


