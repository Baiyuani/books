# Note

## 配置静态IP

```bash
vim /etc/netplan/···.ymal
# This is the network config written by 'subiquity'
network:
  ethernets:
    ens33:
      dhcp4: true
    ens37:
      dhcp4: no
      addresses: [192.168.1.11/24]
      optional: true
#     gateway4: 192.168.0.1
      nameservers:
        addresses: [223.5.5.5,223.6.6.6]
  version: 2
  
  
netplan apply
```

## 忘记密码

https://blog.csdn.net/zhuwade/article/details/121853685



## 启用root登录

https://blog.csdn.net/qq_29537425/article/details/116146693


```shell
sudo passwd root

sudo vim /etc/ssh/sshd_config 

#Authentication
PermitRootLogin yes

PasswordAuthentication yes

sudo systemctl restart ssh
```


## dpkg（类似centos的rpm）
dpkg [参数]
常用参数：
-i	安装软件包
-r	删除软件包
-l	显示已安装软件包列表
-L	显示于软件包关联的文件
-c	显示软件包内文件列表


## 刷新磁盘

```shell
[root@IChen~]#ls /sys/class/scsi_host/
host0 host1 host2
[root@IChen~]#echo "---" > /sys/class/scsi_host/host0/scan 
-bash: echo: write error: Invalid argument
[root@IChen~]#echo "- - -" > /sys/class/scsi_host/host0/scan 
[root@IChen~]#echo "- - -" > /sys/class/scsi_host/host1/scan 
[root@IChen~]#echo "- - -" > /sys/class/scsi_host/host2/scan 
[root@IChen~]#fdisk -l


#!/bin/bash
cd /sys/class/scsi_host
for i in $(ls)
do
  echo "- - -" > /sys/class/scsi_host/$i/scan
done

```

## 更新服务器ca证书库

```shell
apt install ca-certificates --reinstall
```
