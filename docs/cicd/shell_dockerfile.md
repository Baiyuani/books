---
tags:
  - shell
  - docker
  
---

# 使用shell脚本作为容器启动命令


```dockerfile
FROM ...

...

# 使用shell脚本作为容器运行命令时，主程序应使用exec执行
ENTRYPOINT ["docker-entrypoint.sh"] 
```

```shell
# docker-entrypoint.sh
#!/bin/bash
...

# 使用exec 执行命令，使该命令继承当前bash环境和PID等。老的bash将退出，同时exec语句之后的代码也不会被执行
# 这个方法可以使exec执行的守护进程在容器中作为主进程运行，即PID=1
# 使程序可以正常接收信号
exec "$@"
```

## other

```shell
#!/bin/bash -e
#------修改环境变量-------
CONTAINER_ALREADY_STARTED="CONTAINER_ALREADY_STARTED_PLACEHOLDER";
if [ ! -e $CONTAINER_ALREADY_STARTED ]; then
    touch $CONTAINER_ALREADY_STARTED;
    echo "-- First container startup --";
#    cat /usr/share/nginx/html/note/index.html;
    # YOUR_JUST_ONCE_LOGIC_HERE
    echo "-- BUS_URL= $BUS_URL --";
    sed -i   "s#BUS_URL#$BUS_URL#"  /usr/share/nginx/html/note/index.html;
    echo "-- OAUTH_AUTHORITY_URL= $OAUTH_AUTHORITY_URL --";
    sed -i   "s#OAUTH_AUTHORITY_URL#$OAUTH_AUTHORITY_URL#"  /usr/share/nginx/html/note/index.html;
    echo "-- OAUTH_CLIENT_ID= $OAUTH_CLIENT_ID --";
    sed -i   "s#OAUTH_CLIENT_ID#$OAUTH_CLIENT_ID#"  /usr/share/nginx/html/note/index.html;
    echo "-- SSO_LOGOUT_URL= $SSO_LOGOUT_URL --";
    sed -i   "s#SSO_LOGOUT_URL#$SSO_LOGOUT_URL#"  /usr/share/nginx/html/note/index.html;
    echo "-- contextPath= $contextPath --";
    sed -i   "s#contextPath#$contextPath#"  /usr/share/nginx/html/note/index.html;

#cat /usr/share/nginx/html/note/index.html;
else
    echo "-- Not first container startup --"
fi

#------docker-entrypoint.sh 默认--------
for hook in $(ls /startup-hooks); do
  echo -n "Found startup hook ${hook} ... ";
  if [ -x "/startup-hooks/${hook}" ]; then
    echo "executing.";
    /startup-hooks/${hook};
  else
    echo 'not executable. Skipping.';
  fi
done

_quit () {
  echo 'Caught sigquit, sending SIGQUIT to child';
  kill -s QUIT $child;
}

trap _quit SIGQUIT;

echo 'Starting child (nginx)';
nginx -g 'daemon off;' &
child=$!;

echo 'Waiting on child...';
wait $child;
```
