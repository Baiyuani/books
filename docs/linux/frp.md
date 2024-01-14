---
tags:
  - network
  - frp
---

# 内网穿透

## [安装](https://gofrp.org/zh-cn/docs/setup/)

[Release](https://gofrp.org/zh-cn/docs/setup/)

- 具备公网IP的服务器安装

```shell
tar -xf frp_0.53.2_linux_amd64.tar.gz
cd frp_0.53.2_linux_amd64/

sudo cp frps /usr/local/bin/
sudo mkdir /etc/frp
#sudo cp frps.toml /etc/frp

sudo tee /etc/frp/frps.toml << 'EOF'
bindPort = 7000
#vhostHTTPPort = 80
#vhostHTTPSPort = 443
EOF

sudo tee /etc/systemd/system/frps.service << 'EOF'
[Unit]
# 服务名称，可自定义
Description = frp server
After = network.target syslog.target
Wants = network.target

[Service]
Type = simple
# 启动frps的命令，需修改为您的frps的安装路径
ExecStart = /usr/local/bin/frps -c /etc/frp/frps.toml

[Install]
WantedBy = multi-user.target
EOF
```

- 内网的服务器安装

```shell
tar -xf frp_0.53.2_linux_amd64.tar.gz
cd frp_0.53.2_linux_amd64/

sudo cp frpc /usr/local/bin/
sudo mkdir /etc/frp
#sudo cp frpc.toml /etc/frp

sudo tee /etc/frp/frpc.toml << 'EOF'
serverAddr = "x.x.x.x"
serverPort = 7000

[[proxies]]
name = "https"
type = "tcp"
localIP = "127.0.0.1"
localPort = 443
remotePort = 443
[[proxies]]
name = "http"
type = "tcp"
localIP = "127.0.0.1"
localPort = 80
remotePort = 80
EOF

sudo tee /etc/systemd/system/frpc.service << 'EOF'
[Unit]
# 服务名称，可自定义
Description = frp client
After = network.target syslog.target
Wants = network.target

[Service]
Type = simple
# 启动frps的命令，需修改为您的frps的安装路径
ExecStart = /usr/local/bin/frpc -c /etc/frp/frpc.toml

[Install]
WantedBy = multi-user.target
EOF
```

```shell
# 启动frp
sudo systemctl start frps
# 停止frp
sudo systemctl stop frps
# 重启frp
sudo systemctl restart frps
# 查看frp状态
sudo systemctl status frps

sudo systemctl enable frps --now
sudo systemctl enable frpc --now
```

