
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
