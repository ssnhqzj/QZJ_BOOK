# Hadoop集群搭建
准备3台服务器
- 10.8.1.189  hd.master
- 10.8.1.190  hd.slave1
- 10.8.1.191  hd.slave2

## 设置主机名
```shell
vi /etc/sysconfig/network

NETWORKING=yes
HOSTNAME=hd.master
```
再次修改主机名字，将hostname中内容删除掉，增加hd.master名字操作
```shell
vi /etc/hostname

hd.master
```
按照上述操作方法，将其他的虚拟机更改主机名字，对应的hd.slave1,hd.slave2都修改,修改完记得重启验证一下，主机名字是否更变.

##  hosts设置
```shell
vi /etc/hosts

# 追加以下内容
10.8.1.189  hd.master
10.8.1.190  hd.slave1
10.8.1.191  hd.slave2
```

## 配置免密登录
略，参考免密登录配置......

## 安装JDK
略，参考JDK安装配置......

## Hadoop安装与环境配置
先用下面的命令给opt文件夹中新建一个hadoop文件夹，后期配置hadoop文件
```shell
mkdir /opt/hadoop
```
然后把hadoop-2.7.5复制到hadoop文件夹中,使用下面命令进入到hadoop文件夹，进行解压
```shell
cd /opt/hadoop
tar -zxvf hadoop-2.7.5.tar.gz
```
### 在主服务器master上配置
#### 1.配置hadoop-env.sh
该文件设置的是Hadoop运行时需要的环境变量。JAVA_HOME是必须设置的，即使我们当前的系统设置了JAVA_HOME，它也是不认识的，因为Hadoop即使是在本机上执行，它也是把当前执行的环境当成远程服务器。所以这里设置的目的是确保Hadoop能正确的找到jdk。
在hadoop文件中找到hadoop-env.sh文件进行修改，配置java的路径。
```shell
export JAVA_HOME=/usr/local/jdk1.8.0_211
```
#### 2. 配置core-site.xml
core-site.xm所在的目录和上面的目录一样，所以直接使用下面命令打开该文件即可
```shell
cd /opt/hadoop/hadoop/etc/hadoop
vi core-site.xml
```
接着把下面命令写入<configuration></configuration>中，注释不用写
```shell
<!-- 指定Hadoop所使用的文件系统schema(URL),HDFS的老大(NameNode)的地址 -->
<property>
	<name>fs.defaultFS</name>
	<value>hdfs://master:9000</value>
</property>
<!-- 指定Hadoop运行时产生文件的储存目录，默认是/tmp/hadoop-${user.name} -->
<property>
	<name>hadoop.tmp.dir</name>
	<value>/opt/hadoop/hadoopdata</value>
</property>
```
#### 3.配置hdfs-site.xml
hdfs-site.xml所在的目录和上面的目录一样，所以直接使用下面命令打开该文件即可
```shell
vi hdfs-site.xml
```
接着把下面命令写入<configuration></configuration>中，注释不用写
```shell
<!-- 指定HDFS副本的数量 -->
<property>
	<name>dfs.replication</name>
	<value>1</value>
</property>
<property>
    <name>dfs.namenode.secondary.http-address</name>
    <value>hd.master:50090</value>
</property>
```
#### 4.配置yarn-site.xml
yarn-site.xml所在的目录和上面的目录一样，所以直接使用下面命令打开该文件即可
```shell
vi yarn-site.xml
```
接着把下面命令写入<configuration></configuration>中，里面自带的注释不用删除
```shell
<property>
	<name>yarn.nodemanager.aux-services</name>
	<value>mapreduce_shuffle</value>
</property>
<property>
	<name>yarn.resourcemanager.address</name>
	<value>hd.master:18040</value>
</property>
<property>
	<name>yarn.resourcemanager.scheduler.address</name>
	<value>hd.master:18030</value>
</property>
<property>
	<name>yarn.resourcemanager.resource-tracker.address</name>
	<value>hd.master:18025</value>
</property>
<property>
	<name>yarn.resourcemanager.admin.address</name>
	<value>hd.master:18141</value>
</property>
<property>
	<name>yarn.resourcemanager.webapp.address</name>
	<value>hd.master:18088</value>
</property>
```
#### 5.配置mapred-site.xml
还是在/opt/hadoop/hadoop/etc/hadoop目录下(也就是上个文件所在的目录)，有一个叫 mapred-site.xml.template的文件，把它复制到/opt/hadoop/hadoop/etc/hadoop目录下(也就是mapred-queues.xml.template文件所在的目录)重命名为mapred-site.xml，命令如下
```shell
mv mapred-site.xml.template mapred-site.xml
```
编辑文本
```shell
vi mapred-site.xml
```
接着把下面命令写入<configuration></configuration>中，注释不用写
```shell
<!-- 指定mr运行时框架，这里指定在yarn上，默认是local -->
<property>
	<name>mapreduce.framework.name</name>
	<value>yarn</value>
</property>
```
#### 6.配置slaves
slaves 文件给出了 Hadoop 集群的 Slave 节点列表。该文件十分重要，因为启动Hadoop 的时候，系统总是根据当前 slaves 文件中 Slave 节点名称列表启动集群，不在列表中的Slave节点便不会被视为计算节点.
slaves所在的目录和上面的目录一样，所以直接使用下面命令打开该文件即可
```shell
cd /opt/hadoop/hadoop/etc/hadoop
vi slaves
```
增加以下文字内容，进行配置。
```shell
hd.master
hd.slave1
hd.slave2
```
#### 7.配置Hadoop环境变量
先用cd命令回到总目录
编辑环境变量配置
```shell
vi /root/.bash_profile
```
增加以下内容，将Hadoop的环境变量配置到系统中。
```shell
export HADOOP_HOME=/opt/hadoop/hadoop
export PATH=$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$PATH
```
保存文件，使用source功能加载环境变量。
```shell
source /root/.bash_profile
```
#### 8.新建Hadoop运行时产生文件的储存目录
先用cd命令回到总目录,
接着用下面命令新建目录
```shell
mkdir /opt/hadoop/hadoopdata
```
#### 9.给hd.slave1和hd.slave2复制Hadoop
用下面命令就可以把hd.master的Hadoop复制到hd.slave1，hd.slave2上
```shell
scp -r /opt/hadoop root@hd.slave1:/opt
scp -r /opt/hadoop root@hd.slave1:/opt
```
接着用下面命令把hd.master的环境变量复制到hd.slave1，hd.slave2上
```shell
scp -r /root/.bash_profile root@hd.slave1:/root
scp -r /root/.bash_profile root@hd.slave2:/root
```
然后在hd.slave1中输入下面内容使环境变量生效
```shell
source /root/.bash_profile
```
#### 10.格式化文件系统
在master中输入下面命令格式化文件系统，其余俩台服务器不用，注意该命令只能使用一次
```shell
hadoop namenode -format
```
#### 11.启动Hadoop
在master服务器上，先用下面命令进入Hadoop的sbin目录
```shell
cd /opt/hadoop/hadoop/sbin
```
然后输入下面命令启动
```shell
start-all.sh
```
在三台服务器分别输入jps可以判断是否启动成功，出现下面内容说明成功
```shell

```
#### 12.关闭Hadoop
只需要在master服务器输入下面命令即可，三个服务器正常停止hadoop的操作。
```shell
stop-all.sh
```
#### 浏览器访问web界面 http://hd.master:50070/

