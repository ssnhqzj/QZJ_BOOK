# base
spring.rabbitmq.host: 服务Host
spring.rabbitmq.port: 服务端口
spring.rabbitmq.username: 登陆用户名
spring.rabbitmq.password: 登陆密码
spring.rabbitmq.virtual-host: 连接到rabbitMQ的vhost
spring.rabbitmq.addresses: 指定client连接到的server的地址，多个以逗号分隔(优先取addresses，然后再取host)
spring.rabbitmq.requested-heartbeat: 指定心跳超时，单位秒，0为不指定；默认60s
spring.rabbitmq.publisher-confirms: 是否启用【发布确认】
spring.rabbitmq.publisher-returns: 是否启用【发布返回】
spring.rabbitmq.connection-timeout: 连接超时，单位毫秒，0表示无穷大，不超时
spring.rabbitmq.parsed-addresses:


# ssl
spring.rabbitmq.ssl.enabled: 是否支持ssl
spring.rabbitmq.ssl.key-store: 指定持有SSL certificate的key store的路径
spring.rabbitmq.ssl.key-store-password: 指定访问key store的密码
spring.rabbitmq.ssl.trust-store: 指定持有SSL certificates的Trust store
spring.rabbitmq.ssl.trust-store-password: 指定访问trust store的密码
spring.rabbitmq.ssl.algorithm: ssl使用的算法，例如，TLSv1.1


# cache
spring.rabbitmq.cache.channel.size: 缓存中保持的channel数量
spring.rabbitmq.cache.channel.checkout-timeout: 当缓存数量被设置时，从缓存中获取一个channel的超时时间，单位毫秒；如果为0，则总是创建一个新channel
spring.rabbitmq.cache.connection.size: 缓存的连接数，只有是CONNECTION模式时生效
spring.rabbitmq.cache.connection.mode: 连接工厂缓存模式：CHANNEL 和 CONNECTION


# listener
spring.rabbitmq.listener.simple.auto-startup: 是否启动时自动启动容器
spring.rabbitmq.listener.simple.acknowledge-mode: 表示消息确认方式，其有三种配置方式，分别是none、manual和auto；默认auto
spring.rabbitmq.listener.simple.concurrency: 最小的消费者数量
spring.rabbitmq.listener.simple.max-concurrency: 最大的消费者数量
spring.rabbitmq.listener.simple.prefetch: 指定一个请求能处理多少个消息，如果有事务的话，必须大于等于transaction数量.
spring.rabbitmq.listener.simple.transaction-size: 指定一个事务处理的消息数量，最好是小于等于prefetch的数量.
spring.rabbitmq.listener.simple.default-requeue-rejected: 决定被拒绝的消息是否重新入队；默认是true（与参数acknowledge-mode有关系）
spring.rabbitmq.listener.simple.idle-event-interval: 多少长时间发布空闲容器时间，单位毫秒

spring.rabbitmq.listener.simple.retry.enabled: 监听重试是否可用
spring.rabbitmq.listener.simple.retry.max-attempts: 最大重试次数
spring.rabbitmq.listener.simple.retry.initial-interval: 第一次和第二次尝试发布或传递消息之间的间隔
spring.rabbitmq.listener.simple.retry.multiplier: 应用于上一重试间隔的乘数
spring.rabbitmq.listener.simple.retry.max-interval: 最大重试时间间隔
spring.rabbitmq.listener.simple.retry.stateless: 重试是有状态or无状态


# template
spring.rabbitmq.template.mandatory: 启用强制信息；默认false
spring.rabbitmq.template.receive-timeout: receive() 操作的超时时间
spring.rabbitmq.template.reply-timeout: sendAndReceive() 操作的超时时间
spring.rabbitmq.template.retry.enabled: 发送重试是否可用 
spring.rabbitmq.template.retry.max-attempts: 最大重试次数
spring.rabbitmq.template.retry.initial-interval: 第一次和第二次尝试发布或传递消息之间的间隔
spring.rabbitmq.template.retry.multiplier: 应用于上一重试间隔的乘数
spring.rabbitmq.template.retry.max-interval: 最大重试时间间隔