# Run OpenLDAP created by official helm chart on k8s


## Using Helm 3 installed OpenLDAP:
```bash
helm install openldap apphub/openldap \
--set persistence.enabled=true \
--set persistence.storageClass="nfs-client" \
--set persistence.size="20Gi" \
-f values.yaml  \
-n qtgl
```   
Got this message:
```shell script
[ymzhang@SaaS-Storage qtgl]$ helm install openldap apphub/openldap \
> --set persistence.enabled=true \
> --set persistence.storageClass="nfs-storage" \
> --set persistence.size="20Gi" \
> -n qtgl
NAME: openldap
LAST DEPLOYED: Mon Jul  5 14:14:36 2021
NAMESPACE: qtgl
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
OpenLDAP has been installed. You can access the server from within the k8s cluster using:

  openldap.qtgl.svc.cluster.local:389


You can access the LDAP adminPassword and configPassword using:

  kubectl get secret --namespace qtgl openldap -o jsonpath="{.data.LDAP_ADMIN_PASSWORD}" | base64 --decode; echo
  kubectl get secret --namespace qtgl openldap -o jsonpath="{.data.LDAP_CONFIG_PASSWORD}" | base64 --decode; echo


You can access the LDAP service, from within the cluster (or with kubectl port-forward) with a command like (replace password and domain):
  ldapsearch -x -H ldap://openldap.qtgl.svc.cluster.local:389 -b dc=example,dc=org -D "cn=admin,dc=example,dc=org" -w $LDAP_ADMIN_PASSWORD


Test server health using Helm test:
  helm test openldap


You can also consider installing the helm chart for phpldapadmin to manage this instance of OpenLDAP, or install Apache Directory Studio, and connect using kubectl port-forward.
```




ldapsearch 查询
```shell script
root@openldap-69db79887d-5xvcf:/# ldapsearch -x -H ldap://openldap-nodeport:389 -b dc=example,dc=org -D "cn=admin,dc=example,dc=org" -w aFNhJnUmqiXm4pgB88HQEe2a6r3lkMeT
# extended LDIF
#
# LDAPv3
# base <dc=example,dc=org> with scope subtree
# filter: (objectclass=*)
# requesting: ALL
#

# example.org
dn: dc=example,dc=org
objectClass: top
objectClass: dcObject
objectClass: organization
o: Example Inc.
dc: example

# admin, example.org
dn: cn=admin,dc=example,dc=org
objectClass: simpleSecurityObject
objectClass: organizationalRole
cn: admin
description: LDAP administrator
userPassword:: e1NTSEF9ZjgwblRtK05MeVA2aXpNVXFRTXN5QktqdVJ2ZVdZcks=

# search result
search: 2
result: 0 Success

# numResponses: 3
# numEntries: 2

```










## References ##

- [openladp](https://hub.helm.sh/charts/stable/openldap)