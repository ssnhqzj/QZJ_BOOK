前提
官网下载kafka_2.11-2.3.0.tgz
https://www.apache.org/dyn/closer.cgi?path=/kafka/2.3.0/kafka_2.11-2.3.0.tgz
已安装zookeeper：
教程：https://blog.csdn.net/sndayYU/article/details/100537922
三台服务器192.168.230.128:2181,192.168.230.129:2181,192.168.230.130:2181
单机
下面以服务器192.168.230.128为例

安装
1.利用xftp复制到/usr/local/，并解压，创建日志目录
tar -zxvf /usr/local/kafka_2.11-2.3.0.tgz -C /usr/local
mkdir -p /data/kafka-logs
1
2
2.修改配置文件config/server.properties下面参数

# 单机模式，ip改为服务器的ip
listeners=PLAINTEXT://192.168.230.130:9092
# 自定义目录
log.dirs=/data/kafka-logs
# 注册中心
zookeeper.connect=192.168.230.128:2181,192.168.230.129:2181,192.168.230.130:2181

3.启动

[root@localhost /]# cd /usr/local/kafka_2.11-2.3.0/
[root@localhost kafka_2.11-2.3.0]# bin/kafka-server-start.sh config/server.properties &
验证
// 创建topic
[root@localhost kafka_2.11-2.3.0]# ./bin/kafka-topics.sh --create --zookeeper 192.168.230.130:2181 --replication-factor 1 --partitions 3 --topic MY_KAFKA_TOPIC
// 访问topic
[root@localhost kafka_2.11-2.3.0]# ./bin/kafka-topics.sh --describe --zookeeper 192.168.230.130:2181 --topic MY_KAFKA_TOPIC
Topic:MY_KAFKA_TOPIC	PartitionCount:3	ReplicationFactor:1	Configs:
	Topic: MY_KAFKA_TOPIC	Partition: 0	Leader: 0	Replicas: 0	Isr: 0
	Topic: MY_KAFKA_TOPIC	Partition: 1	Leader: 0	Replicas: 0	Isr: 0
	Topic: MY_KAFKA_TOPIC	Partition: 2	Leader: 0	Replicas: 0	Isr: 0

–replication-factor 1 --partitions 3 ：创建一个副本、3个分区；
xshell打开两个192.168.230.130的窗口

// 窗口1--启动生产者
cd /usr/local/kafka_2.11-2.3.0/
./bin/kafka-console-producer.sh --broker-list 192.168.230.130:9092 --topic MY_KAFKA_TOPIC

// 窗口2---启动消费者
cd /usr/local/kafka_2.11-2.3.0/
./bin/kafka-console-consumer.sh --bootstrap-server 192.168.230.130:9092  --topic MY_KAFKA_TOPIC  --from-beginning

启动后生产者发送消息，可以看到消费者中可以收到消息