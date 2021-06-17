#

## 1. 拉取redis镜像
```shell script
docker pull redis:6.0.6
```

## 2. 准备redis的配置文件
从官网下载redis相应版本的包，解压获取里边的redis.conf配置文件
```shell script
wget https://download.redis.io/releases/redis-6.0.6.tar.gz
tar -zxvf redis-6.0.6.tar.gz
cp redis-6.0.6/redis.conf /opt/redis/
```

## 3. 配置redis.conf配置文件
修改redis.conf配置文件：
主要配置的如下：
```shell script
#注释掉这部分，使redis可以外部访问
bind 127.0.0.1 
#用守护线程的方式启动
daemonize no
#你的密码#给redis设置密码
requirepass 123456
#redis持久化,默认是no
appendonly yes
#防止出现远程主机强迫关闭了一个现有的连接的错误 默认是300
tcp-keepalive 300
#关闭protected-mode模式，此时外部网络可以直接访问
#开启protected-mode保护模式，需配置bind ip或者设置访问密码
protected-mode no
```
> 特别需要注意的是在docker安装时配置daemonize需要设置成no，否则redis会一直重启

## 4.创建本地与docker映射的目录，即本地存放的位置
创建本地存放redis的位置;
可以自定义，因为我的docker的一些配置文件都是存放在/opt/redis/data目录下面的，
所以我依然在/opt/redis/data目录下创建一个redis目录，这样是为了方便后期管理
```shell script
sudo mkdir -p /opt/redis/data
```
把配置文件拷贝到刚才创建好的文件里
因为我本身就是Linux操作系统，所以我可以直接拷贝过去，如果你是windows的话，可能需要使用ftp拷贝过去，或者直接复制内容，然后粘贴过去。
```shell script
sudo cp -p redis.conf /opt/redis/
```

## 5. 启动docker redis
```shell script

sudo docker run \
 --name redis \
 -p 9736:6379 \
 -v /opt/redis/redis.conf:/etc/redis/redis.conf \
 -v /opt/redis/data:/data \
 --restart unless-stopped \
 -d redis:6.0.6  redis-server /etc/redis/redis.conf 
```

参数解释：
```shell script
#把容器内的6379端口映射到宿主机9736端口
-p 9736:6379
# 把宿主机配置好的redis.conf放到容器内的这个位置中
-v /data/redis/redis.conf:/etc/redis/redis.conf
# 把redis持久化的数据在宿主机内显示，做数据备份3
-v /data/redis/data:/data
# 这个是关键配置，让redis不是无配置启动，而是按照这个redis.conf的配置启动
redis-server /etc/redis/redis.conf
```







