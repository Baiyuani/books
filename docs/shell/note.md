# 1. 脚本执行的几种方式 

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


