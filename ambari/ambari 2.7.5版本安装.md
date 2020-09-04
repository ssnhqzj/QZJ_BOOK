## centos安装ambari

### 一 必要工具安装：

#### 1.1 jdk 1.8以上版本安装

#### 1.2 maven 3.3.9以上版本安装
maven需要配置阿里镜像源，提升下载依赖包速度

#### 1.3 Python 2.7以上版本安装

----
先安装 GCC 包，如果没安装 GCC包 就输入以下命令行安装；
（*注：以下记得使用 su 权限）

```
yum install gcc openssl-devel bzip2-devel
```

用 wget 下载 python 2.7 并解压
如果没有 wget，先用下面命令安装 wget；

```
yum -y install wget　　
```

进入目录 /usr/src  再用 wget 下载 python 2.7

```
cd /usr/src
wget https://www.python.org/ftp/python/2.7.15/Python-2.7.15.tgz
```

再解压 python2.7

```
tar -zxvf Python-2.7.15.tgz
```

安装 python 2.7
 进入上面解压的 Python-2.7.15 解压文件中使用下面命令行安装

```
cd Python-2.7.15
./configure --enable-optimizations
make altinstall
```

查看安装版本
```
python -V
```
可以看到输出 Python 2.7.15 就安装完成。

----

#### 1.4 Python setuptools: for Python 2.7:  Download setuptools and run:

下载地址：

<https://pypi.python.org/packages/2.7/s/setuptools/setuptools-0.6c11-py2.7.egg#md5=fe1f997bc722265116870bc7919059ea>

```
sh setuptools-0.6c11-py2.7.egg
```

#### 1.5 安装rpmbuild (rpm-build package)
```
yum　install rpm-build
```

#### 1.6 安装 g++ (gcc-c++ package)
```
yum install gcc
yum install gcc-c++
```


         
