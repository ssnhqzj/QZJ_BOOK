# redis单节点安装
## 安装依赖
```shell script
yum install gcc-c++ -y
```

## 下载地址
```shell script
wget http://download.redis.io/releases/redis-5.0.5.tar.gz
```

## 解压
```shell script
tar -zxvf redis-5.0.5.tar.gz
```

## 安装
```shell script
# make是用来编译的，它从Makefile中读取指令，然后编译
# make install是用来安装的，它也从Makefile中读取指令，安装到指定的位置 PREFIX选定要安装得目录
make && make PREFIX=/home/software/redis install
```

## 修改redis.conf配置文件
```shell script
#在136行
daemonize yes

#如需修改实例数量
#在186行
databases 32

#注释绑定ip，可以连接到redis得ip
#bind 127.0.0.1

#添加访问密码
#在507行
requirepass redis
```

# 集群安装
## 创建日志、数据目录
```shell script
# 创建数据目录
mkdir data
# 创建日志目录
mkdir logs
```

## 集群配置
> 在单节点配置的基础上增加以下配置
```shell script
#使用vim编辑器编辑配置文件时，可以使用

# 显示行数
:set number 

#263行 重新设置工作目录
dir /home/software/redis_master/data

#831行 设为节点启动
cluster-enabled yes

#922行 是否实现对集群的全覆盖
cluster-require-full-coverage no

#698行 是否进行数据持久化
appendonly yes

#158 行 进程文件
pidfile /var/run/redis_6379.pid

#92 行 设置启动端口
port 6379

#171行 日志文件位置
logfile "/home/software/redis_master/logs/redis-6379"

#253行 自动持久化文件
dbfilename dump-6379.rdb

#702行 aof自动持久化文件
appendfilename "appendonly-6379.aof"

#839行 自动生成集群文件
cluster-config-file nodes-6379.conf

#293行 设置集群密码（因为处于安全考虑，记住集群密码要和单机密码一致，而且每个节点上的集群密码一致）
masterauth sofn

# 技巧：为了方便你可以将将配置文件复制粘贴至各个节点
```

## 依次启动各个节点
```shell script
./redis_server redis.conf
```

## 使用redis-cli创建集群
```shell script

./redis-cli -a sofn --cluster create 192.168.21.70:7001 192.168.21.70:7002 192.168.21.70:7003 192.168.21.70:7004 192.168.21.70:7005 192.168.21.70:7006 --cluster-replicas 1

# 解释一下上面的命令
# -a :后面需要一个参数就是我们设置的集群密码
# --cluster：代表事集群操作
# Create：创建集群，后面是需要创建集群的节点
# --cluster-replicas 1：代表为每一个主节点创建一个从节点
```



