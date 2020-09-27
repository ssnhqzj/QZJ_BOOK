# Kubernetes 部署 Eureka Server

## 1、创建 Eureka 的 Kubernetes 部署文件
创建 Eureka 部署文件，用于在 Kubernetes 中部署 Eureka，这里选择用 StatefulSet （有状态集）方式来部署，这样能保证它 Eureka Pod 名是有序的，如果部署为 Deployment，那么得部署三个 Deployment 对象，比较繁琐。并且 StatefulSet 支持 Service Headless 方式创建 Service 来对内部服务访问，如果是 CluserIP 方式创建 Service 会分一个虚拟 IP 给该 Service，那么服务通过 Service 访问 Pod 每次都需要经过 Kube-proxy 代理流量，这样会增加与注册中心的通信造成一定性能损耗。Headless 方式部署的 Service 不会分配虚拟 IP，而是用轮询的访问，每次都直接与 Pod 的 IP 进行通信。

> eureka.yaml
```
apiVersion: v1
kind: Service
metadata:
  name: eureka
  labels:
    app: eureka
spec:
  clusterIP: None
  ports:
    - name: server
      port: 8080
      targetPort: 8080
    - name: management
      port: 8081
  selector:
    app: eureka
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: eureka
  labels:
    app: eureka
spec:
  serviceName: eureka
  replicas: 3
  podManagementPolicy: Parallel     #Pod启停顺序管理
  selector:
    matchLabels:
      app: eureka
  template:
    metadata:
      labels:
        app: eureka
    spec:
      terminationGracePeriodSeconds: 10    #当删除Pod时，等待时间
      containers:
        - name: eureka
          image: mydlqclub/eureka-server:2.1.2
          ports:
            - name: server
              containerPort: 8080
            - name: management
              containerPort: 8081
          env:
            - name: APP_NAME
              value: "eureka"
            - name: POD_NAME
              valueFrom:
                fieldRef:
                  fieldPath: metadata.name
            - name: APP_OPTS
              value: "
                     --spring.application.name=${APP_NAME}
                     --eureka.instance.hostname=${POD_NAME}.${APP_NAME}
                     --registerWithEureka=true
                     --fetchRegistry=true
                     --eureka.instance.preferIpAddress=false
                     --eureka.client.serviceUrl.defaultZone=http://eureka-0.${APP_NAME}:8080/eureka/,http://eureka-1.${APP_NAME}:8080/eureka/,http://eureka-2.${APP_NAME}:8080/eureka/
                     "
          resources:
            limits:
              cpu: 2000m
              memory: 1024Mi
            requests:
              cpu: 2000m
              memory: 1024Mi
          readinessProbe:              #就绪探针
            initialDelaySeconds: 20    #延迟加载时间
            periodSeconds: 5           #重试时间间隔
            timeoutSeconds: 10         #超时时间设置
            failureThreshold: 5        #探测失败的重试次数
            httpGet:
              path: /actuator/health
              port: 8081
          livenessProbe:               #存活探针
            initialDelaySeconds: 60    #延迟加载时间
            periodSeconds: 5           #重试时间间隔
            timeoutSeconds: 5          #超时时间设置
            failureThreshold: 3        #探测失败的重试次数
            httpGet:
              path: /actuator/health
              port: 8081
```

### env 参数说明：

>APP_NAME： 和服务名称一致，将服务名称传入容器环境中。
POD_NAME： Pod名称，将 Pod 名称传入容器环境中。
APP_OPTS： Dockerfile 中定义的变量，用于设置 Spring 启动参数，这里主要设置此值与 APP_NAME 和 POD_NAME 两值配合使用。

### 其它参数说明：
>resources： 对 Pod 使用计算资源的限制，最好两个值设置成一致，Kubernetes 中会对 Pod 设置 QoS 等级，跟这两个值的设置挂钩，limits 与 request 值一致时 Qos 等级最高，当资源不足时候 QoS 等级低的最先被杀死，等级高的一般不会受太大影响。
readinessProbe： 就绪探针，Pod 启动时只有就绪探针探测成功后才对外提供访问，用它可用避免 Pod 启动而内部程序没有启动的情况下就允许外部流量流入这种情况。
livenessProbe： 存活探针，定期检测 Docker 内部程序是否存活。
spec.podManagementPolicy： pod的启动顺序策略
OrderedReady： 顺序启停 Pod，默认设置。
Parallel： 并行启停 Pod，而不遵循一个 Pod 启动后再启动另一个这种规则。

## 2、部署 Eureka 到 Kubernetes
-n：创建应用到指定的 Namespace 中。
```
$ kubectl apply -f eureka.yaml -n mydlqcloud
```

## 创建 Kubernetes 集群外部访问的 NodePort Service
创建一个类型为 NodePort 类型的 Service，供 Kubernetes 集群外部访问 Eureka UI 界面，方便观察服务注册情况。

### 1、创建 Service 部署文件
```
apiVersion: v1
kind: Service
metadata:
  name: eureka-nodeport
  labels:
    app: eureka-nodeport
spec:
  type: NodePort
  ports:
  - name: server
    port: 8080
    targetPort: 8080
    nodePort: 31011
  selector:
    app: eureka
```

### 2、创建 Service
-n：创建应用到指定的 Namespace 中。
```
$ kubectl apply -f eureka.yaml -n mydlqcloud
```

### 3、访问 Eureka UI
本人的 Kubernetes 集群 IP 地址为 192.168.2.11，且上面设置 NodePort 端口为 31001，所以这里访问 http://192.168.2.11:31001 地址，查看 Eureka UI 界面。