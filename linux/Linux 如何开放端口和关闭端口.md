一、查看哪些端口被打开 
```
netstat -anp
```

二、关闭端口号:
```
iptables -A OUTPUT -p tcp --dport 端口号 -j DROP
```

三、打开端口号：
```
iptables -A INPUT -ptcp --dport  端口号 -j ACCEPT
```

四、保存设置
```
service iptables save
```

五、以下是linux打开端口命令的使用方法。
```
　　nc -lp 23 &(打开23端口，即telnet)
　　netstat -an | grep 23 (查看是否打开23端口)
```
六、linux打开端口命令每一个打开的端口，都需要有相应的监听程序才可以

七、查看iptables打开的端口
```
iptables -L -n
```

```
vim /etc/sysconfig/iptables

# 在/etc/sysconfig/iptables加上这句
-A INPUT -p tcp -m tcp --dport 9000 -j ACCEPT

# 重启iptables
service iptables restart
```
