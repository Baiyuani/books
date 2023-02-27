## 1.debug

- name: 查看状态
  shell: docker info
  register: docker 
- debug: var=docker.stdout_lines



## 修改主机密码
密码不能以明文传递，执行前需要加密！
#ansible all -m user -a "name=ubuntu shell=/bin/bash password=dify6S5vIW44 update_password=always"


## shell
```shell
ansible all -m shell -a 'echo Hello'
```