## sebp/elk容器的配置文件
logstash的配置文件在/etc/logstash/conf.d/目录下
```
vim /etc/logstash/conf.d/
```
其中：

> 02-beats-input.conf  输入源配置文件
> 10-syslog.conf  日志过滤器配置文件
> 11-nginx.conf  nginx日志过滤器配置文件
> 30-output.conf 输出配置

## 配置时间戳
修改配置文件10-syslog.conf
```
vim 10-syslog.conf

# 模拟日志数据输入
input {
    generator {
        # 输入次数
        count => 10
        message => '2020-09-16 14:06:20.660 [main] INFO  com.sofn.sys.SysServiceApplication - The following profiles are active: filter,local'
    }
}


filter {

    grok {
      match => { "message" => "%{TIMESTAMP_ISO8601:logdate}" }
      add_field => {"logdt" => "%{logdate}"}
    }

    syslog_pri { }
    
    date {
      timezone => "Asia/Chongqing"
      match => [ "logdate", "yyyy-MM-dd HH:mm:ss.SSS" ]
      target => "logdate"
    }

    mutate {
      # 替换message中的logdt为空
      gsub => [ "message","%{logdt} - ","" ]
      remove_field => ["logdt"] 
    }


}

output {
    stdout {
        codec => rubydebug
    }
}
```