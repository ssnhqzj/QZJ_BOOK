当编写WHERE语句中有LIKE条件时，如果参数中需要匹配 % 和_ 等特殊字符时，必须进行处理，否则系统会将其当成通配符处理。
 
## SqlServer：
有两种方案
一：将参数中的 [ 替换成 [[]，  % 替换成 [%]， _ 替换成 [_]；（推荐用这种方案处理）
二：先将参数中的 \ 替换成 \\， [替换成\[ ， % 替换成 \%， _ 替换成 \_；
然后在每个需要like查询的字段后加上escape '\'。 
注：sqlserver2005测试通过
 
## Oracle只能既改参数，又改SQL语句。
先将参数中的 \ 替换成 \\，  % 替换成 \%， _ 替换成 \_；
然后在每个需要like查询的字段后加上escape   chr(92   USING   NCHAR_CS)，组成的SQL语句形如：
select * from A where name like '%\%%' escape chr(92 USING NCHAR_CS) or addr like '%\_%' escape chr(92 USING NCHAR_CS);
在ORACLE 9I中必须写escape chr(92 USING NCHAR_CS)这么长一段，ORACLE 10G中可以简写成escape '\' 
注：oracle9i、10g测试通过
 
## Mysql
与ORACLE类似，也需要用escape语句。但是经测试不能用escape '\'，所以用escape '/' 
先将参数中 / 替换成 //，% 替换成 /%，_ 替换成 /_，\ 替换成 /\；
然后在每个需要like查询的字段后加上escape '/'。 
注：Mysql 5.5测试通过
 
Access不能用escape，但与SQLSERVER类似，只需将参数中的 [ 替换成 [[]，  % 替换成 [%]， _ 替换成 [_]即可。 
注：Access2003测试通过