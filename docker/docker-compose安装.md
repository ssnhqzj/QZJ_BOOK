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