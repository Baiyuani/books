---
tags:
  - shell
  - linux
  - cli
---

## 设置系统代理 

```shell

sudo tee /etc/profile.d/custom_proxy.sh << 'EOF'
export no_proxy=127.0.0.1,192.168.*,172.31.*,172.30.*,172.29.*,172.28.*,172.27.*,172.26.*,172.25.*,172.24.*,172.23.*,172.22.*,172.21.*,172.20.*,172.19.*,172.18.*,172.17.*,172.16.*,10.*,127.*,localhost,$(awk -F[\#] '{print $1}' /etc/hosts | sed -r /^$/d | awk '{res=res$2","}END{print res}')
export NO_PROXY=127.0.0.1,192.168.*,172.31.*,172.30.*,172.29.*,172.28.*,172.27.*,172.26.*,172.25.*,172.24.*,172.23.*,172.22.*,172.21.*,172.20.*,172.19.*,172.18.*,172.17.*,172.16.*,10.*,127.*,localhost,$(awk -F[\#] '{print $1}' /etc/hosts | sed -r /^$/d | awk '{res=res$2","}END{print res}')
export HTTPS_PROXY=http://192.168.182.1:29998
export https_proxy=http://192.168.182.1:29998
export HTTP_PROXY=http://192.168.182.1:29998
export http_proxy=http://192.168.182.1:29998
EOF

```

## 切换中文及添加中文字体

```shell
# 查看系统语言
locale

# 如果系统语言不是“zh_CN.UTF-8”的话，则执行步骤2修改系统语言为“zh_CN.UTF-8”
# centos
vi  /etc/locale.conf
# ubuntu
vim /etc/default/locale

# 添加
export LC_ALL="zh_CN.UTF-8"

# 立即生效
source /etc/default/locale

# 再次查看
locale
```

```shell
# 从windows C盘字体目录C:\Windows\Fonts获取字体文件

# linux 服务器创建字体存放目录
mkdir -p /usr/share/fonts/truetype   

# 修改权限
chmod  -R  755  /usr/share/fonts/truetype

# 加载缓存
fc-cache
```

## 时间同步

#### centos6

```shell
vim /etc/ntp.conf

# 立即找服务器同步时间，危险操作！时间差异较大时直接同步可能会出问题
ntpd -gq

service ntpd start 
# 开机自启
chkconfig ntpd on 
```

#### centos7

```shell
vim /etc/chronyd.conf

#查看时间同步源：
chronyc sources -v

systemctl start chronyd

#立即手工同步,危险操作！时间差异较大时直接同步可能会出问题
chronyc -a makestep

systemctl enable chronyd
```

#### ubuntu 
```shell
vim /etc/chrony/chronyd.conf

#查看时间同步源：
chronyc sources -v

systemctl start chronyd

#立即手工同步,危险操作！时间差异较大时直接同步可能会出问题
chronyc -a makestep

systemctl enable chronyd
```

## rsync增量同步

- 使用rsync协议，同步服务端文件

```shell
~$ rsync rsync://mirrors.tuna.tsinghua.edu.cn/kubernetes

drwxr-xr-x              4 2020/03/02 10:28:26 .
drwxr-xr-x              4 2020/03/02 11:33:16 apt
drwxr-xr-x              3 2020/03/02 14:19:34 yum
```

```shell
RSYNC_OPTS="-aHvh --no-o --no-g --stats --exclude .~tmp~/ --delete --delete-excluded --delete-after --delay-updates --safe-links --timeout=120 --contimeout=120"
upstream="rsync://mirrors.tuna.tsinghua.edu.cn/kubernetes/"
dest="$DIR"

rsync ${RSYNC_OPTS} "$upstream" "$dest"
```
