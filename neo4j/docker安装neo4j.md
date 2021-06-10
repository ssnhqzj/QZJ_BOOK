一、创建数据目录
```
mkdir -p neo4jdata/neo4j-1/data
mkdir -p neo4jdata/neo4j-1/logs
mkdir -p neo4jdata/neo4j-1/conf
mkdir -p neo4jdata/neo4j-1/metrics
mkdir -p neo4jdata/neo4j-1/plugins
mkdir -p neo4jdata/neo4j-1/import
mkdir -p neo4jdata/neo4j-1/data
```

二、拉取镜像（Neo4j的官方Docker镜像https://hub.docker.com/_/neo4j）
```
docker pull neo4j
```
三、启动容器（务必关闭selinux）
```
docker run -d --name neo4j -e NEO4J_AUTH=neo4j/123456 --net=host --privileged=true \
-p 7474:7474 -p 7687:7687  \
-v /opt/neo4j/data:/var/lib/neo4j/data \
-v /opt/neo4j/logs:/var/lib/neo4j/logs \
-v /opt/neo4j/conf:/var/lib/neo4j/conf \
-v /opt/neo4j/metrics:/var/lib/neo4j/metrics \
-v /opt/neo4j/plugins:/var/lib/neo4j/plugins \
-v /opt/neo4j/import:/var/lib/neo4j/import \
-v /opt/neo4j/data:/var/lib/neo4j/data \
neo4j:latest

```
四、查看容器状态及日志
```
docker ps -a | grep neo4j-1
docker logs neo4j-1
docker inspect neo4j-1
```
五、修改容器为自启动
```
docker container update --restart=always neo4j-1
```
六、web连接
