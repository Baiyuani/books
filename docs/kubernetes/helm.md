---
tags:
  - helm
  - kubernetes
---

## 1.常用命令

```shell
#获取release实际加载的模板
helm get manifest rancher
helm get all rancher

#查找repo中charts的版本
helm search repo --versions
helm search repo --versions rancher-stable/rancher
# -l 显示所有版本
helm search repo gitlab/gitlab -l

#获取charts包
helm fetch rancher-stable/rancher
#获取指定版本的charts包
helm fetch rancher-stable/rancher --version=2.4.8
#获取charts包并解压到当前目录
helm fetch rancher-stable/rancher --untar
```

## 2. 测试安装charts，并输出模板

```shell
helm install ./first-chart --debug --dry-run
```

## 3. charts常用函数

```go
quote  加上双引号
upper  转换大小写
repeat NUM  对给定的字符串进行一定次数的回显
default STR  在模板内部指定一个默认值，一般情况下，所有的默认值都应该在values.yaml文件内指定，除非是一些运算结果
empty  如果给定的值被认为是空的，则empty函数返回true，否则返回false。在Go模板条件中，空值是为你计算出来的。这样你很少需要 if empty .Foo ，仅使用 if .Foo 即可。
```

## 4. 运行符

运算符被实现为返回布尔值的函数。要使用`eq`、`ne`、`lt`、`gt`、`and`、`or`、`not`等等，就要把运算符放在语句的前面，后面跟着它的参数，就像函数一样。要将多个操作链接在一起，可以用括号将它们分隔开。

```
{{/* include the body of this if statement when the variable .Values.fooString exists and is set to "foo" */}}
{{ if and .Values.fooString (eq .Values.fooString "foo") }}
    {{ ... }}
{{ end }}


{{/* include the body of this if statement when the variable .Values.anUnsetVariable is set or .values.aSetVariable is not set */}}
{{ if or .Values.anUnsetVariable (not .Values.aSetVariable) }}
   {{ ... }}
{{ end }}
```

## 5. 从集群中获取信息

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: {{ include "apis.qappSecretName" . | lower }}
  namespace: {{ .Release.Namespace }}
  labels: {{- include "apis.labels" . | nindent 4 }}
type: Opaque
data:
  {{- if .Release.IsInstall }}
  OAUTH_CLIENT_ID: ""
  OAUTH_CLIENT_SECRET: ""
  {{- else }}
  {{- $secretObj := (lookup "v1" "Secret" .Release.Namespace (include "apis.qappSecretName" .))  }}
  {{- $secretData := (get $secretObj "data") | default dict }}
  OAUTH_CLIENT_ID: {{ (get $secretData "OAUTH_CLIENT_ID")  | quote }}
  OAUTH_CLIENT_SECRET: {{ (get $secretData "OAUTH_CLIENT_SECRET")  | quote }}
  {{- end }}

```

## 6. 循环 range

```yaml
{{ if .Values.envVarsSecret }}
apiVersion: v1
kind: Secret
metadata:
  name: {{ printf "%s-envvars" (include "common.names.fullname" .) }}
  namespace: {{ .Release.Namespace }}
  labels: {{- include "common.labels.standard" . | nindent 4 }}
    {{- if .Values.commonLabels }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.commonLabels "context" $ ) | nindent 4 }}
    {{- end }}
  {{- if .Values.commonAnnotations }}
  annotations: {{- include "common.tplvalues.render" ( dict "value" .Values.commonAnnotations "context" $ ) | nindent 4 }}
  {{- end }}
type: Opaque
data:
{{- range $key, $val := .Values.envVarsSecret }}
  {{- $key | nindent 2 }}: {{ $val | b64enc | quote }}
{{- end }}
{{- end }}
```

## 7. dependencies

```yaml
# Charts.yaml
dependencies:
# 该condition代表参数fileapi-v2.enabled仅明确为bool false时，取消安装子charts fileapi-v2，其他情况均以true处理
- condition: fileapi-v2.enabled
  name: fileapi-v2
  repository: https://git.ketanyun.cn/api/v4/projects/1611/packages/helm/stable
  version: 1.5.11
```