## 前言
搭建一个简单的Spring Boot项目与Docker技术进行整合,使用Maven来构建Docker镜像并推送至本地Docker Registry,最后对项目进行部署时只需根据镜像启动相应的容器即可.

## 环境搭建
JDK1.8
Spring Boot 1.5.7
Maven 3.3.9
Docker

## 1.使用IDEA新建一个Spring Boot项目,在pom.xml中添加如下配置:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <groupId>hello</groupId>
    <artifactId>hello-api</artifactId>
    <version>1.0.0</version>
    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>1.5.7.RELEASE</version>
        <relativePath/>
    </parent>
    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>
        <dependency>
            <groupId>org.apache.zookeeper</groupId>
            <artifactId>zookeeper</artifactId>
            <version>3.4.13</version>
        </dependency>
    </dependencies>
    <build>
        <finalName>hello</finalName>
        <resources>
            <resource>
                <directory>src/main/resources</directory>
                <filtering>true</filtering>
            </resource>
        </resources>
        <plugins>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
            </plugin>
        </plugins>
    </build>
</project>
```
我们使用了spring-boot-maven-plugin插件来打包生成一个可直接运行的hello.jar包.

## 2.新建一个HelloApplication类.

```java
package hello;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class HelloApplication {
    public static void main(String[] args) {
        SpringApplication.run(HelloApplication.class, args);
    }
}
```

## 3.新建一个控制类HelloController,用于接收Http请求.

```java
package hello.controller;

import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HelloController {
    @RequestMapping(value = "/hi", method = RequestMethod.GET)
    public String hello() {
        return "hi";
    }
}
```

## 4.然后使用mvn package命令开始对spring boot项目进行打包构建,生成对应的target目录.
image.png

cd到此目录下执行java -jar hello.jar启动项目,开启浏览器访问http://localhost:8080/hi,页面返回:hi说明spring boot项目配置运行正常.

## 5.开始为项目添加Docker支持.
Maven规范要求所有的资源文件都应放在src/main/resources目录下,我们在应用的resources目录下创建一个空白的文件Dockerfile,用来说明如何构建docker 镜像,打开Dockerfile文件编写以下指令:
```
FROM java:8
MAINTAINER "william"<952408421@qq.com>
ADD hello.jar app.jar
EXPOSE 8080
CMD java -jar app.jar
```
以上指令使用了Jdk8环境为基础镜像,通过ADD指令将生成的hello.jar包复制到docker容器中,并重命名为app.jar,应用将开启8080端口,最后使用java -jar指令执行jar包.

## 6.使用Maven来构建Docker镜像.
接下来我们要使用maven读取Dockerfile文件来构建镜像并推送到注册中心去,由于Docker默认的镜像注册中心为Docke Hub(地址是docker.io),当使用docker push命令推送镜像时,实际上都是推送到了docker.io的地址上的,如果需要推送到本地自己搭建的镜像注册中心,则镜像名称需要添加前缀ip:port,因为我们之前已经搭好了本地Registry了,所以在pom.xml文件中添加properties:
```
    <properties>
        <docker.registry>192.168.56.101:5000</docker.registry>
    </properties>
```
然后再添加maven plugin到pom.xml文件中:
```
            <plugin>
                <groupId>com.spotify</groupId>
                <artifactId>docker-maven-plugin</artifactId>
                <version>0.4.10</version>
                <configuration>
                    <imageName>${docker.registry}/${project.groupId}/${project.artifactId}:${project.version}</imageName>
                    <dockerDirectory>${project.build.outputDirectory}</dockerDirectory>
                    <resources>
                        <resource>
                            <directory>${project.build.directory}</directory>
                            <include>${project.build.finalName}.jar</include>
                        </resource>
                    </resources>
                </configuration>
            </plugin>
 ```
简要说明一下configuration的配置:
```
imageName:用于指定镜像的完整名称,其中{docker.registry}为注册中心地址,{project.groupId}为仓库名称,{project.artifactId}为镜像名称,${project.version}为镜像标签名.
dockerDirectory:用于指定Dockerfile文件所在的目录.
resources.resource.directory:用于指定需要复制的根目录,${project.build.directory}表示target目录.
resources.resource.include:用于指定需要复制的文件,${project.build.finalName}.jar表示生成的jar包.
```

## 7.使用docker build命令来构建镜像.

```
 mvn docker:build
