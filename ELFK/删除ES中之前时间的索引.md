
### 清理过期ES索引的脚本

```shell
#!/bin/bash

elastic_url=127.0.0.1
elastic_port=9200
log="/data/log/delete_index.log"
recent_days=20


# 当前日期时间戳减去索引名时间转化时间戳是否大于1
dateDiff (){
    dte1=$1
    dte2=$2
    
    ##将输入的日期转为的时间戳格式
    startDate=`date -d "${dte2}" +%s`
    endDate=`date -d "${dte1}" +%s`
    ##计算两个时间戳的差值除于每天86400s即为天数差
    stampDiff=`expr $endDate - $startDate`
    diffSec=`expr $stampDiff / 86400`
    
    if ((diffSec > ${recent_days})); then
	echo "1"
    else
        echo "0"
    fi
}

# 循环获取索引文件，通过正则匹配过滤
for index in $(curl -s "${elastic_url}:${elastic_port}/_cat/indices?v" | awk -F' ' '{print $3}' | grep -E "[0-9]{4}.[0-9]{2}.[0-9]{2}$"); do
# 获取索引文件日期，并转化格式
  date=$(echo $index | awk -F'-' '{print $NF}' | sed -n 's/\.//p' | sed -n 's/\.//p')
# 获取当前日期
  cond=$(date '+%Y%m%d')
# 根据不同服务器，计算不同数值
  diff=$(dateDiff "${cond}" "${date}")
# 打印索引名和结果数值
  #echo -n "${index} (${diff})"

# 判断结果值是否大于等于1
  if [ $diff -eq 1 ]; then
    curl -XDELETE -s "${elastic_url}:${elastic_port}/${index}" && echo "${index} 删除成功" >> $log || echo "${index} 删除失败" >> $log
fi
done
```

### 为当前用户创建cron服务

键入 crontab  -e 编辑crontab服务文件

```shell
0 12 * * * /bin/sh /home/admin/jiaoben/buy/deleteFile.sh 
#保存文件并并退出
```
