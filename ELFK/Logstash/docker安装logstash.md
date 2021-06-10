# 一、概述
需要使用docker 安装Logstash，来收集文件/var/log/messages

# 二、安装
## 下载镜像
```shell script
docker pull logstash:7.5.1
```

## 启动logstash
```shell script
docker run -d --name=logstash logstash:7.5.1
```

等待30秒，查看日志
```shell script
docker logs -f logstash
```

如果出现以下信息，说明启动成功。
```shell script
[2020-08-26T08:12:01,224][INFO ][org.logstash.beats.Server] Starting server on port: 5044
[2020-08-26T08:12:01,722][INFO ][logstash.agent           ] Successfully started Logstash API endpoint {:port=>9600}
```

## 拷贝数据，授予权限
```shell script
docker cp logstash:/usr/share/logstash /data/elk7/
mkdir /data/elk7/logstash/config/conf.d
chmod 777 -R /data/elk7/logstash
```

配置文件
```shell script
vi /data/elk7/logstash/config/logstash.yml
```

完整内容如下：
```shell script
http.host: "0.0.0.0"
xpack.monitoring.elasticsearch.hosts: [ "http://192.168.31.196:9200" ]
path.config: /usr/share/logstash/config/conf.d/*.conf
path.logs: /usr/share/logstash/logs
```
> 注意：请根据实际情况修改elasticsearch地址

## 新建文件syslog.conf，用来收集/var/log/messages
```shell script
vi /data/elk7/logstash/config/conf.d/syslog.conf
```

内容如下：
```shell script
input {
  file {
    #标签
    type => "systemlog-localhost"
    #采集点
    path => "/var/log/messages"
    #开始收集点
    start_position => "beginning"
    #扫描间隔时间，默认是1s，建议5s
    stat_interval => "5"
  }
}

output {
  elasticsearch {
    hosts => ["192.168.31.196:9200"]
    index => "logstash-system-localhost-%{+YYYY.MM.dd}"
 }
}
```

如果是接收filebeat的日志，可以参考如下配置：
```shell script
input {
  beats {
    port => 5044
  }
}

filter {
  if [type] == "syslog" {
    grok {
      match => { "message" => "%{TIMESTAMP_ISO8601:logdate}" }
      add_field => {"logdt" => "%{logdate}"}
    }

    date {
      timezone => "Asia/Chongqing"
      match => [ "logdate", "yyyy-MM-dd HH:mm:ss.SSS" ]
      target => "logdate"
    }

    mutate {
      gsub => [ "message","%{logdate} -","" ]
      remove_field => ["logdt"]
    }
  }
}

output {
  elasticsearch {
    hosts => ["192.168.21.128:9200","192.168.21.128:9201","192.168.21.128:9202"]
    manage_template => false
    index => "%{[fields][system]}-%{+YYYY.MM.dd}"
    document_type => "%{[@metadata][type]}"
  }
}
```

重新启动logstash

```shell script
docker rm -f logstash

docker run -d \
  --name=logstash \
  --restart=always \
  -p 5044:5044 \
  -v /data/elk7/logstash:/usr/share/logstash \
  -v /var/log/messages:/var/log/messages \
  logstash:7.5.1

docker run -d \
  --name=logstash \
  --restart=always \
  -p 5044:5044 \
  -v /opt/es-cluster/logstash:/usr/share/logstash \
  logstash:7.6.2
```

> 重启完成之后，访问elasticsearch-head