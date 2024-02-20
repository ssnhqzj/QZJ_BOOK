1，在一台服务器（master）上使用【ssh-keygen -t rsa】命和令创建 rsa类型的 公钥 和 私钥。（命令执行过程中按三次回车就行）。产生的公钥和私钥存放在 /.ssh/目录下；

2，在master 上使用 【ssh-copy-id root@slave1】命令将公钥拷给要免密登录的机器slave1(前提 在主机/etc/hosts 文件中配置了该主机名，否则只能直接使用主机ip);

3,测试，在master上使用 【ssh slave1】看能否登录成功。登陆成功后使用【exit】退出登录。