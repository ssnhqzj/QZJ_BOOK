### 安装docker 镜像文件

```bash
# 选择执行
sudo apt-get update
sudo apt-get install linux-image-extra-$(uname -r) linux-image-extra-virtual
```

### 安装软件包，允许apt 通过https 使用存储库

```bash
sudo apt-get install apt-transport-https ca-certificates curl software-properties-common 
```

### 添加docker官网的GPG秘钥

```bash
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
# 9DC8 5822 9FC7 DD38 854A E2D8 8D81 803C 0EBF CD88通过搜索指纹的最后8个字符，验证您现在是否具有指纹的密钥 
sudo apt-key fingerprint 0EBFCD88
```

### 设置存储库版本

```bash
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
```

### 更新apt包

```bash
apt-get update
```

### 列出可用的版本

```bash
apt-cache madison docker-ce
```

### 安装选定版本

```bash
apt-get install docker-ce=<VERSION>
```

### 验证docker

```bash
# 查看docker服务是否启动：
systemctl status docker

# 若未启动，则启动docker服务：
systemctl start docker
```