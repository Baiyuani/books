

```dockerfile
FROM ...

...

# 使用shell脚本作为容器运行命令时，主程序应使用exec执行
RUN ["/bin/bash", "-c", "/src/run.sh"] 
```

```shell
# run.sh
#!/bin/bash
...

# 使用exec 执行命令，使该命令继承当前bash环境和PID等。老的bash将退出，同时exec语句之后的代码也不会被执行
# 这个方法可以使exec执行的守护进程在容器中作为主进程运行，即PID=1
# 使程序可以正常接收信号
exec mysqld
```

