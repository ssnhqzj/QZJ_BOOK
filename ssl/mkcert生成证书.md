# linux下使用mkcert生成证书
## 下载mkcert
在github中下载linux版本文件mkcert-v1.4.4-linux-amd64

github地址：https://github.com/FiloSottile/mkcert

## 安装
1. 将安装文件拷贝到linux服务器上
2. cd到文件目录下
3. 对文件进行授权
```shell
chmod +x mkcert-v1.4.4-linux-amd64
```
4. 安装根证书
```shell
./mkcert-v1.4.4-linux-amd64 -install
```
5. 执行命令查询CA证书目录，并将pem文件拷贝出来，如示例rootCA.pem
```shell
./mkcert-v1.4.4-linux-amd64 -CAROOT
```

## 签发本地证书
```shell
./mkcert-v1.4.4-linux-amd64 localhost 127.0.0.1 ::1 10.8.1.163
```
> 根据自己的需求填写ip可以有多个ip。（如上所示，就使用localhost、127.0.0.1、::1、192.168.1.1）这四个地址，
> 生成对应的证书，也就是这个证书中，是根据这个四个地址生成的。
> 在IP地址中，::1 是一个特殊的IPv6地址，被称为回环地址（loopback address）。在IPv4中，
> 回环地址是 127.0.0.1。IPv6的回环地址 ::1 与IPv4的 127.0.0.1 在功能上是相似的。

证书生成在当前目录下

## 配置nginx证书
nginx目录创建cer目录，将10.8.1.163.pem/10.8.1.163-key.pem拷贝到目录中，进行nginx配置ssl访问
```shell
server {
        listen       443 ssl;
        server_name  localhost;

        ssl_certificate      cer/10.8.1.163.pem;
        ssl_certificate_key  cer/10.8.1.163-key.pem;
        ssl_session_cache    shared:SSL:1m;
        ssl_session_timeout  5m;
        ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:HIGH:!aNULL:!MD5:!RC4:!DHE;
        #ssl_ciphers  HIGH:!aNULL:!MD5;
        ssl_prefer_server_ciphers  on;

          location / {
            root   /usr/share/nginx/html;
            index  index.html index.htm;
       }
```

## 客户端电脑安装根证书
将第4步的rootCA.pem根证书，增加扩展名改为rootCA.pem.cer，拷贝到需要访问https的windows电脑上
双击rootCA.pem.cer文件–安装证书–下一步–将所有证书都放入下列存储，浏览选择受信人的根证书颁发机构–下一步–完成