```
执行后发现构建镜像不成功,报异常localhost:2375 Connection refused :
```
[INFO] Building image 192.168.56.101:5000/hello/hello-api:1.0.0
[INFO] ------------------------------------------------------------------------
[INFO] BUILD FAILURE
[INFO] ------------------------------------------------------------------------
[INFO] Total time: 13.102 s
[INFO] Finished at: 2018-07-30T15:56:40+08:00
[INFO] Final Memory: 26M/218M
[INFO] ------------------------------------------------------------------------
[ERROR] Failed to execute goal com.spotify:docker-maven-plugin:0.4.10:build (default-cli) on project hello-api: Exception caught: java.util.concurrent.ExecutionException: com.spotify.docker.client.shaded.javax.ws.rs.ProcessingException: org.apache.http.conn.HttpHostConnectException: Connect to localhost:2375 [localhost/127.0.0.1, localhost/0:0:0:0:0:0:0:1] failed: Connection refused: connect -> [Help 1]
[ERROR]
[ERROR] To see the full stack trace of the errors, re-run Maven with the -e switch.
[ERROR] Re-run Maven using the -X switch to enable full debug logging.
[ERROR]
[ERROR] For more information about the errors and possible solutions, please read the following articles:
[ERROR] [Help 1] http://cwiki.apache.org/confluence/display/MAVEN/MojoExecutionException
```
网上搜索了很久找到了一种解决Connect to localhost:2375的问题的方法:在pom.xml文件的configuration中添加一行dockerHost.
```
                <configuration>
                    <imageName>${docker.registry}/${project.groupId}/${project.artifactId}:${project.version}</imageName>
                    <dockerDirectory>${project.build.outputDirectory}</dockerDirectory>
                    <dockerHost>http://192.168.56.101:2375</dockerHost>
                    ......
                </configuration>
 ```
我们再来执行mvn docker:build试试,这一次同样是报Connection refused的错,错误信息由localhost变成了192.168.56.101:
```
[INFO] BUILD FAILURE
[INFO] ------------------------------------------------------------------------
[INFO] Total time: 10.086 s
[INFO] Finished at: 2018-07-30T16:13:36+08:00
[INFO] Final Memory: 27M/302M
[INFO] ------------------------------------------------------------------------
[ERROR] Failed to execute goal com.spotify:docker-maven-plugin:0.4.10:build (default-cli) on project hello-api: Exception caught: java.util.concurrent.ExecutionException: com.spotify.docker.client.shaded.javax.ws.rs.ProcessingException: org.apache.http.conn.HttpHostConnectException: Connect to 192.168.56.101:2375 [/192.168.56.101] failed: Connection refused: connect -> [Help 1]
[ERROR]
[ERROR] To see the full stack trace of the errors, re-run Maven with the -e switch.
[ERROR] Re-run Maven using the -X switch to enable full debug logging.
[ERROR]
[ERROR] For more information about the errors and possible solutions, please read the following articles:
[ERROR] [Help 1] http://cwiki.apache.org/confluence/display/MAVEN/MojoExecutionException
```
继续网上搜索,发现在默认情况下Docker守护进程Unix socket(/var/run/docker.sock)来进行本地进程通信,而不会监听任何端口,因此只能在本地使用docker客户端或者使用Docker API进行操作.如果想在其他主机上操作Docker主机,就需要让Docker守护进程打开一个HTTP Socket,这样才能实现远程通信.我们是在windows上打包构建的,所以需要让centos7上的docker服务开启远程访问.

## 8.开启docker远程服务,执行vi命令:
```
vi /usr/lib/systemd/system/docker.service
```
在[Service]部分的最下面添加下面两行:
```
ExecStart=
ExecStart=/usr/bin/dockerd -H tcp://0.0.0.0:2375 -H unix://var/run/docker.sock
```
然后让docker重新读取配置文件,并重启docker服务.
```
systemctl daemon-reload
systemctl restart docker
```
查看docker进程,发现docker守护进程在已经监听2375的tcp端口了.
```
[root@bogon ~]# ps -ef|grep docker
root      1956     1  3 16:32 ?        00:00:00 /usr/bin/dockerd -H tcp://0.0.0.0:2375 -H unix://var/run/docker.sock
root      1959  1956  0 16:32 ?        00:00:00 docker-containerd -l unix:///var/run/docker/libcontainerd/docker-containerd.sock --metrics-interval=0 --start-timeout 2m --state-dir /var/run/docker/libcontainerd/containerd --shim docker-containerd-shim --runtime docker-runc
root      2056  1956  0 16:32 ?        00:00:00 /usr/bin/docker-proxy -proto tcp -host-ip 0.0.0.0 -host-port 5000 -container-ip 172.17.0.2 -container-port 5000
root      2062  1959  0 16:32 ?        00:00:00 docker-containerd-shim ffac4cc26314b42610071b521cbd9c39e00618f4277ca967c1fee31193ff4041 /var/run/docker/libcontainerd/ffac4cc26314b42610071b521cbd9c39e00618f4277ca967c1fee31193ff4041 docker-runc
root      2075  2062  2 16:32 ?        00:00:00 registry serve /etc/docker/registry/config.yml
root      2103  1259  0 16:32 pts/0    00:00:00 grep --color=auto docker
```
最后我们再来执行mvn docker:build命令:
```
[INFO] Building image 192.168.56.101:5000/hello/hello-api:1.0.0
Step 1/5 : FROM java:8
 ---> d23bdf5b1b1b
