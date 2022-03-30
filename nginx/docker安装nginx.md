1.使用docker search nginx命令获取nginx镜像列

2.使用docker pull nginx命令拉取nginx镜像到本地，此处我们获取排名第一的是官方最新镜像，其它版本可以去DockerHub查询

3.使用docker images nginx命令，查看我们拉取到本地的nginx镜像IMAGE ID

首先测试下nginx镜像是否可用，使用docker run -d --name mynginx -p 80:80 0839创建并启动nginx容器

-d 指定容器以守护进程方式在后台运行
--name 指定容器名称，此处我指定的是mynginx
-p 指定主机与容器内部的端口号映射关系，格式 -p
[宿主机端口号]：[容器内部端口]，此处我使用了主机80端口，映射容器80端口
0839 是nginx的镜像IMAGE ID前4位

进入到nginx容器内部后，我们可以cd /etc/nginx，可以看到相关的nginx配置文件都在/etc/nginx目录下

而nginx容器内的默认首页html文件目录为/usr/share/nginx/html

日志文件位于/var/log/nginx
docker cp ef:/etc/nginx/nginx.conf ./        
dokcer cp ef:/etc/nginx/conf.d/default.conf ./conf/

```shell script
docker run -d \
--name ngx \
-p 80:80 \
-p 8080:8080 \
-v /opt/nginx/nginx.conf:/etc/nginx/nginx.conf \
-v /opt/nginx/logs:/var/log/nginx \
-v /opt/nginx/html:/usr/share/nginx/html \
-v /opt/nginx/conf:/etc/nginx/conf.d --privileged=true nginx:latest
```

```shell script
#虚拟主机
server {
    listen       80;  #配置监听端口号
    server_name  localhost; #配置访问域名，域名可以有多个，用空格隔开

    #charset koi8-r; #字符集设置

    #access_log  logs/host.access.log  main;

    location / {
        root   html;
        index  index.html index.htm;
    }
    #错误跳转页
    #error_page  404              /404.html; 

    # redirect server error pages to the static page /50x.html
    #
    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   html;
    }
}
```