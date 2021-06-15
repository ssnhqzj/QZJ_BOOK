# docker安装es集群
# 说明
本次安装在一台服务器上完成，多台服务器安装步骤一样，只需要在涉及IP配置的地方做相应调整即可。

## 1. 环境准备
### 1.1 修改Linux配置
```shell script
sudo vim /etc/sysctl.conf
vm.max_map_count=262144

#不重启， 直接生效当前的命令
sysctl -w vm.max_map_count=262144
```

### 1.2 创建配置和数据文件夹 
模拟3个节点，所以需要创建3套配置和数据文件夹，如果是多台服务器安装，每个服务器上创建一套文件夹即可。
```shell script
# es01
mkdir -p /opt/es-cluster/es01/data
mkdir -p /opt/es-cluster/es01/logs
mkdir -p /opt/es-cluster/es01/plugins

# es02
mkdir -p /opt/es-cluster/es02/data
mkdir -p /opt/es-cluster/es02/logs
mkdir -p /opt/es-cluster/es02/plugins

# es03
mkdir -p /opt/es-cluster/es03/data
mkdir -p /opt/es-cluster/es03/logs
mkdir -p /opt/es-cluster/es03/plugins

# kibana
mkdir -p /opt/kibana/config

# es的用户id为1000，这里暂且授权给所有人
sudo chmod 777 /opt/es-cluster -R
```

### 2 拉取镜像
```shell script
docker pull docker.elastic.co/elasticsearch/elasticsearch:7.6.2
```

### 3 创建es配置文件，每个节点对应一个配置文件
```shell script
# vim /opt/es-cluster/es01/es.yml

cluster.name: kf-es-cluster
node.name: es-node01
network.host: 0.0.0.0
network.publish_host: 172.16.119.181
http.port: 9201
transport.tcp.port: 9301
http.cors.enabled: true
http.cors.allow-origin: "*"
node.master: true
node.data: true
discovery.seed_hosts: ["172.16.119.181:9301","172.16.119.181:9302","172.16.119.181:9303"]
cluster.initial_master_nodes: ["172.16.119.181:9301","172.16.119.181:9302","172.16.119.181:9303"]
# -----------------------------------------------------------------------------------------------#
# vim /opt/es-cluster/es02/es.yml

cluster.name: kf-es-cluster
node.name: es-node02
network.host: 0.0.0.0
network.publish_host: 172.16.119.181
http.port: 9202
transport.tcp.port: 9302
http.cors.enabled: true
http.cors.allow-origin: "*"
node.master: true
node.data: true
discovery.seed_hosts: ["172.16.119.181:9301","172.16.119.181:9302","172.16.119.181:9303"]
cluster.initial_master_nodes: ["172.16.119.181:9301","172.16.119.181:9302","172.16.119.181:9303"]
# -----------------------------------------------------------------------------------------------#
# vim /opt/es-cluster/es03/es.yml

cluster.name: kf-es-cluster
node.name: es-node03
network.host: 0.0.0.0
network.publish_host: 172.16.119.181
http.port: 9203
transport.tcp.port: 9303
http.cors.enabled: true
http.cors.allow-origin: "*"
node.master: true
node.data: true
discovery.seed_hosts: ["172.16.119.181:9301","172.16.119.181:9302","172.16.119.181:9303"]
cluster.initial_master_nodes: ["172.16.119.181:9301","172.16.119.181:9302","172.16.119.181:9303"]
# -----------------------------------------------------------------------------------------------#
```
> 需要注意的是以上配置中使用的ip不能替换成localhost或127.0.0.1，因为此配置文件是在docker容器中使用的，localhost或127.0.0.1代表
> 容器并非主机，无法完成集群注册

### 4 启动容器
#### 启动es01
```shell script
docker run \
-e ES_JAVA_OPTS="-Xms256m -Xmx256m" -d \
-p 9201:9201 \
-p 9301:9301 \
-v /opt/es-cluster/es01/es.yml:/usr/share/elasticsearch/config/es.yml \
-v /opt/es-cluster/es01/data:/usr/share/elasticsearch/data \
-v /opt/es-cluster/es01/logs:/usr/share/elasticsearch/logs \
-v /opt/es-cluster/es01/plugins:/usr/share/elasticsearch/plugins \
--name es01 elasticsearch:7.6.2
```

#### 启动es02
```shell script
docker run \
-e ES_JAVA_OPTS="-Xms256m -Xmx256m" -d \
-p 9202:9202 \
-p 9302:9302 \
-v /opt/es-cluster/es02/es.yml:/usr/share/elasticsearch/config/es.yml \
-v /opt/es-cluster/es02/data:/usr/share/elasticsearch/data \
-v /opt/es-cluster/es02/logs:/usr/share/elasticsearch/logs \
-v /opt/es-cluster/es02/plugins:/usr/share/elasticsearch/plugins \
--name es01 elasticsearch:7.6.2
```

#### 启动es03
```shell script
docker run \
-e ES_JAVA_OPTS="-Xms256m -Xmx256m" -d \
-p 9203:9203 \
-p 9303:9303 \
-v /opt/es-cluster/es03/es.yml:/usr/share/elasticsearch/config/es.yml \
-v /opt/es-cluster/es03/data:/usr/share/elasticsearch/data \
-v /opt/es-cluster/es03/logs:/usr/share/elasticsearch/logs \
-v /opt/es-cluster/es03/plugins:/usr/share/elasticsearch/plugins \
--name es01 elasticsearch:7.6.2
```

### 5 验证是否启动成功
```shell script
curl http://172.16.119.181:9201/_cluster/health
```
返回如下则启动成功
```json
{
    "cluster_name":"kf-es-cluster",
    "status":"green",
    "timed_out":false,
    "number_of_nodes":3,
    "number_of_data_nodes":3,
    "active_primary_shards":4,
    "active_shards":8,
    "relocating_shards":0,
    "initializing_shards":0,
    "unassigned_shards":0,
    "delayed_unassigned_shards":0,
    "number_of_pending_tasks":0,
    "number_of_in_flight_fetch":0,
    "task_max_waiting_in_queue_millis":0,
    "active_shards_percent_as_number":"100.0"
}
```
> 集群的状态（status）：red红表示集群不可用，有故障。yellow黄表示集群不可靠但可用，一般单节点时就是此状态。green正常状态，
> 表示集群一切正常

### 6 安装kibana
kibana是一个查看es数据的可视化工具

#### 6.1 编辑配置文件
```shell script
# vim /opt/es-cluster/config/kibana.yml

# Default Kibana configuration for docker target
server.name: kibana
server.host: "0"
elasticsearch.hosts: [ "http://172.16.119.181:9201","http://172.16.119.181:9202","http://172.16.119.181:9203" ]
xpack.monitoring.ui.container.elasticsearch.enabled: true
```
> 修改配置文件中的ip为自己的服务器ip

#### 6.2访问kibana
```
http://39.101.160.196:5601/
```




