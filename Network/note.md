## tcpdump

```shell
tcpdump -e -vvv
tcpdump -e -vvv -w a.cap
tcpdump -e -vvv host IP port PORT 
tcpdump -i eht0

```

## iptables

```shell
iptables -nvL
```


## 检测域名证书信息

```shell
openssl s_client -connect 域名:443 (非sni)

openssl s_client -connect authserver.jssvc.edu.cn:443 -servername authserver.jssvc.edu.cn(sni)

```