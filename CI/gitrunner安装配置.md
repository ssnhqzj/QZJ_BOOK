#gitlib runner安装配置

## 1. 安装包下载
```
 https://gitlab-runner-downloads.s3.amazonaws.com/latest/binaries/gitlab-runner-linux-amd64
```

## 2. 安装gitlab-runner
```
#将安装包上传到Linux
$ sudo mv gitlab-runner-linux-amd64 /usr/local/bin/gitlab-runner

#接着授予可执行权限
$ sudo chmod +x /usr/local/bin/gitlab-runner

#创建一个gitlab-ci用户
$ sudo useradd --comment 'GitLab Runner' --create-home gitlab-runner --shell /bin/bash

#安装，并作为服务启动
$ sudo gitlab-runner install --user=gitlab-runner --working-directory=/home/gitlab-runner
```

## 3. 向GitLab-CI注册runner
```
gitlab-runner register
```
> 会要求输入gitlab的url和Token.
> 查找过程如下：
> 进入仓库->settings->CI/CD，找到Runner Settings这一项，点击Expend,即可在Setup a specific Runner manually这项中找到。
> url和token 都可在此位置找到

注册过程如下:
```
# 注册
gitlab-runner register
# 输入本地的gitlab仓库下, settings->CI/CD中找到的URL
Please enter the gitlab-ci coordinator URL (e.g. https://gitlab.com )
https://mesgit.seagate.com/
# 输入 Token
Please enter the gitlab-ci token for this runner
_FTHYNTYU747RzxFCYG
# 输入 tag, 注意要跟 job 的 tag 一致
Please enter the gitlab-ci tags for this runner (comma separated):
my-tag,another-tag
# 选择 executor,有docker选dokcer，没有选shell 
Please enter the executor: ssh, docker+machine, docker-ssh+machine, kubernetes, docker, parallels, virtualbox, docker-ssh, shell:
shell
```

## 4. 启动gitlab-runner
```
gitlab-runner start
```

> 教程上说是使用gitlab-runner start命令，但我试的时候并没有生效，但是用了gitlab run就可以了，建议先使用gitlab-runner start试一下，不行再用gitlab-runner run
> 启动成功后就可以看到，gitlab对应的仓库下（操作：进入仓库->settings->CI/CD，找到Runner Settings这一项，点击Expend,即可在Setup a specific Runner manually）看到注册的runner已经在运行了。

## 5. 常用命令
```
gitlab-ruuner start #启动
gitlab-ruuner restart #重启
gitlab-ruuner stop #停止
gitlab-ruuner run #运行，运行之后gitlab上的runner会显示绿色，否则会显示New runner. Has not connected yet
gitlab-ruuner register #打开注册引导
```