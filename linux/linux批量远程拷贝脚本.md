## 远程拷贝文件到多台服务器脚本

### 服务器列表文件

vim ip.txt
```shell script
10.0.50.102
10.0.50.12
10.0.50.103
10.0.50.13
10.0.50.14
192.168.21.112
192.168.21.128
```

### 批量拷贝脚本

```shell script
#!/bin/bash

password="sofn@123"
password1="abc123"

for ip in $(cat ip.txt)
do
/usr/bin/expect <<-EOF
spawn scp -oStrictHostKeyChecking=no $1 root@${ip}:$2
expect "password:"
send "$password\r"
set timeout 300
expect eof

expect "password:"
send "$password1"
set timeout 300
expect eof
EOF
done
```

> 需要安装expect

## 使用
```
./scp-list.sh /opt/jenkins/docker_start.sh  /opt/jenkins/
```