# 增量同步工具canal服务端安装

## 准备
- 对于自建 MySQL , 需要先开启 Binlog 写入功能，配置 binlog-format 为 ROW 模式，my.cnf 中配置如下
```
[mysqld]
log-bin=mysql-bin # 开启 binlog
binlog-format=ROW # 选择 ROW 模式
server_id=1 # 配置 MySQL replaction 需要定义，不要和 canal 的 slaveId 重复
```
> docker安装mysql可进入容器在容器/etc/mysql/mysql.conf.d/mysqld.cnf修改配置文件

- 授权 canal 链接 MySQL 账号具有作为 MySQL slave 的权限, 如果已有账户可直接 grant
```
CREATE USER canal IDENTIFIED BY 'canal';  
GRANT SELECT, REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO 'canal'@'%';
-- GRANT ALL PRIVILEGES ON *.* TO 'canal'@'%' ;
FLUSH PRIVILEGES;
```

## 拉去镜像
```
docker pull canal/canal-server:v1.1.4
```
## 启动镜像 
```shell script
docker run --name canal -d canal/canal-server:v1.1.4
```

## 进入容器 查看配置文件路径
```shell script
docker exec -it canal bash
#找到文件位置后 exit退出容器 将容器内部文件copy到外部
docker cp canal:/home/admin/canal-server/conf/canal.properties /opt/canal
docker cp canal:/home/admin/canal-server/conf/example/instance.properties /opt/canal
```

## 文件copy完成后主要是修改instance这个文件。第一个红框是你需要监听数据库的地址和端口；第二个红框是你数据库的用户和密码，
## 这个用户信息一定是要有全部权限的用户，非root用户；第三个是匹配数据表的规则，我这里默认为全部表
```
vim /opt/instance.properties
```

```
## mysql serverId
canal.instance.mysql.slaveId = 1234
#position info，需要改成自己的数据库信息
canal.instance.master.address = 127.0.0.1:3306 
canal.instance.master.journal.name = 
canal.instance.master.position = 
canal.instance.master.timestamp = 
#canal.instance.standby.address = 
#canal.instance.standby.journal.name =
#canal.instance.standby.position = 
#canal.instance.standby.timestamp = 
#username/password，需要改成自己的数据库信息
canal.instance.dbUsername = canal  
canal.instance.dbPassword = canal
canal.instance.defaultDatabaseName =
canal.instance.connectionCharset = UTF-8
#table regex
canal.instance.filter.regex = .\*\\\\..\*
```
> canal.instance.connectionCharset 代表数据库的编码方式对应到 java 中的编码类型，比如 UTF-8，GBK , ISO-8859-1
  如果系统是1个 cpu，需要将 canal.instance.parser.parallel 设置为 false

## 修改完成后，将之前的canal容器关闭，重新起一个新的容器.
```shell script
#关闭容器
docker stop canal

#移除容器
docker rm canal

#启动新的 这里-v是将外部的文件挂载到容器内部 这样就不用每次启动都要配置参数了
docker run \
--name canal \
--restart=always \
-d \
-p 11111:11111 \
-v /opt/canal/instance.properties:/home/admin/canal-server/conf/example/instance.properties \
-v /opt/canal/canal.properties:/home/admin/canal-server/conf/canal.properties \
canal/canal-server:v1.1.4
```
