---
tags:
  - shell
  - linux
---

## 脚本执行的几种方式 

1. 当前shell执行

```shell
source filename

. filename
```


不创建subshell，在当前shell环境下读取并执行filename中的命令，相当于顺序执行filename里面的命令

2. 新建子shell执行
   
```shell
bash filename

./filename
```

创建subshell，在当前bash环境下再新建一个子shell执行filename中的命令。
子shell继承父shell的变量，但子shell不能使用父shell的变量，除非使用export
【备注：这和命名空间是相似的道理，甚至和c中的函数也有些类似】

    子Shell从父Shell继承得来的属性如下：

        当前工作目录
        环境变量
        标准输入、标准输出和标准错误输出
        所有已打开的文件标识符
        忽略的信号

    子Shell不能从父Shell继承的属性，归纳如下：

        除环境变量和.bashrc文件中定义变量之外的Shell变量
        未被忽略的信号处理

3. `$(commond)`
它的作用是让命令在子shell中执行

4. `commond`
和$(commond)差不多。
【这里的“ ` ”符号是撇（反单引号），不是单引号，是键盘上Esc按键下面的那个键。】

5. `exec commond`
替换当前的shell却没有创建一个新的进程。进程的pid保持不变
作用:
shell的内建命令exec将并不启动新的shell，而是用要被执行命令替换当前的shell进程，并且将老进程的环境清理掉，而且exec命令后的其它命令将不再执行。
当在一个shell里面执行exec ls后，会列出了当前目录，然后这个shell就自己退出了。（后续命令不再执行）
因为这个shell已被替换为仅执行ls命令的进程，执行结束自然也就退出了。
需要的时候可以用sub shell 避免这个影响，一般将exec命令放到一个shell脚本里面，用主脚本调用这个脚本，调用点处可以用bash a.sh（a.sh就是存放该命令的脚本），这样会为a.sh建立一个sub shell去执行，当执行到exec后，该子脚本进程就被替换成了相应的exec的命令。

## [shellcheck](https://github.com/koalaman/shellcheck)

#### 安装

- debian/ubuntu

```shell
sudo apt install shellcheck
```

- centos

```shell
sudo yum -y install epel-release
sudo yum install ShellCheck
```

- vim

```shell
mkdir -p ~/.vim/pack/git-plugins/start
git clone --depth 1 https://github.com/dense-analysis/ale.git ~/.vim/pack/git-plugins/start/ale
```

- VSCode：通过 vscode-shellcheck 安装。

#### 使用

```shell
shellcheck yourscript
```

## set -o pipefail

在默认情况下，一个管道命令（由多个命令通过管道符 | 连接而成的命令）的退出状态是最后一个命令的退出状态，而不考虑前面的命令是否执行成功。

```shell
command1 | command2
```

如果 command1 失败（返回非零退出状态），但 command2 成功（返回零退出状态），那么整个管道命令的退出状态是 0（成功）。

但是如果你使用了set -o pipefail，那么如果 command1 失败，整个管道命令的退出状态就是 command1 的退出状态，即使 command2 成功。

## [flock](https://linux.die.net/man/1/flock)

https://blog.csdn.net/weixin_31748605/article/details/116879655

```shell
*/5 * * * * flock -xn /tmp/lock -c 'start.sh >/dev/null 2>&1'
```

- e.g.

```shell
(
flock -s 200

# ... commands executed under lock ...
echo $$

) 200>/var/lock/mylockfile
```

```shell
#!/bin/bash

{

flock -n 3

[ $? -eq 1 ] && { echo fail; exit; }

echo $$

} 3<>mylockfile
```

