## centos7 编译安装 python

```shell
# https://help.dreamhost.com/hc/en-us/articles/360001435926-Installing-OpenSSL-locally-under-your-username
wget https://www.openssl.org/source/openssl-1.1.1w.tar.gz
tar zxvf openssl-1.1.1w.tar.gz
cd openssl-1.1.1w
./config --prefix=$HOME/openssl --openssldir=$HOME/openssl no-ssl2
make
make test
make install
echo 'export PATH=$HOME/openssl/bin:$PATH
export LD_LIBRARY_PATH=$HOME/openssl/lib
export LC_ALL="en_US.UTF-8"
export LDFLAGS="-L $HOME/openssl/lib -Wl,-rpath,$HOME/openssl/lib"' >> ~/.bash_profile
. ~/.bash_profile


# https://zhuanlan.zhihu.com/p/358605587
yum -y install zlib-devel bzip2-devel openssl-devel ncurses-devel sqlite-devel readline-devel tk-devel gdbm-devel db4-devel libpcap-devel xz-devel libffi-devel
wget https://www.python.org/ftp/python/3.11.6/Python-3.11.6.tgz
tar xf Python-3.11.6.tgz
cd Python-3.11.6
./configure --prefix=/usr/local/python3 --with-openssl=$HOME/openssl
make && make install
ln -s /usr/local/python3/bin/python3 /usr/bin/python3
ln -s /usr/local/python3/bin/pip3 /usr/bin/pip3
```


## pip

```shell
pip install -i https://pypi.tuna.tsinghua.edu.cn/simple --trusted-host pypi.tuna.tsinghua.edu.cn \
    -r /requirements.txt

pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple    

# 查看所有版本
pip install requests==
```


## time

```python
import time

time.sleep(1)
```

## zip

#### 使用方法
```python
a = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
b = [2, 2, 2, 2, 2, 2, 2, 2, 2, 2]
print(list(zip(a, b)))
# [(1, 2), (1, 2), (1, 2), (1, 2), (1, 2), (1, 2), (1, 2), (1, 2), (1, 2), (1, 2)]
```

#### zip函数同时处理多个对象
```python
id = [1, 2, 3, 4]
record = zip(id)
print(list(record))
# [(1,), (2,), (3,), (4,)]
```

- 传递多个列表

```python
id = [1, 2, 3, 4]
leaders = ['Elon Mask', 'Tim Cook', 'Bill Gates', 'Bai Li']
sex = ['m', 'm', 'm', 'm']
record = zip(id, leaders, sex)

print(list(record))
# [(1, 'Elon Mask', 'm'), (2, 'Tim Cook', 'm'), (3, 'Bill Gates', 'm'), (4, 'Bai Li', 'm')]
```

#### zip函数处理长度不等的参数

```python
id = [1, 2]
leaders = ['Elon Mask', 'Tim Cook', 'Bill Gates', 'Bai Li']
record = zip(id, leaders)

# 忽略了列表leaders 中的最后两个元素
print(list(record))
# [(1, 'Elon Mask'), (2, 'Tim Cook')]
```

- 使用zip_langest 函数。zip_langest 函数基于其最长参数来返回结果

```python
from itertools import zip_longest
id = [1, 2]
leaders = ['Elon Mask', 'Tim Cook', 'Bill Gates', 'Bai Li']

long_record = zip_longest(id, leaders)
print(list(long_record))
# [(1, 'Elon Mask'), (2, 'Tim Cook'), (None, 'Bill Gates'), (None, 'Bai Li')]

long_record_2 = zip_longest(id, leaders, fillvalue='Top')
print(list(long_record_2))
# [(1, 'Elon Mask'), (2, 'Tim Cook'), ('Top', 'Bill Gates'), ('Top', 'Bai Li')]
```

#### unzip

```python
record = [(1, 'Elon Mask'), (2, 'Tim Cook'), (3, 'Bill Gates'), (4, 'Bai Li')]
# 星号执行了拆包操作
id, leaders = zip(*record)

print(id)
# (1, 2, 3, 4)
print(leaders)
# ('Elon Mask', 'Tim Cook', 'Bill Gates', 'Bai Li')
```

#### 通过zip函数创建和更新dict

