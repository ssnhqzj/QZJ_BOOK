## 前置条件

* 安装docker

* 安装docker-compose

## 下载安装包

* github上下载harhor安装包

* 解压

```
tar -zxvf harbor-offline-installer-v1.7.1.tgz
```

## 编辑配置文件

* harbor.yml 是这个项目的配置文件

```
cp harbor.yml.tmpl harbor.yml
```

* 修改hostname选项

```
hostname = A.B.C.D  # 写你自己的网址或IP，公网访问要写公网IP
```

## 运行

* 修改完配置文件后，运行 ./prepare

* 运行 ./install.sh

* 运行成功，docker ps 查看，可以看到服务已经起来了。

## 常用管理命令

```
docker-compose up -d 启动
docker-compose stop 停止
docker-compose restart 重新启动
```

## 访问
```
访问地址：http://172.16.46.111
默认的账号密码：admin/Harbor12345
```

