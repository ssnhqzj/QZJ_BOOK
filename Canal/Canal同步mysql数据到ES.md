## ElasticSearch适配器

> 开始使用官方提供的包测试，各种问题，最后下载源码包debug测试，才逐步解决问题。

### 修改启动器配置: application.yml

```yaml
server:
  port: 8081
spring:
  jackson:
    date-format: yyyy-MM-dd HH:mm:ss
    time-zone: GMT+8
    default-property-inclusion: non_null

canal.conf:
  mode: tcp # kafka rocketMQ
  canalServerHost: 127.0.0.1:11111
#  zookeeperHosts: slave1:2181
#  mqServers: 127.0.0.1:9092 #or rocketmq
#  flatMessage: true
  batchSize: 500
  syncBatchSize: 1000
  retries: 0
  timeout:
  accessKey:
  secretKey:
# mysql数据库连接信息
  srcDataSources:
    defaultDS:
      url: jdbc:mysql://127.0.0.1:3306/canaltest?useUnicode=true
      username: root
      password: 123456
  canalAdapters:
  - instance: example # canal instance Name or mq topic name
    groups:
    - groupId: g1
      outerAdapters:
      - name: logger
#      - name: rdb
#        key: mysql1
#        properties:
#          jdbc.driverClassName: com.mysql.jdbc.Driver
#          jdbc.url: jdbc:mysql://127.0.0.1:3306/mytest2?useUnicode=true
#          jdbc.username: root
#          jdbc.password: 121212
#      - name: rdb
#        key: oracle1
#        properties:
#          jdbc.driverClassName: oracle.jdbc.OracleDriver
#          jdbc.url: jdbc:oracle:thin:@localhost:49161:XE
#          jdbc.username: mytest
#          jdbc.password: m121212
#      - name: rdb
#        key: postgres1
#        properties:
#          jdbc.driverClassName: org.postgresql.Driver
#          jdbc.url: jdbc:postgresql://localhost:5432/postgres
#          jdbc.username: postgres
#          jdbc.password: 121212
#          threads: 1
#          commitSize: 3000
#      - name: hbase
#        properties:
#          hbase.zookeeper.quorum: 127.0.0.1
#          hbase.zookeeper.property.clientPort: 2181
#          zookeeper.znode.parent: /hbase
# es连接信息
      - name: es
        hosts: 192.168.36.200:9200 # 127.0.0.1:9200 for rest mode
        properties:
          mode: rest # or rest
          # security.auth: test:123456 #  only used for rest mode
          cluster.name: docker-cluster
```
> * adapter将会自动加载 conf/es 下的所有.yml结尾的配置文件 
> * es的配置中name属性是es，无论是es6还是es7（开始使用es7报错，调试源码才发现是es）
> * 1.14版本同步到es7未成功，后缓存es6.7后成功

## 适配器表映射文件

conf/es目录下新建一个yaml文件，命名随意，内容如下：

```yaml
dataSourceKey: defaultDS
destination: example
groupId: g1
esMapping:
  _index: canal_test_user
  _type: _doc
  _id: _id
  upsert: true
#  pk: id
  sql: "select a.id as _id, a.user_name, a.user_age, a.user_sex from canal_test_user a"
#  objFields:
#    _labels: array:;
#  etlCondition: "where a.c_time>={}"
  commitBatch: 3000

```
> * sql中除_id需要使用别名，其他字段无需使用别名
> * 其中使用到的mysql表创建步骤省略

## 手动创建es索引和mapping
略

## 启动

在bin目录下执行脚本启动
```shell script
sh startup.sh
```

## 全量同步
### 1. 全量同步需要手动调用api,测试ok,如下：
```shell script
curl http://127.0.0.1:8081/etl/es/canaltest.yml -X POST
curl http://127.0.0.1:8881/etl/rdb/mysql1/sys_user.yml -X POST -d "params=1;100000"
```

### 2. 全量同步数据量较大会提示超时
查看 canal 源码得知当同步的数据量大于1w时，会分批进行同步，每批1w条记录，并使用多线程来并行执行任务，而 adapter 默认的连接池为3，
当线程获取数据库连接等待超过1分钟就会抛出该异常。
解决方案：
修改 adapter 的 conf/application.yml 文件中的 srcDataSources下的数据源配置下（如defaultDS下），增加 maxActive 配置数据库的
最大连接数为当前服务器cpu的可用线程数
```shell script
# cpu线程数可以下命令查看
grep 'processor' /proc/cpuinfo | sort -u | wc -l


```


## 遇到问题1
前面提到的application.yml中的es配置名称是"es", 看官方文档中注释的是es6或es7,以为需要配置es6
或者es7,通过调试源码,实则不然

## 遇到问题2
使用es7提示错误信息，找不到索引XXX,查看issues中有人说无法同步到es7，es6没问题，换成es6后无此问题

## 遇到问题3
空指针异常，调试源码发现有个地方获取es字段时用小写名称去获取，但是map中存储的是大写，源码改成转换成大写
后获取
```java 
public Object getValFromData(ESMapping mapping, Map<String, Object> dmlData, String fieldName, String columnName) {
        String esType = getEsType(mapping, fieldName);
        Object value = dmlData.get(columnName.toUpperCase());
        if (value instanceof Byte) {
            if ("boolean".equals(esType)) {
                value = ((Byte) value).intValue() != 0;
            }
        }

        // 如果是对象类型
        if (mapping.getObjFields().containsKey(fieldName)) {
            return ESSyncUtil.convertToEsObj(value, mapping.getObjFields().get(fieldName));
        } else {
            return ESSyncUtil.typeConvert(value, esType);
        }
    }
```
> * 修改上边方法中的 dmlData.get(columnName.toUpperCase());
> * 重新rebuild下项目，mvn install 打包，拷贝maven仓库中的client-adapter.elasticsearch-1.1.4-jar-with-dependencies.jar
>   覆盖官方包中的plugin下的相应jar，测试ok

## 遇到问题4
启动适配器时提示连接数据库空指针异常，原因是由于adapter中使用的mysql的jar和数据库版本不匹配，需要做如下修改
### 1. mysql连接器jar拷贝到canal.adapter-1.1.4/lib目录中
例如我的数据版本是8.0.*的，我将mysql-connector-java-8.0.15.jar拷贝到canal.adapter-1.1.4/lib目录中

### 2. 修改pom.xml文件中的mysql依赖
pom文件在一下路径中
canal.adapter-1.1.4\plugin\client-adapter.rdb-1.1.4-jar-with-dependencies.jar\META-INF\maven\com.alibaba.otter\client-adapter.rdb
替换之前的mysql-connector-java内容：
```shell script
<dependency>
    <groupId>mysql</groupId>
    <artifactId>mysql-connector-java</artifactId>
    <version>8.0.15</version>
    <scope>test</scope>
</dependency>
```





