一、前言

Logstash是Elastic stack 中的一个开源组件，其不仅能够对日志进行抓取收集，还能对抓取的日志进行过滤输出。Logstash的过滤插件有多种，如：grok、date、json、geoip等等。其中最为常用的为grok正则表达式过滤。

二、grok的匹配语法

grok的匹配语法分为两种：grok自带的基本匹配模式、用户自定义的匹配模式。
- Grok的基本匹配模式
Grok模块提供了默认内嵌了一些基本匹配模式，其使用语法为：
```
%{SYNTAX:SEMANTIC}
```

其中SYNTAX为匹配模式的名称，用于调用相应的匹配模式匹配文本，如：3.44 会被NUBER模式所匹配，而10.10.10.1会被IP模式所匹配。
而SEMANTIC则是用于标记被匹配到的文本内容，如10.10.10.1被IP模式所匹配，并编辑为ClientIP。
其使用例子：
```
%{NUMBER:duration} %{IP:ClientIP}
```

- Grok的自定义模式
Grok模块是基于正则表达式做匹配的，因此当基本匹配模式不足以满足我们的需求时，我们还自定义模式编译相应的匹配规则。
Grok的自定义模式的语法：
(?<field_name>the pattern here)

其中filed_name为自定义模式的名称，pattern即指正则表达式。
如：
```
#匹配时间的自定义模式
(?<Date>(\d*[./-]\d*[./-]\d* \d*:\d*:\d*[.,][0-9]+))
```

三、grok的过滤配置选项和通用选项
grok支持下述的过滤配置选项



选项
类型
是否为必须
描述




break_on_match
布尔型
否
默认值为true，只会匹配第一个符合匹配条件的值，如果需要匹配多个值，则需要设置为false


keep_empty_captures
布尔型
否
默认值为false，如果为true，则保留空字段为事件字段


match
哈希型
否
意思为匹配一个字段的哈希值，单一字段可设置匹配多个匹配模式


named_captures_only
布尔型
否
默认值为true，意味着只保存从grok中获取的名称


overwrite
数组
否
此选项用于复写字段中的值


pattern_definitions
哈希型
否
定义被当前过滤器所使用的自动模式的名称和元组名称，如果命名的名称已存在，则会覆盖此前配置


patterns_dir
数组
否
指定用于保存定义好的匹配模式的文件目录


patterns_files_glob
字符串
否
用于在patterns_dir指定的目录中过滤匹配的文件


tag_on_failure
数组
否
默认值为_grokparsefailure，当匹配不成功时追加指定值到tags字段


tag_on_timeout
字符串
否
默认值为_groktimeout，当grok正则表达式匹配超时追加的tag


timeout_millis
数值
否
默认值为30000毫秒，当正则匹配运行超过指定的时间后，尝试终结此匹配操作。设置为0将关闭超时



grok的通用选项：
下述选项是被所有过滤插件都支持的通用选项。



选项
类型
是否为必须
描述




add_field
哈希型
否
如果此过滤选项匹配成功，则会向匹配的事件中添加指定的字段，字段名和内容可以调用相关的变量进行定义命名


add_tag
数组
否
用于当过滤成功时，向匹配的事件中添加tag


enable_metric
布尔型
否
默认值为true，默认情况下，启用或禁用此功能，能记录特定插件的相关度量值。


id
字符串
否
添加一个唯一ID到指定的插件配置中，当有多个同一类型的插件时，可更好地去区别监控logstash


periodic_flush
布尔型
否
默认值为false，可选项，用于在规定的间隔时间调用过滤器的刷新功能


remove_field
数组
否
当此插件匹配成功时，从事件中移除指定的字段


remove_tag
数组
否
当此插件匹配成功时，从事件中移除指定的tags

作者：小尛酒窝
链接：https://www.jianshu.com/p/49ae54a411b8
来源：简书
简书著作权归作者所有，任何形式的转载都请联系作者获得授权并注明出处。




四、grok使用示例
添加和移除指定的字段
```
input {
        beats {
                port => 5044
                type => "nginx"
        }
}

filter {
        if [type] == "nginx" {
        grok {
                match => { "message" => ["(?<RemoteIP>(\d*.\d*.\d*.\d*)) - %{DATA:[nginx][access][user_name]} \[%{HTTPDATE:[nginx][access][time]}\] \"%{WORD:[nginx][access][method]} %{DATA:[nginx][access][url]} HTTP/%{NUMBER:[nginx][access][http_version]}\" %{NUMBER:[nginx][access][response_code]} %{NUMBER:[nginx][access][body_sent][bytes]} \"%{DATA:[nginx][access][referrer]}\" \"%{DATA:[nginx][access][agent]}\""] }
        add_field => {
                "Device" => "Charles Desktop"
        }
        remove_field => "message"
        remove_field => "beat.version"
        remove_field => "beat.name"
                }
        }
}

output {
        if [type] == "nginx" {
                elasticsearch {
                        hosts => "10.10.10.6:9200"
                        index => "logstash-testlog"
        }       }
}
```
作者：小尛酒窝
链接：https://www.jianshu.com/p/49ae54a411b8
来源：简书
简书著作权归作者所有，任何形式的转载都请联系作者获得授权并注明出处。