一、SCP
基本格式：
本地主机的文件拷贝到远程主机

```
scp [参数] 文件名 远程主机的用户名@192.168.0.xxx:/目录
```
例：
```
scp xx.ko yyy@192.168.0.145:/root/file
```

把远程主机的文件拷贝到本地主机

```
scp  远程主机的用户名@192.168.0.xxx:/目录  本地主机目录
```
例：
```
scp yyy@192.168.0.145:/root/file /home/pi/file
```

参数：
```
-1  强制scp命令使用协议ssh1 
-2  强制scp命令使用协议ssh2 
-4  强制scp命令只使用IPv4寻址 
-6  强制scp命令只使用IPv6寻址 
-B  使用批处理模式（传输过程中不询问传输口令或短语） 
-C  允许压缩。（将-C标志传递给ssh，从而打开压缩功能） 
-p  保留原文件的修改时间，访问时间和访问权限。 
-q  不显示传输进度条。 
-r  递归复制整个目录。 
-v 详细方式显示输出。scp和ssh(1)会显示出整个过程的调试信息。这些信息用于调试连接，验证和配置问题。  
-c cipher  以cipher将数据传输进行加密，这个选项将直接传递给ssh。  
-F ssh_config  指定一个替代的ssh配置文件，此参数直接传递给ssh。 
-i identity_file  从指定文件中读取传输时使用的密钥文件，此参数直接传递给ssh。   
-l limit  限定用户所能使用的带宽，以Kbit/s为单位。    
-o ssh_option  如果习惯于使用ssh_config(5)中的参数传递方式，  
-P port  注意是大写的P, port是指定数据传输用到的端口号  
-S program  指定加密传输时所使用的程序。此程序必须能够理解ssh(1)的选项。
```

例：改变端口
```
scp -P 23 文件名 目标用户名@192.168.0.xxx:/目录
```

二、RSYNC
基本格式：
本地主机的文件拷贝到远程主机
```
rsync [参数] 文件名 远程主机的用户名@192.168.0.xxx:/目录
```

把远程主机的文件拷贝到本地主机
```
rsync [参数] 远程主机的用户名@192.168.0.xxx:/目录  本地主机目录
```

参数：
常用组合 -avzP
```
-a ：归档模式，表示以递归模式传输文件，并保持文件所有属性相当于-rtopgdl
-v :详细模式输出，传输时的进度等信息
-z :传输时进行压缩以提高效率—compress-level=num可按级别压缩
-r :对子目录以递归模式，即目录下的所有目录都同样传输。
-t :保持文件的时间信息—time
-o ：保持文件属主信息owner
-p ：保持文件权限
-g ：保持文件的属组信息
-P :--progress 显示同步的过程及传输时的进度等信息
-e ：使用的信道协议，指定替代rsh的shell程序。例如：ssh
-D :保持设备文件信息
-l ：--links 保留软连接
--progress  :显示备份过程
--delete    :删除那些DST中SRC没有的文件
--exclude=PATTERN 　指定排除不需要传输的文件模式
-u, --update 仅仅进行更新，也就是跳过所有已经存在于DST，并且文件时间晚于要备份的文件。(不覆盖更新的文件)
-b, --backup 创建备份，也就是对于目的已经存在有同样的文件名时，将老的文件重新命名为~filename。
-suffix=SUFFIX 定义备份文件前缀
-stats 给出某些文件的传输状态
-R, --relative 使用相对路径信息  如：rsync foo/bar/foo.c remote:/tmp/   则在/tmp目录下创建foo.c文件，而如果使用-R参数：rsync -R foo/bar/foo.c remote:/tmp/     则会创建文件/tmp/foo/bar/foo.c，也就是会保持完全路径信息。
--config=FILE 指定其他的配置文件，不使用默认的rsyncd.conf文件
--port=PORT 指定其他的rsync服务端口
```

三、RSYNC和SCP的区别
```
RSYNC：只传输修改过的文件，并保持文件的修改时间、权限等信息。
SCP：所有文件都传输，系统开销少。```

四、SCP的BUG问题

```
传输到远程主机时：
1、Permission denied报错
在这里插入图片描述
方法1：登录远程主机，然后对作为传输目标的远程主机的目录更改权限；本地主机切换root账户
例：scp [参数] 文件名 远程主机的用户名@192.168.0.xxx:/home/xxx

sudo chmod 777  /home/xxx
1
方法2：拷贝到远程主机的tmp目录下，scp默认对tmp有权限。

2、lost connection报错
在这里插入图片描述
本地主机和远程主机安装openssh-server并且保证都在同一局域网内
```