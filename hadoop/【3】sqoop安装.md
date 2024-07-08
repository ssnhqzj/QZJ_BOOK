# sqoop安装
## 安装前准备
在安装sqoop之前要配置好本机的Java环境和Hadoop环境
先下载sqoop的安装包sqoop-1.4.7.bin__hadoop-2.6.0.tar.gz
> 注意：不能下载sqoop-1.4.7.tar.gz包不然会出现Could not find or load main class org.apache.sqoop.Sqoop异常

## 解压配置环境变量
```shell
# 解压tar.gz包
[root@qianfeng01 local] tar -zxvf /root/sqoop-1.4.7.bin__hadoop-2.6.0.tar.gz -C /usr/local/

#把sqoop的安装路径修改为sqoop,方便以后配置和调用
[root@qianfeng01 local]# mv  sqoop-1.4.7.bin__hadoop-2.6.0 sqoop-1.4.7
[root@qianfeng01 sqoop-1.4.7]# vi /etc/profile
# 追加内容如下:
export SQOOP_HOME=/usr/local/sqoop-1.4.7
export PATH=$PATH:$SQOOP_HOME/bin

# 使配置生效
[root@qianfeng01 sqoop-1.4.7]# source /etc/profile
```

## 修改配置文件
```shell
# 拷贝一个配置文件
[root@qianfeng01 sqoop-1.4.7] mv ./conf/sqoop-env-template.sh ./conf/sqoop-env.sh
# 修改配置文件
[root@qianfeng01 sqoop-1.4.7] vi ./conf/sqoop-env.sh
# 按照本系统实际安装的Hadoop系列目录配置好下面的路径:
export HADOOP_COMMON_HOME=/usr/local/hadoop-2.7.5/
export HADOOP_MAPRED_HOME=/usr/local/hadoop-2.7.5/
# 如果要使用hive，则配置hive的安装路径
export HIVE_HOME=/usr/local/hive-2.1.1/
# 如果要使用zookeeper，则配置zookeeper的安装路径
export ZOOCFGDIR=/usr/local/zookeeper-3.4.10/
```

## 拷贝mysql驱动
因为我们现在通过JDBC让Mysql和HDFS等进行数据的导入导出,所以我们先必须把JDBC的驱动包拷贝到sqoop/lib路径下,如下
```shell
[root@qianfeng01 sqoop1.4.7] cp /root/mysql-connector-java-5.1.18.jar ./lib/
```
## 验证安装：
```shell
#查看sqoop的版本
[root@qianfeng01 sqoop1.4.7] sqoop version
```

## 常见命令执行参数
通过sqoop加不同参数可以执行导入导出,通过sqoop help 可以查看常见的命令行
```shell
#常见sqoop参数
[root@qianfeng01 sqoop- 1.4.7] sqoop help
codegen            Generate code to interact with database records
create-hive-table  Import a table definition into Hive
eval               Evaluate a SQL statement and display the results
export             Export an HDFS directory to a database table #导出
help               List available commands
import             Import a table from a database to HDFS  #导入
import-all-tables  Import tables from a database to HDFS
import-mainframe   Import mainframe datasets to HDFS
list-databases     List available databases on a server
list-tables        List available tables in a database
version            Display version information
```
## 直接执行命令
Sqoop运行的时候不需要启动后台进程,直接执行sqoop命令加参数即可.简单举例如下:
```shell
# #通过参数用下面查看数据库
[root@qianfeng01 sqoop-1.4.7] sqoop list-databases --connect jdbc:mysql://10.8.1.161:3306/ --username root --password QingCheng1234567890.
```

## Import的控制参数
常见Import的控制参数有如下几个:

|   Argument   |  Description    |
| ---- | ---- |
|--append	|通过追加的方式导入到HDFS|
|--as-avrodatafile	|导入为 Avro Data 文件格式|
|--as-sequencefile	|导入为 SequenceFiles文件格式|
|--as-textfile	|导入为文本格式 (默认值)|
|--as-parquetfile	|导入为 Parquet 文件格式|
|--columns	|指定要导入的列|
|--delete-target-dir	|如果目标文件夹存在,则删除|
|--fetch-size	|一次从数据库读取的数量大小|
|-m,--num-mappers	|用来指定map tasks的数量,用来做并行导入|
|-e,--query	|指定要查询的SQL语句|
|--split-by	|用来指定分片的列|
|--table	|需要导入的表名|
|--target-dir	|HDFS 的目标文件夹|
|--where	|用来指定导入数据的where条件|
|-z,--compress	|是否要压缩|
|--compression-codec	|使用Hadoop压缩 (默认是 gzip)|

## 指定表导入
```shell
[root@qianfeng01 sqoop1.4.7]# sqoop import --connect jdbc:mysql://10.8.1.161:3306/crm-system --username root --password QingCheng1234567890. \
--table sys_account \
--target-dir hdfs://10.8.1.189:9000/user/qzj/sys_account \
--delete-target-dir
```

## 单双引号区别
在导入数据时,默认的字符引号是单引号,这样sqoop在解析的时候就安装字面量来解析,不会做转移:例如:

```shell
--query 'select empno,mgr,job from emp WHERE empno>7800 and $CONDITIONS'  \
```


如果使用了双引号,那么Sqoop在解析的时候会做转义的解析,这时候就必须要加转义字符: 如下:

```shell
--query "select empno,mgr,job from emp WHERE empno>7800 and \$CONDITIONS" \
```

##  MySql缺主键问题
1、如果mysql的表没有主键，将会报错：

```shell
19/12/02 10:39:50 ERROR tool.ImportTool: Import 
failed: No primary key could be found for table u1. Please specify one with 
-- split-  by or perform a sequential import with '-m 1
```


解决方案:

通过 --split-by 来指定要分片的列

