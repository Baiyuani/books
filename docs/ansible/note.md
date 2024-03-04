---
tags:
  - automation
  - ansible
  - deployment
status: new
---

# Note

**重点**

## debug

```yaml
- name: 查看状态
  shell: docker info
  register: docker 
- debug: var=docker.stdout_lines
```


## 修改主机密码


**密码不能以明文传递，执行前需要加密！**

```shell
ansible all -m user -a "name=ubuntu shell=/bin/bash password=dify6S5vIW44 update_password=always"
```

## shell

```shell
ansible all -m shell -a 'echo Hello'

ansible -i inventory/localhost-inventory.ini all -m shell -a 'grep -q www.dachui.com /etc/hosts || echo "192.168.182.21 www.dachui.com" >> /etc/hosts; cat /etc/hosts'

sed -i "/www.dachui.com/a 192.168.182.21 www.dachui.com" /etc/hosts || echo "192.168.182.21 www.dachui.com" >> /etc/hosts;cat /etc/hosts
ansible -i inventory/localhost-inventory.ini all -m shell -a 'sed -i "/www.dachui.com/c 192.168.182.21 www.dachui.com" /etc/hosts || echo "192.168.182.21 www.dachui.com" >> /etc/hosts;cat /etc/hosts'
```



## script

```shell
ansible all -m script -a "run.sh"
```

## hosts 

> 20240131 从k8s-playbooks的hosts.j2中移除，

```shell
{% for host in groups['all'] %}
{{ hostvars[host].ip | default(hostvars[host].ansible_default_ipv4.address) }} {{ hostvars[host].ansible_hostname }}
{% endfor %}
```
