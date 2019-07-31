### Docker 远程说明
默认情况下，Docker 通过守护进程 Unix socket (/var/run/docker.sock) 来进行本地进程通信，而不会监听任何端口，因此只能在本地使用 docker客户端 或者使用 Docker API 进行操作。
如果想在其他主机上操作 Docker主机 ，就需要让 Docker守护进程 打开一个 HTTP Socket ，这样才能实现远程通信。

### 网上找的一些方法
>说明 fd:// 相当于 unix:///var/run/docker.sock

* 修改 /etc/default/docker 文件的 DOCKER_OPTS ，测试无效。

```
DOCKER_OPTS="-H unix:///var/run/docker.sock -H tcp://0.0.0.0:2375"
```

* 修改 /etc/docker/daemon.json ，测试无效。

```json
{
    "hosts": ["fd://", "tcp://0.0.0.0:2375"]
}
```

* 修改 /lib/systemd/system/docker.service，测试通过。
```
ExecStart=/usr/bin/dockerd -H fd:// -H tcp://0.0.0.0:2375
```

* 重新启动 Docker

```
systemctl daemon-reload
systemctl restart docker.service
```

* 查看本地端口 2375 是否开启

```
root@ubuntu:/# netstat -plnt |grep 2375
tcp6    0    0 :::2375        :::*            LISTEN    22615/dockerd
```