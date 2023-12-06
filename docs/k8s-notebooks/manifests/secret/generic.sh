#!/bin/bash

kubectl create secret generic NAME -n NAMESPACE \
--from-literal=username=dc \
--from-literal=password=qweasd123

