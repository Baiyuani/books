# 1.授权
```sql
create database `sys` character set 'utf8mb4' collate 'utf8mb4_general_ci';
    
-- create user dashboard@'%' identified by '';
grant all privileges on `sys`.* to  sys@'%' identified by '';
flush privileges;
    
use 
source 
```



# 2.[mysql查看某库表大小](https://www.cnblogs.com/nmap/p/6714142.html)

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



# 3. 主从异常处理方法

https://database.51cto.com/art/202011/632010.htm


# 4. 查看非sleep进程

select * from information_schema.`PROCESSLIST` p where p.COMMAND != "sleep" ORDER BY p.TIME DESC;


# 5. 后台执行命令

nohup mysql -usa -pabcd1234 -e 'source /db.sql' &
nohup mysql -uroot -p1qaz@WSX -h192.168.1.11 -P32614 -e 'ALTER TABLE `dj1910`.`polls_choice` add INDEX choice_text(`choice_text`)' >/dev/null 2>& 1 &


# 6. mysql:Prepared statement needs to be re-prepared解决办法
https://blog.csdn.net/haibo0668/article/details/81262323



# 7. 备份

```sql
# 排除一些库
mysql -uroot -p'P@ssw0rd01!' -h192.171.225.227 -N -e "show databases;"|grep -Ev "information_schema|performance_schema|sys|mysql"|xargs mysqldump -uroot -p'P@ssw0rd01!' -h192.171.225.227 --databases > yewu-20220928.sql


```

