# 增量同步工具canal服务端安装

## 准备
- 安装jdk

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

## 下载
```
https://github.com/alibaba/canal/releases/download/canal-1.1.4/canal.deployer-1.1.4.tar.gz
```

解压缩
```
mkdir /usr/local/canal
tar zxvf canal.deployer-$version.tar.gz  -C /usr/local/canal
```

解压完成后，进入 /usr/local/canal 目录，可以看到如下结构
```
drwxr-xr-x. 2 root root   76 9月  30 11:07 bin
drwxr-xr-x. 5 root root  123 9月  30 11:07 conf
drwxr-xr-x. 2 root root 4096 9月  30 11:07 lib
drwxrwxrwx. 2 root root    6 9月   2 2019 logs
```

## 配置
```
vim conf/example/instance.properties
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

## 启动
```
sh bin/startup.sh
```

查看 server 日志
```
vim logs/canal/canal.log
```
```
2020-09-30 11:29:03.566 [main] INFO  com.alibaba.otter.canal.deployer.CanalLauncher - ## set default uncaught exception handler
2020-09-30 11:29:03.818 [main] INFO  com.alibaba.otter.canal.deployer.CanalLauncher - ## load canal configurations
2020-09-30 11:29:03.948 [main] INFO  com.alibaba.otter.canal.deployer.CanalStarter - ## start the canal server.
2020-09-30 11:29:04.261 [main] INFO  com.alibaba.otter.canal.deployer.CanalController - ## start the canal server[172.17.0.1(172.17.0.1):11111]
2020-09-30 11:29:12.448 [main] INFO  com.alibaba.otter.canal.deployer.CanalStarter - ## the canal server is running now ......
```

查看 instance 的日志
```
vim logs/example/example.log
```

```
2020-09-30 11:29:06.833 [main] INFO  c.a.o.c.i.spring.support.PropertyPlaceholderConfigurer - Loading properties file from class path resource [canal.properties]
2020-09-30 11:29:06.845 [main] INFO  c.a.o.c.i.spring.support.PropertyPlaceholderConfigurer - Loading properties file from class path resource [example/instance.properties]
2020-09-30 11:29:08.215 [main] WARN  o.s.beans.GenericTypeAwarePropertyDescriptor - Invalid JavaBean property 'connectionCharset' being accessed! Ambiguous write methods found next to actually used [public void com.alibaba.otter.canal.parse.inbound.mysql.AbstractMysqlEventParser.setConnectionCharset(java.lang.String)]: [public void com.alibaba.otter.canal.parse.inbound.mysql.AbstractMysqlEventParser.setConnectionCharset(java.nio.charset.Charset)]
2020-09-30 11:29:08.524 [main] INFO  c.a.o.c.i.spring.support.PropertyPlaceholderConfigurer - Loading properties file from class path resource [canal.properties]
2020-09-30 11:29:08.526 [main] INFO  c.a.o.c.i.spring.support.PropertyPlaceholderConfigurer - Loading properties file from class path resource [example/instance.properties]
2020-09-30 11:29:11.666 [main] INFO  c.a.otter.canal.instance.spring.CanalInstanceWithSpring - start CannalInstance for 1-example 
2020-09-30 11:29:11.824 [main] WARN  c.a.o.canal.parse.inbound.mysql.dbsync.LogEventConvert - --> init table filter : ^.*\..*$
2020-09-30 11:29:11.824 [main] WARN  c.a.o.canal.parse.inbound.mysql.dbsync.LogEventConvert - --> init table black filter : 
2020-09-30 11:29:11.894 [main] INFO  c.a.otter.canal.instance.core.AbstractCanalInstance - start successful....
```

## 关闭
```
sh bin/stop.sh
```

## 测试
- 在mysql所在的服务器中下载官方示例包canal.example-1.1.4.tar.gz
```
cd /usr/local/

wget https://github.com/alibaba/canal/releases/download/canal-1.1.4/canal.example-1.1.4.tar.gz

mkdir canal-example

tar zxvf canal.example-1.1.4.tar.gz -C canal-example
```

- 使用mysql创建表，插入数据等操作，在canal-example目录下logs中的entry.log即可看到binlog日志
```
 sql ----> CREATE DATABASE `canaltest`

****************************************************
* Batch Id: [2] ,count : [1] , memsize : [267] , Time : 2020-09-30 15:04:46
* Start : [mysql-bin.000001:1226:1601449486000(2020-09-30 15:04:46)] 
* End : [mysql-bin.000001:1226:1601449486000(2020-09-30 15:04:46)] 
****************************************************

----------------> binlog[mysql-bin.000001:1226] , name[canaltest,xdual] , eventType : CREATE , executeTime : 1601449486000(2020-09-30 15:04:46) , gtid : () , delay : 670 ms
 sql ----> CREATE TABLE `xdual` ( `ID` int(11) NOT NULL AUTO_INCREMENT,`X` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP, PRIMARY KEY (`ID`)) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8

****************************************************
* Batch Id: [3] ,count : [3] , memsize : [160] , Time : 2020-09-30 15:07:30
* Start : [mysql-bin.000001:1558:1601449650000(2020-09-30 15:07:30)] 
* End : [mysql-bin.000001:1742:1601449650000(2020-09-30 15:07:30)] 
****************************************************

================> binlog[mysql-bin.000001:1558] , executeTime : 1601449650000(2020-09-30 15:07:30) , gtid : () , delay : 879ms
 BEGIN ----> Thread id: 9
----------------> binlog[mysql-bin.000001:1698] , name[canaltest,xdual] , eventType : INSERT , executeTime : 1601449650000(2020-09-30 15:07:30) , gtid : () , delay : 890 ms
ID : 1    type=int(11)    update=true
X : 2020-09-30 23:04:31    type=timestamp    update=true
----------------
 END ----> transaction id: 385
================> binlog[mysql-bin.000001:1742] , executeTime : 1601449650000(2020-09-30 15:07:30) , gtid : () , delay : 919ms
```