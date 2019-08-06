# Nginx安装

### 直接下载nginxd的tar.gz安装包
下载地址：nginx下载<https://nginx.org/en/download.html>

### 解压安装包
```bash
tar -zxvf nginx-1.11.6.tar.gz

# 解压后进入安装目录
cd nginx-1.11.6
```

### nginx配置
```bash
# 使用默认配置
./configure
```

### 执行命令后会发现出现错误，我们需要添加依赖库
```bash
# 安装gcc环境
sudo apt-get  build-dep  gcc

# 安装PCRE库
sudo apt-get install libpcre3 libpcre3-dev

# 安装zlib库
sudo apt-get install zlib1g-dev

# 安装openssl库
sudo apt-get install openssl libssl-dev
```

### 再次执行配置命令
```bash
./configure
```

### 编译安装
```bash
make install
```

### 查找安装路径命令
```bash
whereis nginx
```

### 启动、停止nginx
```bash
# 先进入nginx的目录
cd /usr/local/nginx/sbin/

./nginx 开启
./nginx -s stop 停止
./nginx -s quit
./nginx -s reload

./nginx -s quit #此方式停止步骤是待nginx进程处理任务完毕进行停止。
./nginx -s stop #此方式相当于先查出nginx进程id再使用kill命令强制杀掉进程。

```

### 开机自启动
在etc的rc.local增加启动代码就可以了
```bash
vi /etc/rc.local

# 添加一下语句
/usr/local/nginx/sbin/nginx

# 设置权限
chmod 755 /etc/rc.local
```

### 查看Nginx进程
```bash
ps aux|grep nginx
```
