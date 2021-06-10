# 配置
## 引入maven依赖

```xml
<dependency>
    <groupId>org.apache.shardingsphere</groupId>
    <artifactId>sharding-jdbc-spring-boot-starter</artifactId>
    <version>4.1.1</version>
</dependency>

<dependency>
    <groupId>com.alibaba</groupId>
    <artifactId>druid</artifactId>
    <version>1.1.22</version>
</dependency>
```
> druid依赖不能使用druid-spring-boot-starter，提示"Failed to determine a suitable driver class"
> 错误，直接依赖druid包

## 规则配置

```yaml
spring:
    shardingsphere:
        props:
            sql:
                show: true
        # 数据源配置
        datasource:
            names: ds0,ds1
            ds0:
                type: com.alibaba.druid.pool.DruidDataSource
                driver-class-name: com.mysql.jdbc.Driver
                url: jdbc:mysql://192.168.21.129:3306/sharding_dev_0?characterEncoding=UTF-8&useUnicode=true&useSSL=false&autoReconnect=true&failOverReadOnly=false
                username: root
                password: 123456
            ds1:
                type: com.alibaba.druid.pool.DruidDataSource
                driver-class-name: com.mysql.jdbc.Driver
                url: jdbc:mysql://192.168.21.129:3306/sharding_dev_1?characterEncoding=UTF-8&useUnicode=true&useSSL=false&autoReconnect=true&failOverReadOnly=false
                username: root
                password: 123456
        # 规则配置
        sharding:
            # 默认分库策略
            default-database-strategy:
                inline:
                    sharding-column: user_id
                    algorithm-expression: ds$->{user_id%2}
            tables:
                t_order:
                    # 真实数据节点
                    actual-data-nodes: ds$->{0..1}.t_order_$->{0..1}
                    # 分表策略
                    table-strategy:
                        inline:
                            sharding-column: order_id
                            algorithm-expression: t_order_$->{order_id%2}
                    # 主键生成策略
                    key-generator:
                        column: order_id
                        type: SNOWFLAKE
            default-key-generator:
                column: order_id
                type: SNOWFLAKE
```
> 配置中配置了ds0、ds1 2个数据源，每个库中分2张表t_order_0、t_order_1

## 绑定表
绑定表： 指分片规则一致的主表和子表，联表查询防止出现笛卡尔积现象

例如：t_order表和t_order_item表，均按照order_id分片，则此两张表互为绑定表关系。绑定表之间的多表关联查询
不会出现笛卡尔积关联，关联查询效率将大大提升
```yaml
        ...
        # 规则配置
        sharding:
            # 默认分库策略
            default-database-strategy:
                inline:
                    sharding-column: user_id
                    algorithm-expression: ds$->{user_id%2}
            tables:
                t_order:
                    # 真实数据节点
                    actual-data-nodes: ds$->{0..1}.t_order_$->{0..1}
                    # 分表策略
                    table-strategy:
                        inline:
                            sharding-column: order_id
                            algorithm-expression: t_order_$->{order_id%2}
                    # 主键生成策略
                    key-generator:
                        column: order_id
                        type: SNOWFLAKE
                t_order_item:
                    actual-data-nodes: ds$->{0..1}.t_order_item_$->{0..1}
                    table-strategy:
                        inline:
                            sharding-column: order_id
                            algorithm-expression: t_order_item_$->{order_id%2}
                    key-generator:
                        column: order_item_id
                        type: SNOWFLAKE
            # 默认主键生成策略
            default-key-generator:
                column: order_id
                type: SNOWFLAKE
            # 绑定表
            binding-tables:
                - t_order,t_order_item
```
> 绑定表之前的分片策略要一致

## 广播表
定义：指所有的分片数据源中都存在的表，表结构和表中的数据在每个数据库中完全一致。

适用：数据量不大且需要与海量数据的表进行关联查询的场景，例如：字典表。

需要满足如下：

（1）在每个数据库表都存在该表以及表结构都一样。

（2）当保存的时候，每个数据库都会插入相同的数据。

