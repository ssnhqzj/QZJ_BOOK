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
minio/minio:RELEASE.2021-06-17T00-10-46Z server /data

//新版本
docker run -p 9000:9000 -p 9001:9001 --name minio \
-d --restart=always \
-e "MINIO_ACCESS_KEY=admin" \
-e "MINIO_SECRET_KEY=Zxy880322" \
-v /home/data:/data \
-v /home/config:/root/.minio \
minio/minio server /data --console-address ":9001"
```