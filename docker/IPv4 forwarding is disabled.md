### Docker报错：“WARNING: IPv4 forwarding is disabled. Networking will not work.”解决。
 
服务器停机，然后ip莫名被占用，修改新的ip之后，ssh能够连接上去，但是web服务访问不了，数据库访问不了，除了22端口，其它服务端口都不能telnet。

防火前、IPtables、selinux全都关闭，问题存在。

久经折腾之下，觉得Docker的那个端口映射是不是也要重新映射一次？

想到此，于是执行端口映射命令，却报错：  
```
WARNING: IPv4 forwarding is disabled. Networking will not work

```

### 问题解决 
Google 一下报错信息，得到问题解决方法。

```
 vi /etc/sysctl.conf

# 新增一行
 net.ipv4.ip_forward=1
 
#  重启network服务
systemctl restart network

# 查看是否修改成功
sysctl net.ipv4.ip_forward

（返回为“net.ipv4.ip_forward = 1”，表示成功）
```

然后，重启容器即可。

### 问题原因 
“ default the ipv4 forwarding is not turned on in theimage from docker
to prevent any security vulnerabilities. ”

Docker处于安全考虑默认关闭该设置。