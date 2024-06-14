# idea搭建Hadoop开发环境
## 配置hadoop的环境变量
增加系统变量HADOOP_HOME，变量值为hadoop-2.7.5.rar压缩包解压所在的目录
在系统变量中对变量名为PATH的系统变量追加变量值，变量值为 %HADOOP_HOME%\bin

## 新建一个maven工程
打开IDEA，依次点击“File”→“New”→“Project”，点击左侧Maven，勾选上方“Create from archetype”， 在下方列表中选择
org.apache.maven.archetypes:maven-archetype-quickstart，点击“Next”，文件建好之后，在Project框中src/main目录中新建目录resources。

## 下载远程Hadoop配置文件
将远程集群的Hadoop安装目录下hadoop/hadoop-2.7.5/etc/hadoop目录下的
- core-site.xml
- hdfs-site.xml
- log4j.properties
文件通过Xftp等SFTP文件传输软件将两个文件复制，并移动到上述src/main/resources目录中（拖拽即可），然后将下载的log4j.properties文件移动到src/main/resources目录中（防止不输出日志文件）

## 导入winutils
从地址：https://github.com/cdarlint/winutils/tree/master 中下载对应Hadoop版本的winutils.exe、hadoop.dll文件。
- winutils.exe 放入到hadoop-2.7.5/bin目录下
- hadoop.dll 放入到C:\Windows\System32目录下


## 引入pom文件
使用下面的pom.xml文件覆盖项目本身的pom.xml文件（直接拖拽即可），该文件中的一些版本号（比如JDK、Hadoop等）修改为自己电脑中对应的版本
```xml
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <parent>
        <artifactId>hadoop</artifactId>
        <groupId>com.qzj.demo</groupId>
        <version>1.0.0</version>
    </parent>
    <modelVersion>4.0.0</modelVersion>

    <artifactId>word-count</artifactId>
    <packaging>jar</packaging>

    <name>word-count</name>
    <url>http://maven.apache.org</url>

    <properties>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
        <hadoop.version>2.7.5</hadoop.version>
        <jdkLevel>1.8</jdkLevel>
    </properties>


    <dependencies>
        <dependency>
            <groupId>junit</groupId>
            <artifactId>junit</artifactId>
            <version>3.8.1</version>
            <scope>test</scope>
        </dependency>

        <dependency>
            <groupId>org.apache.hadoop</groupId>
            <artifactId>hadoop-hdfs</artifactId>
            <version>${hadoop.version}</version>
        </dependency>
        <dependency>
            <groupId>org.apache.hadoop</groupId>
            <artifactId>hadoop-common</artifactId>
            <version>${hadoop.version}</version>
        </dependency>
        <dependency>
            <groupId>org.apache.hadoop</groupId>
            <artifactId>hadoop-mapreduce-client-core</artifactId>
            <version>${hadoop.version}</version>
        </dependency>
        <dependency>
            <groupId>org.apache.hadoop</groupId>
            <artifactId>hadoop-client</artifactId>
            <version>${hadoop.version}</version>
        </dependency>
        <dependency>
            <groupId>cn.hutool</groupId>
            <artifactId>hutool-all</artifactId>
            <version>4.1.7</version>
        </dependency>
        <dependency>
            <groupId>junit</groupId>
            <artifactId>junit</artifactId>
            <version>4.12</version>
            <scope>test</scope>
        </dependency>
    </dependencies>

    <build>
        <plugins>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-compiler-plugin</artifactId>
                <version>3.2</version>
                <configuration>
                    <source>${jdkLevel}</source>
                    <target>${jdkLevel}</target>
                    <showDeprecation>true</showDeprecation>
                    <showWarnings>true</showWarnings>
                </configuration>
            </plugin>

            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-shade-plugin</artifactId>
                <version>2.4.3</version>
                <executions>
                    <execution>
                        <phase>package</phase>
                        <goals>
                            <goal>shade</goal>
                        </goals>
                        <configuration>
                            <transformers>
                                <transformer implementation="org.apache.maven.plugins.shade.resource.ManifestResourceTransformer">
                                    <mainClass>com.qzj.demo.App</mainClass>
                                </transformer>
                            </transformers>
                            <filters>
                                <filter>
                                    <artifact>*:*</artifact>
                                    <excludes>
                                        <exclude>META-INF/*.SF</exclude>
                                        <exclude>META-INF/*.DSA</exclude>
                                        <exclude>META-INF/*.RSA</exclude>
                                    </excludes>
                                </filter>
                            </filters>
                        </configuration>
                    </execution>
                </executions>
            </plugin>
        </plugins>
    </build>
</project>
```
## 编写WordCount程序
```java
package com.qzj.demo;

import org.apache.hadoop.fs.FileSystem;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.Mapper;
import org.apache.hadoop.mapreduce.Reducer;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;
import org.apache.hadoop.util.GenericOptionsParser;
import org.apache.hadoop.conf.Configuration;

import java.io.IOException;
import java.net.URI;
import java.util.StringTokenizer;

/**
 * Hello world!
 */
public class WordCount {
    public static class Map extends Mapper<Object, Text, Text, IntWritable> {
        private static IntWritable one = new IntWritable(1);
        private Text word = new Text();

        public void map(Object key, Text value, Context context) throws IOException, InterruptedException {
            StringTokenizer st = new StringTokenizer(value.toString());
            while (st.hasMoreTokens()) {
                word.set(st.nextToken());
                context.write(word, one);
            }
        }
    }

    public static class Reduce extends Reducer<Text, IntWritable, Text, IntWritable> {
        private static IntWritable result = new IntWritable();

        public void reduce(Text key, Iterable<IntWritable> values, Context context) throws IOException, InterruptedException {
            int sum = 0;
            for (IntWritable val : values) {
                sum += val.get();
            }
            result.set(sum);
            context.write(key, result);
        }
    }

    public static void main(String[] args) throws Exception {
        System.setProperty("HADOOP_USER_NAME", "root");
        System.setProperty("hadoop.home.dir", "D:\\Program Files\\hadoop-2.7.5");
        Configuration conf = new Configuration();
//        FileSystem fs = FileSystem.get(conf);
        conf.set("fs.defaultFS", "hdfs://10.8.1.189:9000");
        FileSystem fs = FileSystem.get(new URI("hdfs://10.8.1.189:9000"), conf);
        String[] otherArgs = new GenericOptionsParser(conf, args).getRemainingArgs();
        if (otherArgs.length != 2) {
            System.err.println("Usage WordCount <int> <out>");
            System.exit(2);
        }
        Path outPath = new Path(otherArgs[1]);
        if (fs.exists(outPath)) {
            fs.delete(outPath, true);
        }
        Job job = new Job(conf, "word count");
        job.setJarByClass(WordCount.class);
        job.setMapperClass(Map.class);
        job.setCombinerClass(Reduce.class);
        job.setReducerClass(Reduce.class);
        job.setOutputKeyClass(Text.class);
        job.setOutputValueClass(IntWritable.class);
        FileInputFormat.addInputPath(job, new Path(otherArgs[0]));
        FileOutputFormat.setOutputPath(job, new Path(otherArgs[1]));
        System.exit(job.waitForCompletion(true) ? 0 : 1);
    }
}
```

## 配置Edit Configurations
在Edit Configurations中新增一个Application，在program arguments中输入以下参数：
"/user/qzj/input" "/user/qzj/output"

## 运行程序
点击运行程序

