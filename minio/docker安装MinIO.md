1. docker中搜索MinIO
```shell script
docker search minio
```

2. 拉取MinIO
```shell script
docker pull minio/minio
```

3. 启动与安装镜像
```shell script
docker run -p 9000:9000 --name minio \
-d --restart=always \
-e "MINIO_ACCESS_KEY=admin" \
-e "MINIO_SECRET_KEY=Zxy880322" \
-v /home/data:/data \
-v /home/config:/root/.minio \
minio/minio server /data
```