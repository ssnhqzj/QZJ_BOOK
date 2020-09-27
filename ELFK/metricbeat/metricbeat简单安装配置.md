## 下载 metricbeat-6.2.3-linux-x86_64.tar.gz 并解压
```
tar -zxvf metricbeat-6.2.3-linux-x86_64.tar.gz
```

## 修改配置文件
```
cd metricbeat-6.2.3-linux-x86_64

vim metricbeat.yml
```
修改配置如下，参考同目录下的metricbeat.yml

## 配置kibana Dashboard 
搜索
[Metricbeat System] Host overview
填写 beat.name:"10.0.50.101"
即配置文件中定义的name

## 后台启动

```
#启动metricbeat
nohup ./metricbeat -e -c metricbeat.yml -d "publish" & > nohup.out
```


