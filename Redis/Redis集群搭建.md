## 搭建Redis集群

要让集群正常工作至少需要3个主节点，在这里我们要创建6个redis节点，其中三个为主节点，三个为从节点，对应的redis节点的ip和端口对应关系如下（为了简单演示都在同一台机器上面）
```
127.0.0.1:7000

127.0.0.1:7001

127.0.0.1:7002

127.0.0.1:7003

127.0.0.1:7004

127.0.0.1:7005
```

安装和启动Redis
----

下载安装包
```
wget http://download.redis.io/releases/redis-3.2.9.tar.gz
```
解压安装

```
tar zxvf redis-3.2.9.tar.gz
cd redis-3.2.9
make && make PREFIX=/usr/local/redis install
```
这里如果失败的自行yum安装gcc和tcl

```
yum install gcc
yum install tcl
```

创建目录
```
cd /usr/local/redis
mkdir cluster
cd cluster
mkdir 7000 7001 7002 7003 7004 7005
```

复制和修改配置文件
将redis目录下的配置文件复制到对应端口文件夹下,6个文件夹都要复制一份
```
cp redis-3.2.9/redis.conf /usr/local/redis/cluster/7000
```

修改配置文件redis.conf，将下面的选项修改

```
# 端口号
port 7000
# 后台启动
daemonize yes
# 开启集群
cluster-enabled yes
#集群节点配置文件
cluster-config-file nodes-7000.conf
# 集群连接超时时间
cluster-node-timeout 5000
# 进程pid的文件位置
pidfile /var/run/redis-7000.pid
# 开启aof
appendonly yes
# aof文件路径
appendfilename "appendonly-7005.aof"
# rdb文件路径
dbfilename dump-7000.rdb
```
6个配置文件安装对应的端口分别修改配置文件


创建启动脚本
在/usr/local/redis目录下创建一个start.sh

```
#!/bin/bash
redis-server cluster/7000/redis.conf
redis-server cluster/7001/redis.conf
redis-server cluster/7002/redis.conf
redis-server cluster/7003/redis.conf
redis-server cluster/7004/redis.conf
redis-server cluster/7005/redis.conf
```
这个时候我们查看一下进程看启动情况

ps -ef | grep redis
进程状态如下：

```
root      1731     1  1 18:21 ?        00:00:49 bin/redis-server *:7000 [cluster]       
root      1733     1  0 18:21 ?        00:00:29 bin/redis-server *:7001 [cluster]       
root      1735     1  0 18:21 ?        00:00:08 bin/redis-server *:7002 [cluster]       
root      1743     1  0 18:21 ?        00:00:26 bin/redis-server *:7003 [cluster]       
root      1745     1  0 18:21 ?        00:00:13 bin/redis-server *:7004 [cluster]       
root      1749     1  0 18:21 ?        00:00:08 bin/redis-server *:7005 [cluster]
```
有6个redis进程在开启，说明我们的redis就启动成功了


Redis开启集群
----

Redis 5使用以下命令开启集群
```
redis-cli --cluster create 127.0.0.1:7000 127.0.0.1:7001 \
127.0.0.1:7002 127.0.0.1:7003 127.0.0.1:7004 127.0.0.1:7005 \
--cluster-replicas 1

这里不得使用127.0.0.1本机ip，否则不能外部访问
redis-cli --cluster create 192.168.204.129:7000 192.168.204.129:7001 \
192.168.204.129:7002 192.168.204.129:7003 192.168.204.129:7004 192.168.204.129:7005 \
--cluster-replicas 1
```

Redis开启远程连接：
---
```aidl
编辑redis.conf文件
注释掉 # bind 127.0.0.1
或改成 bind 0.0.0.0
```


