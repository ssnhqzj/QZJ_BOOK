# hive安装配置

## 下载

hive官网地址：[http](https://so.csdn.net/so/search?q=http&spm=1001.2101.3001.7020)://hive.apache.org/

## 解压

```shell
# 解压
tar -zxvf apache-hive-3.1.2-bin.tar.gz

# 缩短目录名称
mv apache-hive-3.1.3-bin hive-3.1.3
```

## 配置环境变量

```shell
vi /etc/profile
#添加一下内容
#HIVE_HOME
export HIVE_HOME=/usr/local/hive-3.1.3
export PATH=$PATH:$HIVE_HOME/bin

#使配置生效
source /etc/profile
```

## 初始化元数据库

默认是derby数据库

```shell
bin/schematool -dbType derby -initSchema
```

如报以下错误：

```
Exception in thread "main" java.lang.NoSuchMethodError: com.google.common.base.Preconditions.checkArgument(ZLjava/lang/String;Ljava/lang/Object;)V
```

原因是hadoop和hive的两个guava.jar版本不一致，两个jar位置分别位于下面两个目录：

```
/hive-3.1.3/lib/guava-19.0.jar 
/hadoop-3.1.4/share/hadoop/common/lib/guava-27.0-jre.jar
```

解决办法是删除低版本的那个，将高版本的复制到低版本目录下。

```shell
cd /export/servers/hive/lib
rm -f guava-19.0.jar
cp /export/servers/hadoop-3.1.4/share/hadoop/common/lib/guava-27.0-jre.jar .
```

再次运行schematool -dbType derby -initSchema，即可成功初始化元数据库。
## 配置元数据到MySQL

- ##### MySQL中创建元数据库

```sql
create database hive_meta;
```

- ##### 拷贝MySQL的JDBC驱动到hive的lib目录下

- ##### 在$HIVE_HOME/conf目录下新建hive-site.xml文件
```shell
vi $HIVE_HOME/conf/hive-site.xml
```

添加以下内容：

```xml
<?xml version="1.0"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>

<configuration>
    <!-- jdbc连接的URL -->
    <property>
        <name>javax.jdo.option.ConnectionURL</name>
        <value>jdbc:mysql://10.8.1.166:3306/hive_meta?useSSL=false</value>
    </property>

    <!-- jdbc连接的Driver-->
    <property>
        <name>javax.jdo.option.ConnectionDriverName</name>
        <value>com.mysql.cj.jdbc.Driver</value>
    </property>

    <!-- jdbc连接的username-->
    <property>
        <name>javax.jdo.option.ConnectionUserName</name>
        <value>root</value>
    </property>

    <!-- jdbc连接的password -->
    <property>
        <name>javax.jdo.option.ConnectionPassword</name>
        <value>QingCheng1234567890.</value>
    </property>

    <!-- Hive默认在HDFS的工作目录 -->
    <property>
        <name>hive.metastore.warehouse.dir</name>
        <value>/user/hive/warehouse</value>
    </property>
</configuration>
```

- ##### 初始化Hive元数据库（修改为采用MySQL存储元数据）

  ```shell
  bin/schematool -dbType mysql -initSchema -verbose
  ```

 以下提示表示初始化成功

```shell
No rows affected (0.319 seconds)
0: jdbc:mysql://10.8.1.166:3306/hive_meta> CREATE INDEX IDX_RUNTIME_STATS_CREATE_TIME ON RUNTIME_STATS(CREATE_TIME)
No rows affected (1.019 seconds)
0: jdbc:mysql://10.8.1.166:3306/hive_meta> INSERT INTO VERSION (VER_ID, SCHEMA_VERSION, VERSION_COMMENT) VALUES (1, '3.1.0', 'Hive release version 3.1.0')
1 row affected (0.002 seconds)
0: jdbc:mysql://10.8.1.166:3306/hive_meta> /*!40101 SET character_set_client = @saved_cs_client */
No rows affected (0 seconds)
0: jdbc:mysql://10.8.1.166:3306/hive_meta> /*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */
No rows affected (0 seconds)
0: jdbc:mysql://10.8.1.166:3306/hive_meta> /*!40101 SET SQL_MODE=@OLD_SQL_MODE */
No rows affected (0.001 seconds)
0: jdbc:mysql://10.8.1.166:3306/hive_meta> /*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */
No rows affected (0 seconds)
0: jdbc:mysql://10.8.1.166:3306/hive_meta> /*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */
No rows affected (0 seconds)
0: jdbc:mysql://10.8.1.166:3306/hive_meta> /*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */
No rows affected (0 seconds)
0: jdbc:mysql://10.8.1.166:3306/hive_meta> /*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */
No rows affected (0 seconds)
0: jdbc:mysql://10.8.1.166:3306/hive_meta> /*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */
No rows affected (0 seconds)
0: jdbc:mysql://10.8.1.166:3306/hive_meta> /*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */
No rows affected (0 seconds)
0: jdbc:mysql://10.8.1.166:3306/hive_meta> !closeall
Closing: 0: jdbc:mysql://10.8.1.166:3306/hive_meta?useSSL=false
beeline>
beeline> Initialization script completed
```

## 验证元数据是否配置成功

- ##### 启动hadoop集群和MySQL服务

- ##### 启动Hive

  ```shell
  bin/hive
  ```

  ```
  which: no hbase in (/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/usr/local/jdk1.8.0_211/bin:/usr/local/jdk1.8.0_211/jre/bin:/opt/hadoop/hadoop-2.7.5/bin:/opt/hadoop/hadoop-2.7.5/sbin:/usr/local/sqoop-1.4.7.bin__hadoop-2.6.0/bin:/root/bin:/usr/local/jdk1.8.0_211/bin:/usr/local/jdk1.8.0_211/jre/bin:/opt/hadoop/hadoop-2.7.5/bin:/opt/hadoop/hadoop-2.7.5/sbin:/usr/local/sqoop-1.4.7.bin__hadoop-2.6.0/bin:/usr/local/hive-3.1.3/bin)
  SLF4J: Class path contains multiple SLF4J bindings.
  SLF4J: Found binding in [jar:file:/usr/local/hive-3.1.3/lib/log4j-slf4j-impl-2.17.1.jar!/org/slf4j/impl/StaticLoggerBinder.class]
  SLF4J: Found binding in [jar:file:/opt/hadoop/hadoop-2.7.5/share/hadoop/common/lib/slf4j-log4j12-1.7.10.jar!/org/slf4j/impl/StaticLoggerBinder.class]
  SLF4J: See http://www.slf4j.org/codes.html#multiple_bindings for an explanation.
  SLF4J: Actual binding is of type [org.apache.logging.slf4j.Log4jLoggerFactory]
  Hive Session ID = 5dfab380-172b-4c7a-a701-8477e7460793
  
  Logging initialized using configuration in jar:file:/usr/local/hive-3.1.3/lib/hive-common-3.1.3.jar!/hive-log4j2.properties Async: true
  Hive Session ID = b8e910f5-1d3c-4223-99d9-21ddf8fa996a
  Hive-on-MR is deprecated in Hive 2 and may not be available in the future versions. Consider using a different execution engine (i.e. spark, tez) or using Hive 1.X releases.
  hive>
  ```

- 使用hive

  ```
  hive> show databases;
  hive> show tables;
  hive> create table stu(id int, name string);
  hive> insert into stu values(1,"ss");
  hive> select * from stu;
  ```

  ```sql
  hive> insert into stu values(1, "ss");
  Query ID = root_20240705112117_502d4f53-2904-4629-bafc-b852f472cb64
  Total jobs = 3
  Launching Job 1 out of 3
  Number of reduce tasks determined at compile time: 1
  In order to change the average load for a reducer (in bytes):
    set hive.exec.reducers.bytes.per.reducer=<number>
  In order to limit the maximum number of reducers:
    set hive.exec.reducers.max=<number>
  In order to set a constant number of reducers:
    set mapreduce.job.reduces=<number>
  Starting Job = job_1718257463120_0002, Tracking URL = http://hd.master:18088/proxy/application_1718257463120_0002/
  Kill Command = /opt/hadoop/hadoop-2.7.5/bin/mapred job  -kill job_1718257463120_0002
  Hadoop job information for Stage-1: number of mappers: 1; number of reducers: 1
  2024-07-05 11:21:29,523 Stage-1 map = 0%,  reduce = 0%
  2024-07-05 11:21:34,751 Stage-1 map = 100%,  reduce = 0%, Cumulative CPU 2.98 sec
  2024-07-05 11:21:39,964 Stage-1 map = 100%,  reduce = 100%, Cumulative CPU 5.27 sec
  MapReduce Total cumulative CPU time: 5 seconds 270 msec
  Ended Job = job_1718257463120_0002
  Stage-4 is selected by condition resolver.
  Stage-3 is filtered out by condition resolver.
  Stage-5 is filtered out by condition resolver.
  Moving data to directory hdfs://hd.master:9000/user/hive/warehouse/stu/.hive-staging_hive_2024-07-05_11-21-17_446_3736790412461843961-1/-ext-10000
  Loading data to table default.stu
  MapReduce Jobs Launched:
  Stage-Stage-1: Map: 1  Reduce: 1   Cumulative CPU: 5.27 sec   HDFS Read: 15184 HDFS Write: 235 SUCCESS
  Total MapReduce CPU Time Spent: 5 seconds 270 msec
  OK
  Time taken: 28.236 seconds
  hive> select * from stu;
  OK
  1       ss
  Time taken: 0.314 seconds, Fetched: 1 row(s)
  ```


## Hive服务部署

### hiveserver2服务

Hive的`hiveserver2`服务的作用是提供`jdbc/odbc`接口，为用户提供远程访问Hive数据的功能，例如用户期望在个人电脑中访问远程服务中的Hive数据，就需要用到`Hiveserver2`

> 用户说明
> 在远程访问Hive数据时，客户端并未直接访问Hadoop集群，而是由Hivesever2代理访问。由于Hadoop集群中的数据具备访问权限控制，所以此时需考虑一个问题：那就是访问Hadoop集群的用户身份是谁？是Hiveserver2的启动用户？还是客户端的登录用户？
>
>  答案是都有可能，具体是谁，由Hiveserver2的hive.server2.enable.doAs参数决定，该参数的含义是是否启用Hiveserver2用户模拟的功能。若启用，则Hiveserver2会模拟成客户端的登录用户去访问Hadoop集群的数据，不启用，则Hivesever2会直接使用启动用户访问Hadoop集群数据。模拟用户的功能，默认是开启的。
>
> 生产环境，推荐开启用户模拟功能，因为开启后才能保证各用户之间的权限隔离。

#### `hiveserver2`部署

- Hadoop端配置

  hivesever2的模拟用户功能，依赖于Hadoop提供的proxy user（代理用户功能），只有Hadoop中的代理用户才能模拟其他用户的身份访问Hadoop集群。因此，需要将hiveserver2的启动用户设置为Hadoop的代理用户，配置方式如下：

  修改配置文件core-site.xml，然后记得分发三台机器:

  ```shell
  cd $HADOOP_HOME/etc/hadoop
  vi core-site.xml
  ```

  增加如下配置：

  ```xml
  <!-- 配置访问hadoop的权限，能够让hive访问到 -->
  <property>
      <name>hadoop.proxyuser.root.hosts</name>
      <value>*</value>
  </property>
  <property>
      <name>hadoop.proxyuser.root.users</name>
      <value>*</value>
  </property>
  ```

- Hive端配置

  在hive-site.xml文件中添加如下配置信息:

  ```xml
  <!-- 指定hiveserver2连接的host -->
  <property>
  	<name>hive.server2.thrift.bind.host</name>
  	<value>hadoop001</value>
  </property>
  
  <!-- 指定hiveserver2连接的端口号 -->
  <property>
  	<name>hive.server2.thrift.port</name>
  	<value>10000</value>
  </property>
  ```

- 启动hiveserver2

  ```shell
  bin/hive --service hiveserver2
  ```

  看到如下界面：

  ```shell
  which: no hbase in (/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/usr/local/jdk1.8.0_211/bin:/usr/local/jdk1.8.0_211/jre/bin:/opt/hadoop/hadoop-2.7.5/bin:/opt/hadoop/hadoop-2.7.5/sbin:/usr/local/sqoop-1.4.7.bin__hadoop-2.6.0/bin:/root/bin:/usr/local/jdk1.8.0_211/bin:/usr/local/jdk1.8.0_211/jre/bin:/opt/hadoop/hadoop-2.7.5/bin:/opt/hadoop/hadoop-2.7.5/sbin:/usr/local/sqoop-1.4.7.bin__hadoop-2.6.0/bin:/usr/local/hive-3.1.3/bin)
  2024-07-05 14:25:03: Starting HiveServer2
  SLF4J: Class path contains multiple SLF4J bindings.
  SLF4J: Found binding in [jar:file:/usr/local/hive-3.1.3/lib/log4j-slf4j-impl-2.17.1.jar!/org/slf4j/impl/StaticLoggerBinder.class]
  SLF4J: Found binding in [jar:file:/opt/hadoop/hadoop-2.7.5/share/hadoop/common/lib/slf4j-log4j12-1.7.10.jar!/org/slf4j/impl/StaticLoggerBinder.class]
  SLF4J: See http://www.slf4j.org/codes.html#multiple_bindings for an explanation.
  SLF4J: Actual binding is of type [org.apache.logging.slf4j.Log4jLoggerFactory]
  Hive Session ID = e125189f-0264-4a1d-b914-6393ab34beb8
  Hive Session ID = 604f71b6-ca73-445f-8f8f-9e34e4fde588
  ```

- 使用命令行客户端beeline进行远程访问

  ```shell
  bin/beeline -u jdbc:hive2://hd.master:10000 -n root
  ```

  看到如下界面：

  ```shell
  [root@hd hive-3.1.3]# bin/beeline -u jdbc:hive2://hd.master:10000 -n root
  SLF4J: Class path contains multiple SLF4J bindings.
  SLF4J: Found binding in [jar:file:/usr/local/hive-3.1.3/lib/log4j-slf4j-impl-2.17.1.jar!/org/slf4j/impl/StaticLoggerBinder.class]
  SLF4J: Found binding in [jar:file:/opt/hadoop/hadoop-2.7.5/share/hadoop/common/lib/slf4j-log4j12-1.7.10.jar!/org/slf4j/impl/StaticLoggerBinder.class]
  SLF4J: See http://www.slf4j.org/codes.html#multiple_bindings for an explanation.
  SLF4J: Actual binding is of type [org.apache.logging.slf4j.Log4jLoggerFactory]
  Connecting to jdbc:hive2://hd.master:10000
  Connected to: Apache Hive (version 3.1.3)
  Driver: Hive JDBC (version 3.1.3)
  Transaction isolation: TRANSACTION_REPEATABLE_READ
  Beeline version 3.1.3 by Apache Hive
  0: jdbc:hive2://hd.master:10000>
  ```

### metastore服务

Hive的metastore服务的作用是为Hive CLI或者Hiveserver2提供元数据访问接口。

#### metastore运行模式

metastore有两种运行模式，分别为嵌入式模式和独立服务模式。下面分别对两种模式进行说明：

1. 嵌入式模式

2. 独立服务模式

生产环境中，不推荐使用嵌入式模式。因为其存在以下两个问题：

1. 嵌入式模式下，每个Hive CLI都需要直接连接元数据库，当Hive CLI较多时，数据库压力会比较大。
2. 每个客户端都需要用户元数据库的读写权限，元数据库的安全得不到很好的保证。

#### metastore部署

- 嵌入式模式

  嵌入式模式下，只需保证Hiveserver2和每个Hive CLI的配置文件hive-site.xml中包含连接元数据库所需要的以下参数即可：

  ```xml
  <configuration>
      <!-- jdbc连接的URL -->
      <property>
          <name>javax.jdo.option.ConnectionURL</name>
          <value>jdbc:mysql://10.8.1.166:3306/hive_meta?useSSL=false</value>
      </property>
  
      <!-- jdbc连接的Driver-->
      <property>
          <name>javax.jdo.option.ConnectionDriverName</name>
          <value>com.mysql.cj.jdbc.Driver</value>
      </property>
  
      <!-- jdbc连接的username-->
      <property>
          <name>javax.jdo.option.ConnectionUserName</name>
          <value>root</value>
      </property>
  
      <!-- jdbc连接的password -->
      <property>
          <name>javax.jdo.option.ConnectionPassword</name>
          <value>QingCheng1234567890.</value>
      </property>
  </configuration>
  ```

- 独立服务模式
  独立服务模式需做以下配置：
  首先，保证metastore服务的配置文件hive-site.xml中包含连接元数据库所需的以下参数：

  ```xml
  <configuration>
      <!-- jdbc连接的URL -->
      <property>
          <name>javax.jdo.option.ConnectionURL</name>
          <value>jdbc:mysql://10.8.1.166:3306/hive_meta?useSSL=false</value>
      </property>
  
      <!-- jdbc连接的Driver-->
      <property>
          <name>javax.jdo.option.ConnectionDriverName</name>
          <value>com.mysql.cj.jdbc.Driver</value>
      </property>
  
      <!-- jdbc连接的username-->
      <property>
          <name>javax.jdo.option.ConnectionUserName</name>
          <value>root</value>
      </property>
  
      <!-- jdbc连接的password -->
      <property>
          <name>javax.jdo.option.ConnectionPassword</name>
          <value>QingCheng1234567890.</value>
      </property>
  </configuration>
  ```

  其次，保证Hiveserver2和每个Hive CLI的配置文件hive-site.xml中包含访问metastore服务所需的以下参数：

  ```xml
  <!-- 指定metastore服务的地址 -->
  <property>
  	<name>hive.metastore.uris</name>
  	<value>thrift://hd.master:9083</value>
  </property>
  ```

  > 注意：主机名需要改为metastore服务所在节点，端口号无需修改，metastore服务的默认端口就是9083。

- 启动metastore

  ```shell
  hive --service metastore
  ```

- 测试

  此时启动Hive CLI，执行show databases语句，正常执行就没问题了

### 编写Hive服务启动脚本

前台启动的方式导致需要打开多个窗口，可以使用如下方式后台方式启动
nohup：放在命令开头，表示不挂起，也就是关闭终端进程也继续保持运行状态
/dev/null：是Linux文件系统中的一个文件，被称为黑洞，所有写入该文件的内容都会被自动丢弃
2>&1：表示将错误重定向到标准输出上
&：放在命令结尾，表示后台运行
一般会组合使用：nohup [xxx命令操作]> file 2>&1 &，表示将xxx命令运行的结果输出到file中，并保持命令启动的进程在后台运行。

```shell
nohup hive --service metastore 2>&1 &
nohup hive --service hiveserver2 2>&1 &
```

为了方便使用，可以直接编写脚本来管理服务的启动和关闭

```
vi $HIVE_HOME/bin/hive-script.sh
```

```shell
#!/bin/bash
# 一键启动、停止、查看Hive的metastore和hiveserver2两个服务的脚本
function start_metastore {
  # 启动Hive metastore服务
  hive --service metastore >/dev/null 2>&1 &
  for i in {1..30}; do
    if is_metastore_running; then
      echo "Hive metastore服务已经成功启动！"
      return 0
    else
      sleep 1 # 等待1秒
    fi
  done
  echo "Hive metastore服务启动失败，请查看日志！"
  return 1
}
function stop_metastore {
  # 停止Hive metastore服务
  ps -ef | grep hive.metastore | grep -v grep | awk '{print $2}' | xargs -r kill -9 >/dev/null 2>&1
  if is_metastore_running; then
    echo "Hive metastore服务停止失败，请检查日志！"
    return 1
  else
    echo "Hive metastore服务已经成功停止！"
    return 0
  fi
}
function start_hiveserver2 {
  # 启动HiveServer2服务
  hive --service hiveserver2 >/dev/null 2>&1 &
  for i in {1..30}; do
    if is_hiveserver2_running; then
      echo "HiveServer2服务已经成功启动！"
      return 0
    else
      sleep 1 # 等待1秒
    fi
  done
  echo "HiveServer2服务启动失败，请查看日志！"
  return 1
}
function stop_hiveserver2 {
  # 停止HiveServer2服务
  ps -ef | grep hiveserver2 | grep -v grep | awk '{print $2}' | xargs -r kill -9 >/dev/null 2>&1
  if is_hiveserver2_running; then
    echo "HiveServer2服务停止失败，请检查日志！"
    return 1
  else
    echo "HiveServer2服务已经成功停止！"
    return 0
  fi
}
function is_metastore_running {
  # 检查Hive metastore服务是否在运行
  ps -ef | grep hive.metastore | grep -v grep >/dev/null 2>&1
}
function is_hiveserver2_running {
  # 检查HiveServer2服务是否在运行
  ps -ef | grep hiveserver2 | grep -v grep >/dev/null 2>&1
}
# 检查参数
if [ "$1" = "start" ]; then
  if start_metastore && start_hiveserver2; then
    exit 0
  else
    exit 1
  fi
elif [ "$1" = "stop" ]; then
  if stop_hiveserver2 && stop_metastore; then
    exit 0
  else
    exit 1
  fi
elif [ "$1" = "status" ]; then
  if is_metastore_running; then
    echo "Hive metastore服务正在运行！"
  else
    echo "Hive metastore服务未运行！"
  fi
  if is_hiveserver2_running; then
    echo "HiveServer2服务正在运行！"
  else
    echo "HiveServer2服务未运行！"
  fi
else
  echo "Usage: $0 [start|stop|status]"
  exit 1
fi
```

##### 添加执行权限

```shell
chmod +x $HIVE_HOME/bin/hive-script.sh
```

##### 启动Hive后台服务

```shell
hive-script.sh start
hive-script.sh status
hive-script.sh stop
```
