
## 卸载win11左下角

```shell
winget uninstall MicrosoftWindows.Client.WebExperience_cw5n1h2txyewy
```


## windows网络转发netsh

```shell
# 查看已配置的所有转发
netsh interface portproxy show all

# 添加转发，listen地址+端口转发到connect地址+端口
netsh interface portproxy add v6tov4 listenport=80 listenaddress=2409:8a1e:70c2:4af0:41a1:144c:88aa:2441 connectaddress=192.168.182.50 connectport=80
netsh interface portproxy add v6tov4 listenport=443 listenaddress=2409:8a1e:70c2:4af0:41a1:144c:88aa:2441 connectaddress=192.168.182.50 connectport=443

# 查看刚才配置的转发
netsh interface portproxy show v6tov4

# 查看本机监听端口，过滤
netstat -ano | findstr ":80"

# 删除上面的配置
netsh interface portproxy delete v6tov4 listenport=80 listenaddress=2409:8a1e:70c2:4af0:41a1:144c:88aa:2441
```