```python
id = [1, 2, 3, 4]
leaders = ['Elon Mask', 'Tim Cook', 'Bill Gates', 'Bai Li']

# create dict by dict comprehension
leader_dict = {i: name for i, name in zip(id, leaders)}
print(leader_dict)
# {1: 'Elon Mask', 2: 'Tim Cook', 3: 'Bill Gates', 4:'Bai Li'}

# create dict by dict function
leader_dict_2 = dict(zip(id, leaders))
print(leader_dict_2)
# {1: 'Elon Mask', 2: 'Tim Cook', 3: 'Bill Gates', 4: 'Bai Li'}

# update
other_id = [5, 6]
other_leaders = ['Larry Page', 'Sergey Brin']
leader_dict.update(zip(other_id, other_leaders))
print(leader_dict)
# {1: 'Elon Mask', 2: 'Tim Cook', 3: 'Bill Gates', 4: ''Bai Li'', 5: 'Larry Page', 6: 'Sergey Brin'}
```

#### 在for循环中使用zip函数  

```python
products = ["cherry", "strawberry", "banana"]
price = [2.5, 3, 5]
cost = [1, 1.5, 2]
for prod, p, c in zip(products, price, cost):
    print(f'The profit of a box of {prod} is £{p-c}!')
# The profit of a box of cherry is £1.5!
# The profit of a box of strawberry is £1.5!
# The profit of a box of banana is £3!
```

#### 实现矩阵转置

```python
matrix = [[1, 2, 3], [1, 2, 3]]
matrix_T = [list(i) for i in zip(*matrix)]
print(matrix_T)
# [[1, 1], [2, 2], [3, 3]]
```


## requests库的get()方法使用 https://blog.csdn.net/qq_44728587/article/details/123090304

## 随机模块

```python
import random

# 打印1-10中随机一个数
print(random.randrange(1, 10))

```

## 获取长度
```python
a = "Hello, World!"
print(len(a))
```

## function 任意参数
```python
# Arbitrary Arguments, *args
# Arbitrary Arguments are often shortened to *args in Python documentations.
def my_function(*kids):
  print("The youngest child is " + kids[2])

my_function("Emil", "Tobias", "Linus")

# 可避免由于入参过多导致报错
def my_function(a, b, *args):
  print("The youngest child is " + a + ' ' + b)

my_function("Emil", "Tobias", "Linus")

```

## function 关键字参数
```python
# 使用 key = value 语法发送参数。 这样参数的顺序无关紧要。
def my_function(child3, child2, child1):
  print("The youngest child is " + child3)

my_function(child1 = "Emil", child2 = "Tobias", child3 = "Linus")
```


## function 任意关键字参数
```python
# Arbitrary Kword Arguments are often shortened to **kwargs in Python documentations.
def my_function(**kid):
  print("His last name is " + kid["lname"])

my_function(fname = "Tobias", lname = "Refsnes")
```

## 命令行参数处理

    解释器读取命令行参数，把脚本名与其他参数转化为字符串列表存到 sys 模块的 argv 变量里。
    执行 import sys，可以导入这个模块，并访问该列表。该列表最少有一个元素；未给定输入参数时，sys.argv[0] 是空字符串。
    给定脚本名是 '-' （标准输入）时，sys.argv[0] 是 '-'。使用 -c command 时，sys.argv[0] 是 '-c'。
    如果使用选项 -m module，sys.argv[0] 就是包含目录的模块全名。解释器不处理 -c command 或 -m module 之后的选项，而是直接留在 sys.argv 中由命令或模块来处理。

```python
# main.py
import sys

print(sys.argv[0])

print(sys.argv[1])

print(sys.argv[2])

print(sys.argv[3])
```
```shell
python .\main.py a b c

.\main.py
a
b
c
```



## web开发

```shell
flask
Django
fastapi
```

## 调用系统命令

- linux
```python
import sh

sh.mkdir('abc')
sh.echo('test')
sh.touch('asdasd')
```

- os
```python
import os


```


## uuid

```python
import uuid

user_id = uuid.uuid4()
print(user_id)
```

## [排序sorted](https://docs.python.org/zh-cn/3.11/howto/sorting.html?highlight=sort)
```python
sorted([5, 2, 3, 1, 4])
[1, 2, 3, 4, 5]

```

## 变量级联赋值

```python
"""可变对象set/list/dict由一个变量赋值给另一个变量时，是赋值的内存地址，此时针对其中一个变量的操作会同时影响两个变量，如果需要分离，则使用copy()方法"""
a = {"a", "b"}
b = a.copy()
b.remove("b")
print(a)
print(b)




dict1 = ["a", 3]
dict2 = dict1.copy()

del dict2[0]

print(dict1)
print(dict2)


```






