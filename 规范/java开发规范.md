# java开发规范
## 1.数据库
- 表名及字段名统一使用小写字母+下划线，例如：sys_user
- id类型使用bigint
- 日期时间字段使用date、time、datetime，不推荐使用timestamp和bigint
- java中的bool类型统一使用varchar存储，推荐使用yes/no
- java中的枚举类型统一使用varchar存储，且使用语义明确的单词，不推荐使用例如：1/2/3来表示
- 字段可为空的需插入默认值

## 2.JAVA命名
### 2.1字段命名
驼峰

### 2.2通用方法命名
应该尽量使用通用的动词命名方法，例如：
新增
推荐：insert add
避免：save

删除
推荐：delete
避免：remove

修改
推荐：update
避免：setXxx modify

查单个
推荐：getById getOne
避免：select query find

列表查询：list

分页查询：page

提交：submit

审核：audit

配置：config
> 所有命名拒绝使用语义不明的单词或简写，拒绝使用自造词

## 3.是否需要使用Dto/Vo/Bo/Po
controller调用service，service调用dao，需要封装参数吗？需要封装返回值吗？
尽量还是不用Dto/Vo/Bo， 直接实体类即可。
如果，如果实体类满足不了业务需要，应当进行封装，统一使用：
- Controller请求：XXXRequest
- Controller返回：XXXResponse
- Service层：XXXDto

## 4.基本遵循RESTful风格
- 查询: [GET] /admin/user
- 新增：[POST] /admin/user
- 更新：[PUT] /admin/user
- 删除：[DELETE] /admin/user

示例：
- 查询用户信息列表：[GET] /users
- 查看某个用户信息:[GET] /users/{id} 
- 新建用户信息:[POST] /users 
- 更新用户信息:[PUT] /users/{id}
- 删除用户信息:[DELETE] /users/{id}

状态码：
- 200~299 表示操作成功
- 300~399 表示参数方面的异常
- 400~499 表示请求地址方面的异常：
- 500~599 服务器代码异常

## 5.数据权限
- 涉及到数据权限的表需要冗余机构id和用户id，固定字段名称为dept_id和user_id
- 在xml的查询语句末尾加入${params.dataScope}数据