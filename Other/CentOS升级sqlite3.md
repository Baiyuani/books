# CentOS升级sqllite3

- `＃获取源代码`

```shell
[root@localhost ~]# cd ~
[root@localhost ~]# wget https://www.sqlite.org/2020/sqlite-autoconf-3310100.tar.gz
[root@localhost ~]# tar xvf sqlite-autoconf-3310100.tar.gz
```

- `＃构建并安装`

```shell
[root@localhost ~]# cd sqlite-autoconf-3310100/
[root@localhost sqlite-autoconf-3310100]# ./configure --prefix=/usr/local
[root@localhost sqlite-autoconf-3270200]# ./configue && make && make install
[root@localhost ~]# find /usr/ -name sqlite3
/usr/bin/sqlite3
/usr/lib64/python2.7/sqlite3
/usr/local/bin/sqlite3
/usr/local/lib/python3.6/sqlite3
```

- `＃检查版本 最新安装的sqlite3版本`

```shell
[root@localhost ~]# /usr/local/bin/sqlite3 --version
3.31.1 2020-01-27 19:55:54 3bfa9cc97da10598521b342961df8f5f68c7388fa117345eeb516eaa837bb4d6
```

- `# sqlite3的版本是旧版本，需要更新。`

```shell
[root@localhost ~]# mv /usr/bin/sqlite3 /usr/bin/sqlite3_old
[root@localhost ~]# ln -s /usr/local/bin/sqlite3  /usr/bin/sqlite3
```

- `#查看当前全局sqlite3的版本`

```shell
[root@localhost ~]# sqlite3 --version
3.31.1 2020-01-27 19:55:54 3bfa9cc97da10598521b342961df8f5f68c7388fa117345eeb516eaa837bb4d6
```

- `#将路径传递给共享库 , 将下面的export语句写入~/.bashrc并source它`

```shell
export LD_LIBRARY_PATH="/usr/local/lib"
```

`＃检查Python的SQLite3版本`

```shell
[root@localhost ~]# python3
Python 3.6.7 (default, Jun 11 2020, 08:58:45) 
[GCC 4.8.5 20150623 (Red Hat 4.8.5-39)] on linux
Type "help", "copyright", "credits" or "license" for more information.
>>> import sqlite3
>>> sqlite3.sqlite_version
'3.31.1'
>>> 
```