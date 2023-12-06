#!/bin/bash

namespace=default
username=baiyuani
password=qweasd123
server=registry.cn-shanghai.aliyuncs.com


kubectl create secret docker-registry docker-registry -n $namespace \
--docker-username=$username \
--docker-password=$password \
--docker-server=$server  \
--dry-run=client -o yaml | kubectl apply -f -

