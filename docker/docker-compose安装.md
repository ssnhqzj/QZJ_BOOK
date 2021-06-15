国内镜像安装 docker-compose
按照官网操作

sudo curl -L "https://github.com/docker/compose/releases/download/1.24.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

*** 实在太慢！所以，又去找了一下国内镜像

国内镜像参考文章 https://blog.csdn.net/huiyanghu/article/details/82253886
按照以上参考文章抄过来

curl -L https://get.daocloud.io/docker/compose/releases/download/1.24.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
果然秒达！接下来设置可运行

chmod +x /usr/local/bin/docker-compose
确认一下：

$docker-compose --version

	docker-compose version 1.24.0, build 0aa59064

### centos安装docker-compose
```
#查看docker compose版本
 docker-compose version

#查看pip版本
 pip -v

#上一条语句没有显示版本信息则运行下面语句安装 python-pip
 yum -y install epel-release
 yum -y install python-pip

#查看pip版本
 pip -v

#pip进行升级
 pip install --upgrade pip

#进行安装compose 第一条语句报错执行第二条，执行成功则跳过第二条
 pip install docker-compose
 pip install docker-compose --ignore-installed requests
 docker-compose -version
```
