## time

```python
import time

time.sleep(1)
```

## zip

```python
a = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1]

b = [2, 2, 2, 2, 2, 2, 2, 2, 2, 2]

print(list(zip(a, b)))

[(1, 2), (1, 2), (1, 2), (1, 2), (1, 2), (1, 2), (1, 2), (1, 2), (1, 2), (1, 2)]
```

## python 获取系统环境变量的方式。https://blog.csdn.net/qq_31547771/article/details/115530169
```shell
export mysql_host="192.168.1.13"
export mysql_port="3306"
export mysql_user="user_test"
export mysql_pass="1234534534"
export mysql_dbname="test_db"
```

```python
import os
env_dist = os.environ
mysql_host = env_dist.get("mysql_host")
mysql_port = env_dist.get("mysql_port")
mysql_user = env_dist.get("mysql_user")
mysql_pass = env_dist.get("mysql_pass")
mysql_dbname = env_dist.get("mysql_dbname")
```

## 子进程和进程池 https://blog.csdn.net/m0_61655732/article/details/120567488

## joblib并行加速技巧 https://blog.csdn.net/qq_41185868/article/details/108278072
```python
from joblib import Parallel, delayed
from math import sqrt

a = Parallel(n_jobs=4, backend='threading')(delayed(sqrt)(i ** 2)for i in list(range(10)))
print(a)
```
- backend：用于设置并行方式，其中多进程方式有'loky'（更稳定）和'multiprocessing'两种可选项，多线程有'threading'一种选项。默认为'loky'
- n_jobs：用于设置并行任务同时执行的worker数量，当并行方式为多进程时，n_jobs最多可设置为机器CPU逻辑核心数量，超出亦等价于开启全部核心，你也可以设置为-1来快捷开启全部逻辑核心，若你不希望全部CPU资源均被并行任务占用，则可以设置更小的负数来保留适当的空闲核心，譬如设置为-2则开启全部核心-1个核心，设置为-3则开启全部核心-2个核心


## 日志 https://www.cnblogs.com/ikdl/p/15509034.html

```python
import logging

# filename存在时，将日志输出到文件，否则输出到stdout
logging.basicConfig(filename='myProgramLog.txt', level=logging.DEBUG, format=' %(asctime)s - %(levelname)s - %(message)s')
logging.debug('Start of program')


def factorial(n):
    logging.debug('Start of factorial(%s)' % (n))
    total = 1
    for i in range(1, n + 1):
        total *= i
        logging.debug('i is ' + str(i) + ', total is ' + str(total))
    logging.debug('End of factorial(%s)' % (n))
    return total


print(factorial(5))
logging.debug('End of program')


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




















