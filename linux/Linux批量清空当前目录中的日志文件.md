在Linux中，有时需要批量清空当前目录中的日志文件，同时还要保留日志文件。

其实一行shell命令就可以搞定，一起来看看吧。

在当前目录下，键入如下命令：

```
for i in `find . -name "*.log"`; do cat /dev/null >$i; done

for i in `find . -name "*.log"`;do >$i; done

for i in `find . -name "*.log" -o -name "*.out" -o -name "*.sql"`;do >$i; done
```

再把shell命令解释一下：
```

find . -name "*.log"  ，就是在当前目录下查找后缀为log的文件。

cat /dev/null >$i       ，就是将每次找到的log文件清空。
```