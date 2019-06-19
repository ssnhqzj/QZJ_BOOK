```
# service iptables save
The service command supports only basic LSB actions (start, stop, restart, try-restart, reload, force-reload, status). For other actions, please try to use systemctl.
```

出错信息如上所示

本人原来使用的是CentOS6.X版本的Linux，后来为了学习更多内容选择更换CentOS7.X，然后在配置防火墙的时候出现了上面所示的错误，原因：CentOS 7.x开始，CentOS开始使用systemd服务来代替daemon，原来管理系统启动和管理系统服务的相关命令全部由systemctl命令来代替。service命令只保留下了极少部分使用，大部分命令都要改用systemctl使用。

在RHEL 7 / CentOS 7中，firewalld被引入来管理iptables。个人觉得, firewalld更适合于工作站而不是服务器环境。
可以回到更经典的iptables设置来解决上面的问题

下面就谈谈上面错误的解决方案。

首先停止防火墙

```
1.systemctl stop firewalld
```
```
2.systemctl mask firewalld
```
然后安装iptables-services

```
3.yum install iptables-services
```
设置开机启动防火墙

```
4.systemctl enable iptables
```
可以使用下面命令管理iptables

```
5.systemctl [stop|start|restart] iptables
```
这时可以保存防火墙规则了
```
6.service iptables save
or
/usr/libexec/iptables/iptables.init save
```
问题就解决了，至于需不需要sudo权限，根据具体环境而定
