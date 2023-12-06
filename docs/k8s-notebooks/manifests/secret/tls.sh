#!/bin/bash

#创建ingress使用https所需的secret
kubectl create secret tls NAME -n NAMESPACE \
--cert xx.cer \
--key xx.key