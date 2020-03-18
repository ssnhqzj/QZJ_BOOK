## docker 批量删除无用的容器或镜像

```  
docker rm `docker ps -a | grep Exited | awk '{print $1}'`
删除异常停止的docker容器

docker rmi -f  `docker images | grep '<none>' | awk '{print $3}'`  
删除名称或标签为none的镜像
```