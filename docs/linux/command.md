---
tags:
  - shell
  - linux
  - cli
---

# 常用命令

## tcpdump

```shell
tcpdump -e -vvv
tcpdump -e -vvv -w a.cap
tcpdump -e -vvv host IP port PORT 
tcpdump -i eht0
```

## 检测域名证书信息

```shell
# 非sni
openssl s_client -connect 域名:443 
# sni
openssl s_client -connect authserver.jssvc.edu.cn:443 -servername authserver.jssvc.edu.cn

openssl x509 -in <证书请求文件> -noout -dates
```

## centos防火墙配置：iptables

```shell
# 查看iptables规则，默认查看filter表
iptables -nL

# 查看nat表规则
iptables -t nat -nL

# 可以列出序列号，在插入或者删除的时候就不用自己去数了
iptables -nL --line-numbers 

# 可以查看到包过滤的流量统计，访问次数等
iptables -nvL --line-numbers

# 插入一条规则，默认在第一条插入
iptables -I INPUT -s 192.168.1.0/24 -j ACCEPT

# 在指定位置插入
iptables -I INPUT 2 -s 192.168.2.0/24 -p tcp --sport 45612 -j ACCEPT

# 在INPUT最后追加一条记录。
iptables -A INPUT -s 192.168.2.0/24 -j ACCEPT

# 删除第7条记录
iptables -D INPUT 7

# 替换一条规则
iptables -R INPUT 3 -s 192.168.3.0/24 -p tcp --dport 80 -j ACCEPT

# 指定协议
iptables -I INPUT -p icmp -j ACCEPT

# 针对端口开放（需要指明协议）
iptables -I INPUT -p tcp --dport 22 -j ACCEPT

# 拒绝所有，需要放到最后一条
iptables -A INPUT -j DROP

# 修改FORWARD链的默认策略设置为DROP
iptables -t filter -P FORWARD DROP   #-t指定所要操作的表，如果没有指定，则默认的表为filter.

# 允许访问公网
iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT

# 清空当前规则
iptables -F

# 保存规则
iptables-save > /etc/sysconfig/iptables

# 从文件里面恢复iptables规则
iptables-restore < /etc/sysconfig/iptables

# 设置永久生效
# 需要安装iptables-services并设置开机自启，后续服务器重启时会自动读取/etc/sysconfig/iptables中的规则配置
systemctl stop firewalld
systemctl disable firewalld
yum install iptables-services
systemctl enable iptables.service
iptables-save > /etc/sysconfig/iptables
```

## centos防火墙配置：firewalld-cmd

```shell
#查看当前所有规则
firewall-cmd --list-all

#单独查看端口白名单列表
firewall-cmd --zone=public --list-ports

# 新建永久规则，开放192.168.1.1单个源IP的访问
firewall-cmd --permanent --zone=trusted --add-source=192.168.1.1

# 新建永久规则，开放192.168.1.0/24整个源IP段的访问
firewall-cmd --permanent --add-source=192.168.1.0/24

# 移除上述规则
firewall-cmd --permanent --remove-source=192.168.1.1

# 针对ip开放端口
firewall-cmd --permanent --add-rich-rule="rule family="ipv4" source address="10.64.132.10" port protocol="tcp" port="3306" accept"

# 开放http服务和https服务
firewall-cmd --permanent --add-service=http
firewall-cmd --permanent --add-service=https

# 移除上述规则
firewall-cmd --permanent --remove-service=http

#重新加载firewall
firewall-cmd --reload

#重启firewalld
systemctl restart firewalld


# 开启防火墙后keepalived脑裂
firewall-cmd --direct --permanent --add-rule ipv4 filter INPUT 0 --in-interface eth0 --destination 224.0.0.18 --protocol vrrp -j ACCEPT
firewall-cmd --reload
systemctl restart keepalived
```

## ubunut防火墙配置：ufw

