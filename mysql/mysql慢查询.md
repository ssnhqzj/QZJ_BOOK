# 1. 慢查询开启
##  查看慢查询是否开启
```sql
show VARIABLES like 'slow_query_log';
``` 

```sql
-- 查看慢查询相关变量
show VARIABLES like '%log%';
``` 
## 设置慢查询日志文件保存路径
```sql
set global show_query_log_file='/home/mysql/sql_log/mysql-slow.log';
```

## 设置查询未使用索引日志记录开启
```sql
set global log_queries_not_using_indexs=on;
```

## 设置记录慢查询日志时间
```sql
-- 查询时间超过1s会记录在慢查询日志中
set global long_queries_time=1;
```

# 开启慢查询日志
```sql
set GLOBAL slow_query_log=on;
```
