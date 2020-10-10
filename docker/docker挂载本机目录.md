## Docker容器启动的时候，如果要挂载宿主机的一个目录，可以用-v参数指定。 

比如启动一个centos容器，宿主机的/test目录挂载到容器的/soft目录，可通过以下方式指定：
```
docker run -it -v /test:/soft centos /bin/bash 
```
这样在容器启动后，容器内会自动创建/soft的目录。

>注意： 
容器目录不可以为相对路径，必须以下斜线“/”开头。宿主机的目录最好也是绝对路径。 
挂载宿主机已存在目录后，在容器内对其进行操作，报“Permission denied”。可通过指定–privileged参数来解决：docker run -it --privileged=true -v /test:/soft centos /bin/bash

```
[root@localhost /]# docker run -it -v /storage:/leader-us java /bin/bash
root@c9c916b9a171:/# ls
bin  boot  dev    etc  home  leader-us  lib  lib64  media  mnt  opt  proc  root  run  sbin  srv  sys  tmp  usr  var
root@c9c916b9a171:/# 
```