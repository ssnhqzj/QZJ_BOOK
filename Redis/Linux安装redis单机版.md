版权声明：本文为博主原创文章，遵循 CC 4.0 BY-SA 版权协议，转载请附上原文出处链接和本声明。
本文链接：https://blog.csdn.net/u011669700/article/details/79566713

Linux安装Redis
系统版本为centOS 7.3

一、下载Redis
在官网中下载Redis，下载地址为：http://www.redis.cn/


也可使用wget命令进行下载：

wget http://download.redis.io/releases/redis-4.0.8.tar.gz
1
可以看到我们当前安装的Redis服务版本为4.0.8

二、解压
tar -zxvf redis-4.0.8.tar.gz
1
就可以获取到解压之后的源码包redis-4.0.8，之后进入到该目录中。

三、编译
在进入到该目录下输入命令：

make
1
redis linux安装 [adlist.o] Error jemalloc/jemalloc.h: No such file or directory

就开启了Redis的编译状态，在编译完成之后可以看到类似如下的信息提示：

        CC rax.o
    LINK redis-server
    INSTALL redis-sentinel
    CC redis-cli.o
    LINK redis-cli
    CC redis-benchmark.o
    LINK redis-benchmark
    INSTALL redis-check-rdb
    INSTALL redis-check-aof

Hint: It's a good idea to run 'make test' ;)

make[1]: Leaving directory `/mnt/vdb/software/redis-4.0.8/src'
1
2
3
4
5
6
7
8
9
10
11
12
13
应当运行make test命令
源码文件被移动到当前目录的src文件夹下面。
四、安装
进入到源码目录src下，输入对应的安装命令：

cd src
make install
1
2
安装完成之后的提示结果为：

Hint: It's a good idea to run 'make test' ;)

    INSTALL install
    INSTALL install
    INSTALL install
    INSTALL install
    INSTALL install
1
2
3
4
5
6
7
五、文件移动
在经过make install命令对Redis进行安装之后，我们可以看到文件夹下面的文件列表：


文件移动的目的是为了对Redis的配置和服务启动进行管理：

bin用于存放命令
etc拥有存放配置文件
我们返回上级目录，也就是在redis-4.0.8这个文件夹中进行文件夹的创建：

cd ..
mkdir etc
mkdir bin
1
2
3
之后使用命令将对应的文件移动到对应目录下：

[root@i-6d7c3830 redis-4.0.8]# mv redis.conf etc/
[root@i-6d7c3830 redis-4.0.8]# cd src
[root@i-6d7c3830 redis-4.0.8]# mv mkreleasehdr.sh  redis-benchmark  redis-check-aof  redis-check-rdb  redis-cli  redis-sentinel  redis-server  redis-trib.rb ../bin
1
2
3
六、Redis服务启动
进入到bin目录下面，进行Redis服务的启动：

./redis-server
1


在这里可以看到服务已经启动起来，但是并没有使用到etc/redis.conf配置文件。目前还是使用默认配置进行服务的启动。先使用ctrl + c停止当前服务。我们可以看到如下提示信息：

^C6443:signal-handler (1521089911) Received SIGINT scheduling shutdown...
6443:M 15 Mar 12:58:31.994 # User requested shutdown...
6443:M 15 Mar 12:58:31.995 * Saving the final RDB snapshot before exiting.
6443:M 15 Mar 12:58:32.003 * DB saved on disk
6443:M 15 Mar 12:58:32.003 # Redis is now ready to exit, bye bye...
1
2
3
4
5
我们运行pstree -p | grep redis也可以发现Redis服务已经被完全终止。

接下来使用命名带上配置文件一起运行

#./redis-server /path/to/redis.conf
./redis-server /mnt/vdb/software/redis-4.0.8/etc/redis.conf
1
2
但是现在依旧是前台运行，在我们修改配置文件之后才可以后台运行。需要将daemonize配置为true。

搜索 ：’\daemonize’
把daemonize配置项改为yes
保存退出
在vim命令模式下，输入’/'即进入搜索模式，输入想输入的字符串即可进行搜索

在使用以上加载配置文件的命令启动Redis服务即可看到如下提示：

Redis进入后台启动模式。使用命令：

pstree -p | grep redis
1
可以看到提示：

|-redis-server(7509)-+-{redis-server}(7510)
       |                    |-{redis-server}(7511)
       |                    `-{redis-server}(7512)
1
2
3
证明Redis服务正在运行。
其中Redis服务的默认端口号为6379。
我们可以使用如下命令查看端口占用情况：

lsof -i tcp:6379
1
可以看到如下提示：

redis-ser 13689 root    6u  IPv6  54678      0t0  TCP *:6379 (LISTEN)
redis-ser 13689 root    7u  IPv4  54679      0t0  TCP *:6379 (LISTEN)
1
2
证明该端口被Redis服务所占用。
注意，redis服务需要 root 权限才能查看，不然只能检查到6379被某个进程占用，但是看不到进程名称。
至此，redis服务已经按照配置文件启动成功！！

七、客户端登录
使用命令

./redis-cli
1
就会进入对应的命令行：

[root@i-6d7c3830 bin]# ./redis-cli
127.0.0.1:6379>
1
2
表明客户端登录成功，可以使用exit退出命令行。

八、Redis服务关闭
pkill redis-server
在Redis的bin目录下/redis-cli shutdown
还可以使用 killall 和kill -9对服务进行关闭。

九、附录：配置信息
daemonize 如果需要在后台运行，把该项改为yes
pidfile 配置多个pid的地址 默认在/var/run/redis. pid
bind 绑定ip，设置后只接受来自该ip的请求
port 监听端口，默认是6379
loglevel 分为4个等级：debug verbose notice warning
logfile 用于配置log文件地址
databases 设置数据库个数，默认使用的数据库为0
save 设置redis进行数据库镜像的频率。
rdbcompression 在进行镜像备份时，是否进行压缩
dbfilename 镜像备份文件的文件名
Dir 数据库镜像备份的文件放置路径
Slaveof 设置数据库为其他数据库的从数据库
Masterauth 主数据库连接需要的密码验证
Requriepass 设置 登陆时需要使用密码
Maxclients 限制同时使用的客户数量
Maxmemory 设置redis能够使用的最大内存
Appendonly 开启append only模式
Appendfsync 设置对appendonly. aof文件同步的频率（对数据进行备份的第二种方式）
vm-enabled 是否开启虚拟内存支持 （vm开头的参数都是配置虚拟内存的）
vm-swap-file 设置虚拟内存的交换文件路径
vm-max-memory 设置redis使用的最大物理内存大小
vm-page-size 设置虚拟内存的页大小
vm-pages 设置交换文件的总的page数量
vm-max-threads 设置VM IO同时使用的线程数量
Glueoutputbuf 把小的输出缓存存放在一起
hash-max-zipmap-entries 设置hash的临界值
Activerehashing 重新hash
参考资料：

http://blog.csdn.net/baidu_30000217/article/details/51476712
————————————————
版权声明：本文为CSDN博主「寒沧」的原创文章，遵循 CC 4.0 BY-SA 版权协议，转载请附上原文出处链接及本声明。
原文链接：https://blog.csdn.net/u011669700/article/details/79566713