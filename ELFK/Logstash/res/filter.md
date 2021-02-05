```shell script

filter {
    if [filetype] == "logjson" { #这里对应的是FileBeat里配置的filetype
        grok {
            #切割后日期名字叫logdate
            match => ["message", "%{TIMESTAMP_ISO8601:logdate}"]
        }
        date {
            #logdate 从上面过滤后取到的字段名，yyyy-MM-dd HH:mm:ss.SSS 日期格式条件
            match => ["logdate", "yyyy-MM-dd HH:mm:ss.SSS"]
            #赋值给那个key
            target => "@timestamp"
            remove_field =>["logdate"]
        }
        json {
            source => "message"
            remove_field => ["host","@version","ecs","agent","tags"]
        }
    } else {
        grok {
            #切割后日期名字叫logdate
            match => ["message", "%{TIMESTAMP_ISO8601:logdate}"]
        }
        date {
            #logdate 从上面过滤后取到的字段名，yyyy-MM-dd HH:mm:ss.SSS 日期格式条件
            match => ["logdate", "yyyy-MM-dd HH:mm:ss.SSS"]
            #赋值给那个key
            target => "@timestamp"
            remove_field =>["logdate"]
        }
        mutate {
            remove_field => ["host","@version","ecs","agent","tags"]
        }
    }
}

if [filetype] == "operate" {
  grok {
      match => ["message", "%{TIMESTAMP_ISO8601:logdate}"]
  }
  date {
      #logdate 从上面过滤后取到的字段名，yyyy-MM-dd HH:mm:ss.SSS 日期格式条件
      match => ["logdate", "yyyy-MM-dd HH:mm:ss.SSS"]
      #赋值给那个key
      target => "@timestamp"
  }
}


```

> 截取日期复制到logdate字段中
```shell script
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
```