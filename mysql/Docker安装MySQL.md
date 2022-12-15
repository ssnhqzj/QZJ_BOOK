#### 1. apt install docker.io 命令安装docker

#### 2. docker search mysql 查找MySQL镜像

#### 3. docker pull mysql 拉取官方镜像

#### 4. docker images 查看MySQL镜像的相关信息

#### 5. REPOSITORY：表示镜像的仓库源
+ TAG：镜像的标签
+ IMAGE ID：镜像ID
+ CREATED：镜像创建时间
+ SIZE：镜像大小

可以本地镜像列表里查到REPOSITORY为mysql,标签为latest的mysql镜像。

#### 6. 使用容器运行mysql镜像
```
docker run --name mysqldb -p 3306:3306 -e MYSQL_ROOT_PASSWORD=123456 -d mysql:latest

// 表名大小写不敏感
docker run --name mysqldb -p 3306:3306 -e MYSQL_ROOT_PASSWORD=123456 -d mysql:latest --lower_case_table_names=1

docker run --name mysqldb -p 3306:3306 -e MYSQL_ROOT_PASSWORD=jzt@91530127MA6NH14262# -d mysql:latest --lower_case_table_names=1

docker run --name mysqldb -p 6033:3306 -e MYSQL_ROOT_PASSWORD=ZHANG#peng#880322# -d mysql:5.7 --lower_case_table_names=1
docker run --name mysqldb -p 6033:3306 -e MYSQL_ROOT_PASSWORD=honeybeeUstar999# -d mysql:5.7 --lower_case_table_names=1
docker run --name mysqldb --restart=always -p 3306:3306 -e MYSQL_ROOT_PASSWORD=123456 -d mysql:8.0 --lower_case_table_names=1 
```

挂载目录方式：
```
docker run -d --name mysql \
--privileged=true \
--restart=always \
-p 6033:3306 \
-e MYSQL_ROOT_PASSWORD=honeybeeUstar999# \
-v /etc/mysql:/etc/mysql \
-v /opt/mysql:/var/lib/mysql \
-v /etc/localtime:/etc/localtime \
mysql:5.7 --lower_case_table_names=1
```
这里的容器名字叫：mysqldb，mysql的root用户密码是：123456，映射宿主机子的端口3306到容器的端口3306，仓库名mysql和标签(tag)latest唯一确定了要指定的镜像。注意：就算这里只有一个mysql也有必须要有tag

#### 7. docker ps 查看容器启动情况

#### 8. 至此，使用docker安装mysql的工作就已经完成了。以后使用如下命令开启并执行名为mysqldb的容器：
```
$ docker start mysqldb
$ docker exec -it mysqldb /bin/bash
```
使用如下命令关闭名为mysqldb的容器：
```
docker stop mysqldb
```

#### 9. 输入命令连接mysql：
```
mysql -u root -p
```

#### 10. 解决无法连接数据库authentication plugin 'caching_sha2_password'问题
```
ALTER USER 'root'@'%' IDENTIFIED WITH mysql_native_password BY '123456';
ALTER USER 'root'@'%' IDENTIFIED WITH mysql_native_password BY 'honeybeeUstar999#';

GRANT ALL PRIVILEGES ON *.* TO root@'%' IDENTIFIED BY '123456' WITH GRANT OPTION;

```

#### 可进入docker容器内部用以下命令查看mysql配置文件位置
```
# 查找Docker内，MySQL配置文件my.cnf的位置

mysql --help | grep my.cnf
```

#### 修改Mysql 数据库的 only_full_group_by 模式
```shell script
#拷贝出文件
docker cp  mysqldb:/etc/mysql/mysql.conf.d/mysqld.cnf /mysqld.cnf
#编辑
vim /mysqld.cnf
#最后加入以下内容：
sql_mode=STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION
# 再拷贝进入
docker cp /mysqld.cnf mysqldb:/etc/mysql/mysql.conf.d/mysqld.cnf
```
