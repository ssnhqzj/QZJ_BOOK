# Camunda流程引擎表机构说明

Camunda bpm流程引擎的数据库由多个表组成，表名都以ACT开头，第二部分是说明表用途的两字符标识。

## 表名前缀说明

- ACT_RE_*: 'RE’表示流程资源存储，这个前缀的表包含了流程定义和流程静态资源（图片，规则等），共5张表。
- ACT_RU_*: 'RU’表示流程运行时。 这些运行时的表，包含流程实例，任务，变量，Job等运行中的数据。
  Camunda只在流程实例执行过程中保存这些数据，在流程结束时就会删除这些记录， 这样运行时表的数据量最小，可以最快运行。共15张表。
- ACT_ID_*: 'ID’表示组织用户信息，比如用户，组等，共6张表。
- ACT_HI_*: 'HI’表示流程历史记录。 这些表包含历史数据，比如历史流程实例，变量，任务等，共18张表。
- ACT_GE_*: ‘GE’表示流程通用数据， 用于不同场景下，共3张表。

## 数据表清单

|分类	|表名称	| 描述            |
|---------|---------|---------------|
|流程资源存储	|act_re_case_def	| CMMN案例管理模型定义表 |
|流程资源存储	|act_re_decision_def	| DMN决策模型定义表    |
|流程资源存储	|act_re_decision_req_def	| 待确定           |
|流程资源存储	|act_re_deployment	| 流程部署表         |
|流程资源存储	|act_re_procdef	| BPMN流程模型定义表   |
|流程运行时	|act_ru_authorization	| 流程运行时收取表      |
|流程运行时	|act_ru_batch	| 流程执行批处理表      |
|流程运行时	|act_ru_case_execution	| CMMN案例运行执行表   |
|流程运行时	|act_ru_case_sentry_part	| 待确定           |
|流程运行时	|act_ru_event_subscr	| 流程事件订阅表       |
|流程运行时	|act_ru_execution	| BPMN流程运行时记录表  |
|流程运行时	|act_ru_ext_task	| 流程任务消息执行表     |
|流程运行时	|act_ru_filter	| 流程定义查询配置表     |
|流程运行时	|act_ru_identitylink	| 运行时流程人员表      |
|流程运行时	|act_ru_incident	| 运行时异常事件表      |
|流程运行时	|act_ru_job	| 流程运行时作业表      |
|流程运行时	|act_ru_jobdef	| 流程作业定义表       |
|流程运行时	|act_ru_meter_log	| 流程运行时度量日志表    |
|流程运行时	|act_ru_task	| 流程运行时任务表      |
|流程运行时	|act_ru_variable	| 流程运行时变量表      |
|组织用户信息	|act_id_group	| 群组信息表         |
|组织用户信息	|act_id_info	| 用户扩展信息表       |
|组织用户信息	|act_id_membership	| 用户群组关系表       |
|组织用户信息	|act_id_tenant	| 租户信息表         |
|组织用户信息	|act_id_tenant_member	| 用户租户关系表       |
|组织用户信息	|act_id_user	| 用户信息表         |
|流程历史记录	|act_hi_actinst	|历史的活动实例表|
|流程历史记录	|act_hi_attachment	|历史的流程附件表|
|流程历史记录	|act_hi_batch	|历史的批处理记录表|
|流程历史记录	|act_hi_caseactinst	|历史的CMMN活动实例表|
|流程历史记录	|act_hi_caseinst	|历史的CMMN实例表|
|流程历史记录	|act_hi_comment	|历史的流程审批意见表|
|流程历史记录	|act_hi_dec_in	|历史的DMN变量输入表|
|流程历史记录	|act_hi_dec_out	|历史的DMN变量输出表|
|流程历史记录	|act_hi_decinst	|历史的DMN实例表|
|流程历史记录	|act_hi_detail	|历史的流程运行时变量详情记录表|
|流程历史记录	|act_hi_ext_task_log	|历史的流程任务消息执行表|
|流程历史记录	|act_hi_identitylink	|历史的流程运行过程中用户关系|
|流程历史记录	|act_hi_incident	|历史的流程异常事件记录表|
|流程历史记录	|act_hi_job_log	|历史的流程作业记录表|
|流程历史记录	|act_hi_op_log	|待确定|
|流程历史记录	|act_hi_procinst	|历史的流程实例|
|流程历史记录	|act_hi_taskinst	|历史的任务实例|
|流程历史记录	|act_hi_varinst	|历史的流程变量记录表|
|流程通用数据	|act_ge_bytearray	|流程引擎二进制数据表|
|流程通用数据	|act_ge_property	|流程引擎属性配置表|
|流程通用数据	|act_ge_schema_log	|数据库脚本执行日志表|

## 表功能详细介绍
+ ### act_ru_execution【流程运行时记录表/流程执行实例表】
ACT_RU_EXECUTION 表(很多初学者迷惑的一张表，以为是流程实例表，其实它叫执行实例表）：这个表和act_run_task表，一起控制了用户任务的产生与完成等。
这个表是工作流程的核心表，这个表会体现主干与分支流程实例的概念，所以才有了执行实例这个叫法。
一般来讲一个流程实例都有一条主线。如果流程为直线流程，那么流程实例在这个表中只有一条记录对应。
但如果流程有会签多实例时，以及并行网关时，这时候它就有流程实例和执行实例，一对多的关系，所以一定要理解流实例和执行实例的区别，
不要把它执行实例误以为流程实例表，当在并行网关和会签多实例时，它是会产生多个执行实例，刚创建时各个执行实例的IS_ACTIVE_这个字段的值都是为1，即激活状态
当每完成一个执行实例时，它会把IS_ACTIVE设为0，非激活状态，当所有执行实例完成后，它才会转移到历史，把这个多实例自动删除。
另外当有子流程，子流程的实例是处于激活状态，而主干流程的实例处于非激活状态。
>ID_：EXECUTION主键，这个主键有可能和PROC_INST_ID_相同，相同的情况表示这条记录为主实例记录。

>REV_：表示数据库表更新次数。

>PROC_INST_ID_：一个流程实例不管有多少条分支实例，这个ID都是一致的。

>BUSINESS_KEY_: 这个为业务主键，主流程才会使用业务主键，另外这个业务主键字段在表中有唯一约束。

>PARENT_ID_：这个记录表示父实例ID，如上图，同步节点会产生两条执行记录，这两条记录的父ID为主线的ID。

>PROC_DEF_ID_: 流程定义ID

>SUPER_EXEC： 这个如果存在表示这个实例记录为一个外部子流程记录，对应主流程的主键ID。

>ACT_ID_：表示流程运行到的节点，如上图主实例运行到ANDGateway1 节点。

两个子实例运行到UserTask1,UserTask2节点。

>IS_ACTIVE_ : 是否活动流程实例，比如上图，主流程为非活动实例，下面两个为活动实例，如果UserTask2完成，那么这个值将变为0即非活动。

>IS_CONCURRENT_: 是否并发。上图同步节点后为并发，如果是并发多实例也是为1。

>IS_SCOPE_: 这个字段我跟踪了一下不同的流程实例，如会签，子流程，同步等情况，发现主实例的情况这个字段为1，子实例这个字段为0。

>TENANT_ID_ :  这个字段表示租户ID。可以应对多租户的设计。

>IS_EVENT_SCOPE: 没有使用到事件的情况下，一般都为0。

>SUSPENSION_STATE_： 这个表示是否暂停。