## nginx.service

pidFile和nginx执行文件根据编译安装可能位于不同的目录

```shell
vim /lib/systemd/system/nginx.service
```

```ini
[Unit]
Description=The NGINX HTTP and reverse proxy server
After=syslog.target network-online.target remote-fs.target nss-lookup.target
Wants=network-online.target

[Service]
Restart=always
Type=forking
PIDFile=/usr/local/nginx/logs/nginx.pid
ExecStartPre=/usr/local/nginx/sbin/nginx -t
ExecStart=/usr/local/nginx/sbin/nginx
ExecReload=/usr/local/nginx/sbin/nginx -s reload
ExecStop=/bin/kill -s QUIT $MAINPID
PrivateTmp=true

[Install]
WantedBy=multi-user.target
```




```ini
[Unit]
Description=tunasync-manager
Documentation=https://github.com/tuna/tunasync/blob/master/docs/zh_CN/get_started.md
Wants=network-online.target
After=network-online.target

[Service]
ExecStartPre=/bin/mkdir -p /data/tunasync
ExecStartPre=/bin/chown mirrors:mirrors -R /data/tunasync
ExecStart=/usr/local/bin/tunasync manager --config /home/mirrors/tunasync_demo/conf/manager.conf
ExecStop=/bin/kill -s QUIT $MAINPID
User=mirrors
Group=mirrors

[Install]
WantedBy=multi-user.target
```

```ini
[Unit]
Description=tunasync-worker
Documentation=https://github.com/tuna/tunasync/blob/master/docs/zh_CN/get_started.md
Wants=network-online.target
After=network-online.target
After=tunasync-manager.service
Requires=tunasync-manager.service

[Service]
ExecStartPre=/bin/mkdir -p /data/tunasync_demo
ExecStartPre=/bin/mkdir -p /data/tunasync/log
ExecStartPre=/bin/chown mirrors:mirrors -R /data/tunasync_demo
ExecStartPre=/bin/chown mirrors:mirrors -R /data/tunasync/log
ExecStart=/usr/local/bin/tunasync worker --config /home/mirrors/tunasync_demo/conf/worker.conf
ExecReload=/usr/local/bin/tunasynctl reload -w test_worker
ExecStop=/bin/kill -s QUIT $MAINPID
User=mirrors
Group=mirrors

[Install]
WantedBy=multi-user.target
```



## registry.socket

`vim /lib/systemd/system/registry.socket`

```ini
[Unit]
Description=Distribution registry

[Socket]
ListenStream=5000

[Install]
WantedBy=sockets.target
```

`vim /lib/systemd/system/registry.service`

```ini
[Unit]
Description=Distribution registry
After=docker.service
Requires=docker.service

[Service]
#TimeoutStartSec=0
Restart=always
ExecStartPre=-/usr/bin/docker stop %N
ExecStartPre=-/usr/bin/docker rm %N
ExecStart=/usr/bin/docker run --name %N \
    -v /data/registry:/var/lib/registry \
    -p 5000:5000 \
    registry:2

[Install]
WantedBy=multi-user.target
```

