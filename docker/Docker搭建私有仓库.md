### 1. 下载私有仓库注册服务器的镜像
```
sudo docker pull registry:latest
```

### 2. 创建一个注册服务器容器
```
sudo docker run -d -p 5000:5000 --name server-registry -v /tmp/registry:/tmp/registry docker.io/registry:latest
```

参数说明
```
-d 容器在后端运行
-p 5000:5000 在容器的5000端口运行并映射到外部系统的5000端口
--name server-registry 容器命名为server-registry
-v /tmp/registry /tmp/registry 把宿主机的目录/tmp/registry挂载到容器目录/tmp/registry
```

### 3.为本地镜像添加标签，并将其归入本地仓库
```
sudo docker tag nginx:v3 localhost:5000/nginx:v3

将被标记的本地镜像, push到仓库
sudo docker push localhost:5000/nginx:v3
```

### 4.测试本地仓库的的可用性
```
 sudo docker pull 123.207.55.60:5000/nginx:v3
```

### 5.查询仓库的镜像
```
 curl -XGET http://192.168.36.130:5000/v2/_catalog
```

### 6.遇到的问题

#### Get https://172.18.18.90:5000/v2/: http: server gave HTTP response to HTTPS client
这是报错了，需要https的方法才能上传，我们可以修改下daemon.json来解决：

```
[root@node ~]# vim /etc/docker/daemon.json
{
  "registry-mirrors": [
    "https://docker.mirrors.ustc.edu.cn",
    "https://registry.docker-cn.com",
    "http://hub-mirror.c.163.com",
    "https://cr.console.aliyun.com/"],
  "insecure-registries": ["10.0.52.21:5000"]
}
```

添加私有镜像服务器的地址，注意书写格式为json，有严格的书写要求，然后重启docker服务：

```
[root@node ~]# systemctl  restart docker
```

注：这一步一定要在创建私有仓库的容器之前，否则修改配置文件不会生效


