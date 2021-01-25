### 获取镜像

```shell
#指定版本，该版本包含了web控制页面
docker pull rabbitmq:management
```

### 运行镜像

```
#方式一：默认guest 用户，密码也是 guest
docker run -d --hostname rabbit --name rabbit -p 15672:15672 -p 5672:5672 --restart=unless-stopped rabbitmq:management

#方式二：设置用户名和密码
docker run -d --hostname rabbit --name rabbit -e RABBITMQ_DEFAULT_USER=sofn -e RABBITMQ_DEFAULT_PASS=sofn -p 15672:15672 -p 5672:5672 --restart=unless-stopped rabbitmq:management
```

### 访问ui页面

```
http://localhost:15672/
```

