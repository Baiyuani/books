#!/bin/bash
 
VIP=$1
shift
SERVERS=$@
DEVICE=${DEVICE-"keepalived"}
COMMENT=${COMMENT-"keepalived"}
 
ip a s "${DEVICE}"
if [ "$?" -ne "0" ]; then
  ip link add "${DEVICE}" type dummy
fi
 
ip a s "${DEVICE}" | grep -w "inet" | grep "${VIP}"
if [ "$?" -ne "0" ]; then
  ip a add "${VIP}" dev "${DEVICE}"
fi
 
for s in ${SERVERS}; do
   iptables -t nat -C POSTROUTING -j MASQUERADE -d "${s}/32" -m comment --comment "${COMMENT}"
   if [ "$?" -ne "0" ]; then
     iptables -t nat -A POSTROUTING -j MASQUERADE -d "${s}/32" -m comment --comment "${COMMENT}"
   fi
done