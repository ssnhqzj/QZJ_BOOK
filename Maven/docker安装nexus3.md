# docker安装maven私服nexus
转载：<https://blog.csdn.net/weishaoqi2/article/details/105449546>

## 1. 拉取镜像
```shell script
docker pull sonatype/nexus3
```

## 2. 配置外部挂载文件夹
```shell script
mkdir -p /usr/local/nexus-data && chmod 777 /usr/local/nexus-data
```

## 3. 安装
```shell script
docker run -d -p 28080:8081 --name nexus -v /usr/local/nexus-data:/nexus-data sonatype/nexus3
```

## 4. 进入挂载目录，找到登录密码
```shell script
[root@localhost nexus-data]# ll
总用量 28
-rw-r--r--   1  200  200   36 3月  18 22:08 admin.password
drwxr-xr-x   3  200  200   21 3月  18 22:08 blobs
drwxr-xr-x 336  200  200 8192 3月  18 22:08 cache
drwxr-xr-x   6  200  200  113 3月  18 22:08 db
drwxr-xr-x   3  200  200   19 3月  18 22:08 elasticsearch
drwxr-xr-x   3  200  200   45 3月  18 22:08 etc
drwxr-xr-x   2  200  200    6 3月  18 22:08 generated-bundles
drwxr-xr-x   2  200  200   33 3月  18 22:08 instances
drwxr-xr-x   3  200  200   19 3月  18 22:08 javaprefs
-rw-r--r--   1  200  200    1 3月  18 22:08 karaf.pid
drwxr-xr-x   3  200  200   18 3月  18 22:08 keystores
-rw-r--r--   1  200  200   14 3月  18 22:08 lock
drwxr-x--x   2 root root    6 3月  18 22:04 log
drwxr-xr-x   2  200  200    6 3月  18 22:08 orient
-rw-r--r--   1  200  200    5 3月  18 22:08 port
drwxr-xr-x   2  200  200    6 3月  18 22:08 restore-from-backup
drwxr-xr-x   7  200  200  241 3月  18 22:08 tmp
[root@localhost nexus-data]# cat admin.password 
351e6a69-f42e-4fda-a7d9-127166329f39
```

## 5. 在浏览器输入url，登录nexus页面
   - 账号默认为admin
   - 密码为第4步中获取的默认密码
   - url：http://192.168.133.129:28080/，ip为docker宿主机ip，port为映射的宿主机端口
   - 登录成功后，会提示修改密码，按提示一步步操作
   
### 5.1 默认仓库说明
   - maven-central：maven中央库，默认从https://repo1.maven.org/maven2/拉取jar
   - maven-releases：私库发行版jar，初次安装完后，将Deployment policy设置为Allow redeploy
   - maven-snapshots：私库快照（调试版本）jar
   - maven-public：仓库分组，把上面三个仓库组合在一起对外提供服务，在本地maven基础配置settings.xml或项目pom.xml中使用

### 5.2 仓库类型
   - Group：这是一个仓库聚合的概念，用户仓库地址选择Group的地址，即可访问Group中配置的，用于方便开发人员自己设定的仓库。maven-public就是一个Group类型的仓库，内部设置了多个仓库，访问顺序取决于配置顺序，3.x默认Releases，Snapshots，Central，也可以自己设置。	
   - Hosted：私有仓库，内部项目的发布仓库，专门用来存储本地项目生成的jar文件
   - Snapshots：本地项目的快照仓库
   - Releases： 本地项目发布的正式版本
   - Proxy：代理类型，从远程中央仓库中寻找数据的仓库（可以点击对应的仓库的Configuration页签下Remote Storage属性的值即被代理的远程仓库的路径），如可配置阿里云maven仓库
   - Central：中央仓库
   
## 6. 本地maven及项目pom配置
   - setting.xml：该文件配置的是全局模式
   - pom.xml：该文件的配置的是项目独享模式
   - 若pom.xml和setting.xml同时配置了，以pom.xml为准
   
### 7.1 修改maven的setting.xml
在xml中，添加以下配置
```xml
<servers>
    <!--l加入server配置，用于后续发布包权限验证-->
    <server>
        <id>nexus-releases</id>
        <username>admin</username>
        <password>123456</password>
    </server>
    <server>
        <id>nexus-snapshots</id>
        <username>admin</username>
        <password>123456</password>
    </server>
</servers>

<mirrors>
     <mirror>
        <!--该镜像的唯一标识符。id用来区分不同的mirror元素。 -->
        <id>maven-public</id>
        <!--镜像名称 -->
        <name>maven-public</name>
        <!--*指的是访问任何仓库都使用我们的私服-->
        <mirrorOf>*</mirrorOf>
        <!--该镜像的URL。构建系统会优先考虑使用该URL，而非使用默认的服务器URL。 -->
        <url>http://192.168.56.101:28080/repository/maven-public/</url>		
    </mirror>
</mirrors>
```

### 7.2 修改项目的pom.xml
增加发布到私服的配置，如下
```xml
<!--配置私服发布地址，repository里的id需要和maven配置setting.xml里的server id名称保持一致-->
<distributionManagement>
    <repository>
        <id>nexus-releases</id>
        <name>Releases</name>
        <url>http://192.168.56.101:28080/repository/maven-releases/</url>
    </repository>
    <snapshotRepository>
        <id>nexus-snapshots</id>
        <name>Snapshot</name>
        <url>http://192.168.56.101:28080/repository/maven-snapshots/</url>
    </snapshotRepository>
</distributionManagement>	
```

## 8、发布本地jar到私服
    * 若项目版本号末尾带有 -SNAPSHOT，则会发布到snapshots快照版本仓库
    * 若项目版本号末尾带有 -RELEASES 或什么都不带，则会发布到releases正式版本仓库

在maven项目中，执行[mvn deploy]或直接使用IDEA操作发布

