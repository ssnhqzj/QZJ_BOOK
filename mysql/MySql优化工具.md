数据库层面



检查问题常用的 12 个工具：

MySQL

mysqladmin：MySQL 客户端，可进行管理操作

mysqlshow：功能强大的查看 shell 命令

SHOW [SESSION | GLOBAL] variables：查看数据库参数信息

SHOW [SESSION | GLOBAL] STATUS：查看数据库的状态信息

information_schema：获取元数据的方法

SHOW ENGINE INNODB STATUS：Innodb 引擎的所有状态

SHOW PROCESSLIST：查看当前所有连接的 session 状态

explain：获取查询语句的执行计划

show index：查看表的索引信息

slow-log：记录慢查询语句

mysqldumpslow：分析 slowlog 文件的工具



不常用但好用的 7 个工具：

Zabbix：监控主机、系统、数据库（部署 Zabbix 监控平台）

pt-query-digest：分析慢日志

MySQL slap：分析慢日志

sysbench：压力测试工具

MySQL profiling：统计数据库整体状态工具    

Performance Schema：MySQL 性能状态统计的数据

workbench：管理、备份、监控、分析、优化工具（比较费资源）