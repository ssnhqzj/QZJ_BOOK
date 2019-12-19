### 构建filebeat基础镜像
```
docker build -t sofn/springboot-app-filebeat:0.0.1 .
```

### web工程构建成docker镜像
```
mvn clean package -U -DskipTests docker:build
```

### sebp/elk创建容器并启动
```
docker run -p 5601:5601 -p 9200:9200 -p 5044:5044 -it --name elk sebp/elk:623

# 使用host网络
docker run -it --name elk --network host sebp/elk:623
```

### sys创建容器并启动
```
docker run -d --link elk:elk -p 8881:8881 -it --name sys-01 sofn/sys-service:latest

# 使用host网络
docker run -it --name sys-01 --network host sofn/sys-service:latest
```