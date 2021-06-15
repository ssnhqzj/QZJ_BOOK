# Linux安装Gitlab

## 1.配置yum源
```shell script
vim /etc/yum.repos.d/gitlab-ce.repo
```
复制以下内容：
```shell script
[gitlab-ce]
name=Gitlab CE Repository
baseurl=https://mirrors.tuna.tsinghua.edu.cn/gitlab-ce/yum/el$releasever/
gpgcheck=0
enabled=1
```

## 2.更新本地yum缓存
```shell script
yum makecache
```

## 3.安装GitLab社区版
```shell script
yum install gitlab-ce #自动安装最新版本
```
> 注：若需安装指定版本，则添加版本号即可，即yum install gitlab-ce-x.x.x

## 4.开启GitLab
```shell script
gitlab-ctl start
```

## 5.GitLab常用命令
```shell script
# 启动所有 gitlab 组件；
gitlab-ctl start 
# 停止所有 gitlab 组件；
gitlab-ctl stop 
 # 重启所有 gitlab 组件；
gitlab-ctl restart
# 查看服务状态；
gitlab-ctl status 
# 启动服务；（重新加载配置文件，在GitLab初次安装后可以使用，但是在业务环境中不可随意使用，reconfigure会把一些过去的config还原，
# 导致修改的端口以及域名等都没有了。）
gitlab-ctl reconfigure 
# 修改默认的配置文件；
vim /etc/gitlab/gitlab.rb 
# 检查gitlab
gitlab-rake gitlab:check SANITIZE=true --trace
# 查看日志；
sudo gitlab-ctl tail
```

# GitLab使用
## 1.登录GitLab
在浏览器的地址栏中输入服务器的公网IP即可显示GitLab的界面。首次登录会强制用户修改密码。密码修改成功后，输入用户名和密码进行登录。
> 注：若无法访问，则可以使用ps -ef命令查看服务是否正常启动，若未启动， 则重新开启，若仍然启动不了，则可使用gitlab-ctl reconfigure
>（仅限初始环境下使用）命令启动服务， 然后再访问GitLab。

![](res_gitlab/gitlab-01.png)


## 2. gitlab服务端口修改
```shell script
vim /var/opt/gitlab/nginx/conf/gitlab-http.conf


###################################
##         configuration         ##
###################################
 
upstream gitlab-workhorse {
  server unix:/var/opt/gitlab/gitlab-workhorse/socket;
}
server {
  #此处修改端口即可
  listen *:8888;  
}
```
> 重启服务： gitlab-ctl restart

## 3. 修改域名
由于没有DNS服务器，无法进行域名解析，所以需要将域名修改为主机名，进入终端修改一下文件即可。
```shell script
vim /opt/gitlab/embedded/service/gitlab-rails/config/gitlab.yml

gitlab:
    ## Web server settings (note: host is the FQDN, do not include http://)
    host: 10.0.0.210
    port: 8888
    https: false
```


