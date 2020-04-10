
1.进入Redis安装包目录，安装服务：redis-server.exe --service-install redis.windows.conf --service-name redisserver1 --loglevel verbose

win+r -> services.msc,可以看到服务安装成功

安装服务：redis-server.exe --service-install redis.windows.conf --service-name redisserver1 --loglevel verbose

启动服务：redis-server.exe  --service-start --service-name redisserver1

停止服务：redis-server.exe  --service-stop --service-name redisserver1

卸载服务：redis-server.exe  --service-uninstall--service-name redisserver1