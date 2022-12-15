```
cd /lib/systemd/system/
vim docker.service
```

#在原本的
ExecStart
中添加
tcp://0.0.0.0:2375

```
[Service] Type=notify
# the default is not to use systemd for cgroups because the delegate issues still
# exists and systemd currently does not support the cgroup feature set required
# for containers run by docker
ExecStart=/usr/bin/dockerd -H tcp://0.0.0.0:2375 -H unix://var/run/docker.sock --containerd=/run/containerd/containerd.sock
ExecReload=/bin/kill -s HUP $MAINPID
TimeoutSec=0
RestartSec=2
Restart=always
```

```
 systemctl daemon-reload 
 systemctl restart docker.service
```