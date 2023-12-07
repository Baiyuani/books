## 


ab是apachebench命令的缩写。

ab的原理：ab命令会创建多个并发访问线程，模拟多个访问者同时对某一URL地址进行访问。它的测试目标是基于URL的，因此，它既可以用来测试apache的负载压力，也可以测试nginx、lighthttp、tomcat、IIS等其它Web服务器的压力。

其中-n代表每次并发量，-c代表总共发送的数量

ab -n 300 -c 300 http://192.168.0.10/
（-n发出300个请求，-c模拟300并发，相当800人同时访问，后面是测试url）

ab -t 60 -c 100 http://192.168.0.10/
在60秒内发请求，一次100个请求。 

Document Path:          /  ###请求的资源
Document Length:        50679 bytes  ###文档返回的长度，不包括相应头

Concurrency Level:      3000   ###并发个数
Time taken for tests:   30.449 seconds   ###总请求时间
Complete requests:      3000     ###总请求数
Failed requests:        0     ###失败的请求数
Write errors:           0
Total transferred:      152745000 bytes
HTML transferred:       152037000 bytes
Requests per second:    98.52 [#/sec] (mean)      ###平均每秒的请求数
Time per request:       30449.217 [ms] (mean)     ###平均每个请求消耗的时间
Time per request:       10.150 [ms] (mean, across all concurrent requests)  ###上面的请求除以并发数
Transfer rate:          4898.81 [Kbytes/sec] received   ###传输速率
