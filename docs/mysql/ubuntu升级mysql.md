# ubuntu 14.04 mysql5.5 升级 mysql5.7

### 升级前检查，有错误需先解决

```shell
mysqlcheck -u root -p --all-databases --check-upgrade
```

### 升级操作系统到ubuntu16.04，mysql会跟随apt源升级，注意升级前备份数据，备份数据库配置文件

- 可选修改软件源 https://mirrors.tuna.tsinghua.edu.cn/help/ubuntu/

- 执行升级

```shell
apt update
apt dist-upgrade

reboot

# 中间提示是否重启服务选yes
do-release-upgrade

# 验证
lsb_release -a 
```


# ubuntu 16.04 mysql5.7 升级 mysql8.0

### 升级前检查，有错误需先解决

```shell
mysqlcheck -u root -p --all-databases --check-upgrade
```

### 备份数据，备份数据库配置文件

### 添加mysql8.0软件源

> [官方地址](https://dev.mysql.com/downloads/repo/apt/)(或者按下面命令执行)

- 配置apt源

```shell
wget https://dev.mysql.com/get/mysql-apt-config_0.8.30-1_all.deb

# 安装过程中有两次提示，假如需要选择操作系统，可以随意选一个ubuntu。第二个直接选OK
dpkg -i mysql-apt-config_0.8.30-1_all.deb
```

- ubuntu16.04还需要手工修改

```shell
# 修改文件中的发行版名称为ubuntu16.04的xenial，修改版本为8.0
vim /etc/apt/sources.list.d/mysql.list
```

- 修改后

```txt
### THIS FILE IS AUTOMATICALLY CONFIGURED ###
# You may comment out entries below, but any other modifications may be lost.
# Use command 'dpkg-reconfigure mysql-apt-config' as root for modifications.
deb [signed-by=/usr/share/keyrings/mysql-apt-config.gpg] http://repo.mysql.com/apt/ubuntu/ xenial mysql-apt-config
deb [signed-by=/usr/share/keyrings/mysql-apt-config.gpg] http://repo.mysql.com/apt/ubuntu/ xenial mysql-8.0
deb [signed-by=/usr/share/keyrings/mysql-apt-config.gpg] http://repo.mysql.com/apt/ubuntu/ xenial mysql-tools
#deb [signed-by=/usr/share/keyrings/mysql-apt-config.gpg] http://repo.mysql.com/apt/ubuntu/ xenial mysql-tools-preview
deb-src [signed-by=/usr/share/keyrings/mysql-apt-config.gpg] http://repo.mysql.com/apt/ubuntu/ xenial mysql-8.0
```

- 卸载老的mysql5.7

```shell
apt remove mysql-server
apt autoremove
```

- 安装mysql8.0

```shell
apt install mysql-server
```

- 登录数据库测试

- 测试应用程序

如果发现有问题，可以卸载mysql8.0，在安装前清空数据目录，安装后，再使用备份的sql文件导入数据