```shell
# k8s节点防火墙配置参考
# 所有节点之间互相不限制，集群pod和svc CIDR不限制，node节点允许所有来源访问本机80和443，其他端口根据实际情况放通
ufw enable
ufw allow http
ufw allow https
ufw allow from 192.168.3.212
ufw allow from 192.168.3.213
ufw allow from 192.168.3.214
ufw allow from 192.168.3.215
ufw allow from 192.168.3.216
ufw allow from 192.168.3.217
ufw allow from 192.168.3.218
ufw allow from 192.168.3.219
ufw allow from 100.64.0.0/16 to 100.65.0.0/16
ufw allow from 192.168.3.219 to 192.168.3.218 port 3306 proto tcp
ufw allow from 192.168.3.219 to 192.168.3.219 port 3306 proto tcp
```

```shell
# 整个环境所有服务器
ufw allow 1723
ufw allow from 192.168.103.125
ufw allow from 192.168.103.126
ufw allow from 192.168.103.127
ufw allow from 192.168.103.128
ufw allow from 192.168.103.129
ufw allow from 192.168.103.130
ufw allow from 192.168.103.171
ufw allow from 192.168.103.173
ufw allow from 192.168.103.177
ufw allow from 192.168.103.178
ufw allow from 192.168.103.179

# node
ufw allow http
ufw allow https

# k8s所有节点
ufw allow from 10.95.0.0/16 to 10.96.0.0/16
ufw allow from 10.96.0.0/16 to 10.95.0.0/16


# 主库
ufw allow from 192.168.103.16 to 192.168.103.177 port 3306 proto tcp

# 从库
ufw allow from 192.168.103.156 to 192.168.103.178 port 3306 proto tcp
ufw allow from 192.168.103.113 to 192.168.103.178 port 3306 proto tcp
ufw allow from 192.168.103.234 to 192.168.103.178 port 3306 proto tcp
ufw allow from 192.168.103.114 to 192.168.103.178 port 3306 proto tcp
ufw allow from 192.168.103.116 to 192.168.103.178 port 3306 proto tcp
ufw allow from 192.168.103.90 to 192.168.103.178 port 3306 proto tcp


ufw enable
```

## 强制刷新arp

```shell
# 20230508 腾讯云HAVIP使用keepalived配置后，其他服务器无法学习到vip的MAC，可以在vip所在服务器使用该命令处理
arping -c 10 -U 172.17.1.119 -I eth0
```

## ssh隧道

```shell
# https://www.im050.com/posts/415
nohup ssh -D 0.0.0.0:1337 -f -C -q -N zhdong@gpt.ketanyun.com &
```

## ab

ab是apachebench命令的缩写。

ab的原理：ab命令会创建多个并发访问线程，模拟多个访问者同时对某一URL地址进行访问。它的测试目标是基于URL的，因此，它既可以用来测试apache的负载压力，也可以测试nginx、lighthttp、tomcat、IIS等其它Web服务器的压力。

其中-n代表每次并发量，-c代表总共发送的数量

`ab -n 300 -c 300 http://192.168.0.10/`
（-n发出300个请求，-c模拟300并发，相当800人同时访问，后面是测试url）

`ab -t 60 -c 100 http://192.168.0.10/`
在60秒内发请求，一次100个请求。

```
Document Path:          /  ###请求的资源
Document Length:        50679 bytes  ###文档返回的长度，不包括相应头

Concurrency Level:      3000   ###并发个数
Time taken for tests:   30.449 seconds   ###总请求时间
Complete requests:      3000     ###总请求数
Failed requests:        0     ###失败的请求数
Write errors:           0
Total transferred:      152745000 bytes
HTML transferred:       152037000 bytes
Requests per second:    98.52 [#/sec] (mean)      ###平均每秒的请求数
Time per request:       30449.217 [ms] (mean)     ###平均每个请求消耗的时间
Time per request:       10.150 [ms] (mean, across all concurrent requests)  ###上面的请求除以并发数
Transfer rate:          4898.81 [Kbytes/sec] received   ###传输速率
```

## nc

```shell
apt install netcat -y


```

```shell
# 创建TCP服务器
## -l 监听地址 端口
nc -l 127.0.0.1 8080

# 客户端以TCP协议连接到服务端
nc 127.0.0.1 8080
```

- 测试udp端口

```shell
# netcat 测试udp端口
## -v 详细信息
## -u udp
nc -vu 114.114.114.114 53
```

- 传输文件

```shell
# 源服务器
cat file | nc -l 1234

# 目标服务器
nc host_ip 1234 > file
```
