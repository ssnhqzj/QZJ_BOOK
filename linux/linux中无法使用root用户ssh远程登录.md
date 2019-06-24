一，修改root用户密码

```
sudo su -   #切换到root用户
 
sudo passwd -u root
sudo passwd root  #设置密码
```

二，编辑 /etc/ssh/sshd_config文件

```
cd /etc/ssh/
ls
vi sshd_config

　找到PermitRootLogin，注释掉这一行

  添加PermitRootLogin yes，保存，退出。
```


三，执行 sudo service sshd restart 

四，查看 ps -au|grep sshd 。中，有root用户