Step 2/5 : MAINTAINER "zhangzhongwu"<952408421@qq.com>
 ---> Running in 3b331db3b81b
 ---> bae408e908a0
Removing intermediate container 3b331db3b81b
Step 3/5 : ADD hello.jar app.jar
 ---> 3cc7f118a38c
Removing intermediate container 9a3bf9971e98
Step 4/5 : EXPOSE 8080
 ---> Running in 7b5c1dccbd4e
 ---> 5a0c6401e95a
Removing intermediate container 7b5c1dccbd4e
Step 5/5 : CMD java -jar app.jar
 ---> Running in 3ba012d83276
 ---> 68bbcea2575f
Removing intermediate container 3ba012d83276
Successfully built 68bbcea2575f
Successfully tagged 192.168.56.101:5000/hello/hello-api:1.0.0
[INFO] Built 192.168.56.101:5000/hello/hello-api:1.0.0
[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
[INFO] Total time: 23.931 s
[INFO] Finished at: 2018-07-30T16:33:49+08:00
[INFO] Final Memory: 28M/272M
[INFO] ------------------------------------------------------------------------
```
好了,我们可以看到镜像已经构建成功了.

## 9.接下来就是把已经构建好的镜像推送到Docker Registry了.

我们执行mvn docker:build docker:push命令
然后打开linux终端,输入命令docker images查看所有的镜像:

```
[root@bogon ~]# docker images
REPOSITORY                            TAG                 IMAGE ID            CREATED             SIZE
192.168.56.101:5000/hello/hello-api   1.0.0               68bbcea2575f        2 minutes ago       673MB
nginx                                 latest              c82521676580        5 days ago          109MB
registry                              latest              b2b03e9146e1        3 weeks ago         33.3MB
java                                  8                   d23bdf5b1b1b        18 months ago       643MB
[root@bogon ~]#
```
可以看到"192.168.56.101:5000/hello/hello-api"这个镜像,说明我们已经把镜像成功推送到注册中心了.

## 10.最后一步就是运行该镜像,启动容器并将容器的8080端口绑定到宿主机的58080端口上:

```
[root@bogon ~]# docker run -d -p 58080:8080 192.168.56.101:5000/hello/hello-api:1.0.0
9d9363d1213df621c3f610b3466d265332ef42600461ae3e50ff25418b751b65
[root@bogon ~]#
```
执行以下命令验证服务是否启动成功:
```
[root@bogon /]# curl -XGET http://192.168.56.101:58080//hello/hi
hi[root@bogon /]#
```
返回字符串"hi",说明已经成功使用Docker部署Spring Boot项目了.
参考资料:
https://blog.csdn.net/qq_27808181/article/details/78421134
https://blog.csdn.net/faryang/article/details/75949611
https://www.cnblogs.com/zqifa/p/linux-docker-3.html