示例配置：
```yaml
        ...
        # 规则配置
        sharding:
            # 默认分库策略
            default-database-strategy:
                inline:
                    sharding-column: user_id
                    algorithm-expression: ds$->{user_id%2}
            tables:
                t_order:
                    # 真实数据节点
                    actual-data-nodes: ds$->{0..1}.t_order_$->{0..1}
                    # 分表策略
                    table-strategy:
                        inline:
                            sharding-column: order_id
                            algorithm-expression: t_order_$->{order_id%2}
                    # 主键生成策略
                    key-generator:
                        column: order_id
                        type: SNOWFLAKE
                t_order_item:
                    actual-data-nodes: ds$->{0..1}.t_order_item_$->{0..1}
                    table-strategy:
                        inline:
                            sharding-column: order_id
                            algorithm-expression: t_order_item_$->{order_id%2}
                    key-generator:
                        column: order_item_id
                        type: SNOWFLAKE
                t_dict:
                    key-generator:
                        column: dict_id
                        type: SNOWFLAKE
            # 默认主键生成策略
            default-key-generator:
                column: order_id
                type: SNOWFLAKE
            # 绑定表
            binding-tables:
                - t_order,t_order_item
            # 广播表
            broadcast-tables:
                - t_dict
```

## 读写分离
读写分离可与分库分表结合使用，例如之前有ds0,ds1两个数据源在进行分库分表，如果加上读写分离，就相当于ds0,ds1都要作为master，
另外需要分别创建ds0和ds1的slave

* 创建ds0和ds1的slave，名称不能使用下划线
```yaml
datasource:
    names: ds0,ds1,ds0slave,ds1slave
    ds0:
        type: com.alibaba.druid.pool.DruidDataSource
        driver-class-name: com.mysql.jdbc.Driver
        url: jdbc:mysql://192.168.21.129:3306/sharding_dev_0?characterEncoding=UTF-8&useUnicode=true&useSSL=false&autoReconnect=true&failOverReadOnly=false
        username: root
        password: 123456
    ds1:
        type: com.alibaba.druid.pool.DruidDataSource
        driver-class-name: com.mysql.jdbc.Driver
        url: jdbc:mysql://192.168.21.129:3306/sharding_dev_1?characterEncoding=UTF-8&useUnicode=true&useSSL=false&autoReconnect=true&failOverReadOnly=false
        username: root
        password: 123456
    ds0slave:
        type: com.alibaba.druid.pool.DruidDataSource
        driver-class-name: com.mysql.jdbc.Driver
        url: jdbc:mysql://192.168.21.129:3306/sharding_dev_0_slave?characterEncoding=UTF-8&useUnicode=true&useSSL=false&autoReconnect=true&failOverReadOnly=false
        username: root
        password: 123456
    ds1slave:
        type: com.alibaba.druid.pool.DruidDataSource
        driver-class-name: com.mysql.jdbc.Driver
        url: jdbc:mysql://192.168.21.129:3306/sharding_dev_1_slave?characterEncoding=UTF-8&useUnicode=true&useSSL=false&autoReconnect=true&failOverReadOnly=false
        username: root
        password: 123456
```

* 配置读写分离

名称为ms0配置的是ds0及ds0的读写分离库，名称为ms1配置的是ds1及ds1的读写分离库

分库分表的规则配置中要将之前的ds修改成ms

```yaml
 # 规则配置
sharding:
    # 读写分离
    master-slave-rules:
        ms0:
            master-data-source-name: ds0
            slave-data-source-names:
                - ds0slave
        ms1:
            master-data-source-name: ds1
            slave-data-source-names:
                - ds1slave
    # 默认分库策略
    default-database-strategy:
        inline:
            sharding-column: user_id
            algorithm-expression: ms$->{user_id%2}
    tables:
        t_order:
            # 真实数据节点
            actual-data-nodes: ms$->{0..1}.t_order_$->{0..1}
            # 分表策略
            table-strategy:
                inline:
                    sharding-column: order_id
                    algorithm-expression: t_order_$->{order_id%2}
            # 主键生成策略
            key-generator:
                column: order_id
                type: SNOWFLAKE
        t_order_item:
            actual-data-nodes: ms$->{0..1}.t_order_item_$->{0..1}
            table-strategy:
                inline:
                    sharding-column: order_id
                    algorithm-expression: t_order_item_$->{order_id%2}
            key-generator:
                column: order_item_id
                type: SNOWFLAKE
        t_dict:
            key-generator:
                column: dict_id
                type: SNOWFLAKE
    # 默认主键生成策略
    default-key-generator:
        column: order_id
        type: SNOWFLAKE
    # 绑定表
    binding-tables:
        - t_order,t_order_item
    # 广播表
    broadcast-tables:
        - t_dict
```



