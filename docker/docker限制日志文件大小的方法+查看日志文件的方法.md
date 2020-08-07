一、docker日志文件的方法

除了
```
docker logs -f 容器ID/容器名
```
这个方法以外。

 
在linux上，一般docker的日志文件存储在/var/lib/docker/containers/container_id/ 目录下的 各个容器ID对应的目录下的*-json.log 文件中

方法1：可以直接进入该目录下，查找日志文件

方法2：可以写一个脚本文件，执行即可

　　1》创建.sh文件【在你自己可以找到的目录下】
```
vi docker_log_size.sh
```
文件内容

```
#!/bin/sh 
echo "======== docker containers logs file size ========"  

logs=$(find /var/lib/docker/containers/ -name *-json.log)  

for log in $logs  
        do  
             ls -lh $log   
        done
```
 

　　2》为该文件设置权限
```
chmod +x docker_log_size.sh
```
　　3》执行该文件
```
./docker_log_size.sh
 ```

 
二.设置Docker容器日志文件大小限制

1.新建/etc/docker/daemon.json，若有就不用新建了。添加log-dirver和log-opts参数，样例如下：
```
# vim /etc/docker/daemon.json

{
  "log-driver":"json-file",
  "log-opts": {"max-size":"500m", "max-file":"3"}
}
```
max-size=500m，意味着一个容器日志大小上限是500M， 
max-file=3，意味着一个容器有三个日志，分别是id+.json、id+1.json、id+2.json。

 

2.然后重启docker的守护线程

命令如下：
```
systemctl daemon-reload
systemctl restart docker
```