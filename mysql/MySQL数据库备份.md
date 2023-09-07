## 使用AutoMySQLBackup自动备份MySQL数据库

### 创建备份文件夹

```shell
# 在 /databases/backup 目录下创建一个名为 autobackup 的文件夹
mkdir -p /databases/backup/
```

### 下载

```shell
wget https://nchc.dl.sourceforge.net/project/automysqlbackup/AutoMySQLBackup/AutoMySQLBackup%20VER%203.0/automysqlbackup-v3.0_rc6.tar.gz
```

### 解压

```shell
# 将文件解压到/usr/local/autobackup目录下
tar -zxvf automysqlbackup-v3.0_rc6.tar.gz -C /usr/local/autobackup/
```

### 安装

```shell
# 并按回车键开始安装。提示输入全局配置命令和执行目录，可根据您的需求进行变更，本例中保存不变，直接按回车键。提示已经安装完毕。
sudo ./install.sh
```

### 查看安装目录

```shell
ls /etc/automysqlbackup/
```

### 编辑配置文件

```shell
vi /etc/automysqlbackup/automysqlbackup.conf
#访问数据库的账号（本例中为root）
CONFIG_mysql_dump_username='root' 
#访问数据库的密码（本例中为方便起见设置为aut0test，实际使用时请设置为足够复杂的密码）. 
CONFIG_mysql_dump_password='aut0test' 
#要备份服务器的主机名（本例中为本机，故设置为localhost）. 
CONFIG_mysql_dump_host='localhost' 
#实际使用中请修改为正确的备份目录. 
CONFIG_backup_dir='/tmp/dbbackup' 
#本例中要备份数据库名称为testbackup 
CONFIG_db_names=(testbackup) 
#即每月1号进行月备份。 
CONFIG_do_monthly="01"
#即每星期五进行周备份。  
CONFIG_do_weekly="5" 
#即每2*24小时删除旧的日备份 
CONFIG_rotation_daily=2 
#即每60*24小时删除旧的周备份 
CONFIG_rotation_weekly=60 
#即每160*24小时删除旧的月备份
CONFIG_rotation_monthly=160 
#不设置成no会提示错误
CONFIG_mysql_dump_usessl='no'
```

### 创建定时任务执行脚本
```shell
#!/bin/sh
/usr/local/bin/automysqlbackup /etc/automysqlbackup/automysqlbackup.conf
```

### 配置定时执行
```shell
# 查看定时任务
crontab -l

#配置定时任务
crontab -e
#定时任务，13:46执行
46 13 * * * /usr/local/bin/backupscript.sh
```


