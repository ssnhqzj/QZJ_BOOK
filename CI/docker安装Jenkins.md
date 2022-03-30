## 拉取镜像
```shell script
docker pull jenkins/jenkins
```

## 创建Jenkins挂载目录并授权权限
创建Jenkins挂载目录并授权权限（我们在服务器上先创建一个jenkins工作目录 /var/jenkins_mount，赋予相应权限，稍后我们将jenkins容器目录挂载到这个目录上，
这样我们就可以很方便地对容器内的配置文件进行修改。 如果我们不这样做，那么如果需要修改容器配置文件，将会有点麻烦，因为虽然我们可以使用docker exec -it --user root 
容器id /bin/bash 命令进入容器目录，但是连简单的 vi命令都不能使用）

```shell script
mkdir -p /usr/local/jenkins_data
chmod 777 /usr/local/jenkins_data
```

## 创建并启动Jenkins容器
```shell script
-d 后台运行镜像
-p 10240:8080 将镜像的8080端口映射到服务器的10240端口。
-p 10241:50000 将镜像的50000端口映射到服务器的10241端口
-v /usr/local/jenkins_data:/var/jenkins_home /var/jenkins_home目录为容器jenkins工作目录，
我们将硬盘上的一个目录挂载到这个位置，方便后续更新镜像后继续使用原来的工作目录。这里我们设置的就是上面我们创建的 /var/jenkins_mount目录
-v /etc/localtime:/etc/localtime让容器使用和服务器同样的时间设置。
--name myjenkins 给容器起一个别名
```

```shell script
docker run -d -p 38080:8080 -p 38081:50000 -v /usr/local/jenkins_data:/var/jenkins_home -v /etc/localtime:/etc/localtime --name jks jenkins/jenkins

docker run -d -p 38080:8080 -p 38081:50000 \
-v /usr/local/jenkins_data:/var/jenkins_home \
-v /usr/local/apache-maven-3.8.5:/usr/local/maven \
-v /usr/local/jdk1.8.0_271:/usr/local/java \
--name jksn jks-new
```

## 配置镜像加速，进入 cd /usr/local/jenkins_data 目录。
修改 vi  hudson.model.UpdateCenter.xml里的内容

修改前:
```xml
<?xml version='1.1' encoding='UTF-8'?>
<sites>
  <site>
    <id>default</id>
    <url>https://updates.jenkins.io/update-center.json</url>
  </site>
</sites>
```

将 url 修改为 清华大学官方镜像：https://mirrors.tuna.tsinghua.edu.cn/jenkins/updates/update-center.json
修改后：
```xml
<sites>
  <site>
    <id>default</id>
    <url>https://mirrors.tuna.tsinghua.edu.cn/jenkins/updates/update-center.json</url>
  </site>
</sites>
```
　　
## 访问Jenkins页面，输入你的ip加上38080
管理员密码获取方法，编辑initialAdminPassword文件查看，把密码输入登录中的密码即可，开始使用。
```shell script
cat /usr/local/jenkins_data/secrets/initialAdminPassword

b119f38cf297468ca674d54e0e69cfff
```
