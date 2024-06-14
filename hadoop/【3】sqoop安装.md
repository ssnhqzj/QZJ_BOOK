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

