Kubernetes的官方文档中并没有对apiVersion的详细解释，而且因为K8S本身版本也在快速迭代，有些资源在低版本还在beta阶段，到了高版本就变成了stable。

如Deployment:

```
1.6版本之前 apiVsersion：extensions/v1beta1

1.6版本到1.9版本之间：apps/v1beta1

1.9版本之后:apps/v1
```

一.各种apiVersion的含义

#### alpha

* 该软件可能包含错误。启用一个功能可能会导致bug
* 随时可能会丢弃对该功能的支持，恕不另行通知

#### beta

* 软件经过很好的测试。启用功能被认为是安全的。
* 默认情况下功能是开启的
* 细节可能会改变，但功能在后续版本不会被删除

#### stable

* 该版本名称命名方式：vX这里X是一个整数
* 稳定版本、放心使用
* 将出现在后续发布的软件版本中

#### v1

* Kubernetes API的稳定版本，包含很多核心对象：pod、service等

#### apps/v1beta2

* 在kubernetes1.8版本中，新增加了apps/v1beta2的概念，apps/v1beta1同理
* DaemonSet，Deployment，ReplicaSet 和 StatefulSet的当时版本迁入apps/v1beta2，兼容原有的extensions/v1beta1

#### apps/v1

* 在kubernetes1.9版本中，引入apps/v1，deployment等资源从extensions/v1beta1, apps/v1beta1 和 apps/v1beta2迁入apps/v1，原来的v1beta1等被废弃。

* apps/v1代表：包含一些通用的应用层的api组合，如：Deployments, RollingUpdates, and ReplicaSets

#### batch/v1

* 代表job相关的api组合

* 在kubernetes1.8版本中，新增了batch/v1beta1，后CronJob 已经迁移到了 batch/v1beta1，然后再迁入batch/v1

#### autoscaling/v1

* 代表自动扩缩容的api组合，kubernetes1.8版本中引入。
* 这个组合中后续的alpha 和 beta版本将支持基于memory使用量、其他监控指标进行扩缩容

#### extensions/v1beta1

* deployment等资源在1.6版本时放在这个版本中，后迁入到apps/v1beta2,再到apps/v1中统一管理

#### certificates.k8s.io/v1beta1

* 安全认证相关的api组合

#### authentication.k8s.io/v1

* 资源鉴权相关的api组合

## 二.查看当前可用的API版本
```
执行 kubectl api-versions
```

### kubernetes 1.8
```
apiextensions.k8s.io/v1beta1
apiregistration.k8s.io/v1beta1
apps/v1beta1
apps/v1beta2
authentication.k8s.io/v1
authentication.k8s.io/v1beta1
authorization.k8s.io/v1
authorization.k8s.io/v1beta1
autoscaling/v1
autoscaling/v2beta1
batch/v1
batch/v1beta1
certificates.k8s.io/v1beta1
extensions/v1beta1
networking.k8s.io/v1
policy/v1beta1
rbac.authorization.k8s.io/v1
rbac.authorization.k8s.io/v1beta1
settings.k8s.io/v1alpha1
storage.k8s.io/v1
storage.k8s.io/v1beta1
v1
```

### kubernetes 1.11
```
admissionregistration.k8s.io/v1alpha1
admissionregistration.k8s.io/v1beta1
apiextensions.k8s.io/v1beta1
apiregistration.k8s.io/v1
apiregistration.k8s.io/v1beta1
apps/v1
apps/v1beta1
apps/v1beta2
authentication.k8s.io/v1
authentication.k8s.io/v1beta1
authorization.k8s.io/v1
authorization.k8s.io/v1beta1
autoscaling/v1
autoscaling/v2beta1
batch/v1
batch/v1beta1
certificates.k8s.io/v1beta1
events.k8s.io/v1beta1
extensions/v1beta1
networking.k8s.io/v1
policy/v1beta1
rbac.authorization.k8s.io/v1
rbac.authorization.k8s.io/v1beta1
scheduling.k8s.io/v1beta1
settings.k8s.io/v1alpha1
storage.k8s.io/v1
storage.k8s.io/v1alpha1
storage.k8s.io/v1beta1
v1
```