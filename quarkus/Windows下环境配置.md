[TOC]

# 环境配置

## 安装jdk或GraalVM
运行环境需要安装java环境，可选择安装jdk11+或GraalVM，如需编译成原生可执行文件，GraalVM是必须安装的，否则安装jdk11以上即可

### jdk安装
略

### GraalVm安装
- 在官方网站下载GraalVM包，下载社区版即可，选择Java 11或Java 17均可，下载后解压到任意目录中

[GraalVM官网](https://www.graalvm.org/)
- 配置环境变量，将GraalVM目录下的bin加入到path中
  GRAALVM_HOME=D:\Program Files\graalvm-ce-java11-22.2.0
  %GRAALVM_HOME%\bin

- 查看是否配置成功，看到GraalVM的版本号即成功了
```shell
C:\Users\34541>java -version
openjdk version "11.0.16" 2022-07-19
OpenJDK Runtime Environment GraalVM CE 22.2.0 (build 11.0.16+8-jvmci-22.2-b06)
OpenJDK 64-Bit Server VM GraalVM CE 22.2.0 (build 11.0.16+8-jvmci-22.2-b06, mixed mode, sharing)
```

## 安装maven
maven需要Apache Maven 3.8.1+

## 安装C语言开发环境(编译原生文件需要)
### 安装VS C++
[在Windows上，你将需要安装 Visual Studio 2017 Visual C++构建工具](https://download.visualstudio.microsoft.com/download/pr/95ddd5af-e01b-4f9f-a8ee-cb0e4c4640af/6702bf310b6d5a3f9fba9333f60f9c053227bf57df46b7a661e431181cccf72b/vs_BuildTools.exe)
在安装环节中选择安装visual C++生成工具即可，其他默认
> 特别需要注意的地方是需要在语言包选项卡中取消中文，勾选英文，否则使用中文语言包在构建原生文件时会出现错误

### 配置环境变量
```shell
WK10_INCLUDE=C:\Program Files (x86)\Windows Kits\10\Include\10.0.19041.0
WK10_LIB=C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0
INCLUDE=%WK10_INCLUDE%\ucrt;%WK10_INCLUDE%\um;%WK10_INCLUDE%\shared;%MSVC%\include;
LIB=%WK10_LIB%\um\x64;%WK10_LIB%\ucrt\x64;%MSVC%\lib\x64;%MSVC%\bin\Hostx64\x64;
```
> 把INCLUDE和LIB加入到path中

## 安装native-image(编译原生文件需要)
使用 gu install 安装 native-image 工具：
```shell
${GRAALVM_HOME}/bin/gu install native-image
```

## 创建一个Quarkus项目
创建quarkus项目有多种方式，可以选择idea工具创建，也可以使用maven、gradle命令以及官方提供的CLI工具创建，例如使用maven创建：
```shell
mvn io.quarkus.platform:quarkus-maven-plugin:2.12.3.Final:create \
    -DprojectGroupId=org.acme \
    -DprojectArtifactId=getting-started \
    -Dextensions="resteasy-reactive"
```

## 打包成可执行文件
在项目目录中执行以下命令编译，编译完成即可在target目录中生成一个.exe文件
```shell
mvnw package -Dnative
```


