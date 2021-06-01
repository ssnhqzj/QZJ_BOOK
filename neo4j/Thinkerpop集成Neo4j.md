## 1.下载Thinkerpop server
```
https://www.apache.org/dyn/closer.lua/tinkerpop/3.5.0/apache-tinkerpop-gremlin-server-3.5.0-bin.zip
```

## 2.安装Thinkerpop
```shell script
#直接解压zip包即可
unzip apache-tinkerpop-gremlin-server-3.5.0-bin.zip -d /usr/local/
```

## 3.集成NEO4J
Neo4j是目前使用最广泛的图数据库，缺点就是企业版收费略贵，社区版又不支持HA。通过Tinkerpop集成Neo4j，
首先可以通过gremlin来访问数据库，方便迁移。另外比较重要的一点就是Tinkerpop集成Neo4j可以支持HA。下面操作都以Tinkerpop Server 3.5.0为例。
3.5.0支持的neo4j版本是3.4.11

### 3.1安装neo4j依赖
```shell script
bin/gremlin-server.sh install org.apache.tinkerpop neo4j-gremlin 3.5.0
```

### 3.2修改配置文件
根据需要修改conf/neo4j-empty.properties文件，主要就是db目录
修改conf/gremlin-server-neo4j.yaml的host和port
启动Tinkerpop Server即可。