## 官方定义 Spring Cloud Stream 是一个构建消息驱动微服务的框架。
　　应用程序通过 inputs 或者 outputs 来与 Spring Cloud Stream中binder交互，通过我们配置来 binding ，而 Spring Cloud Stream 的 binder
负责与消息中间件交互。所以，我们只需要搞清楚如何与 Spring Cloud Stream交互就可以方便使用消息驱动的方式。 通过使用Spring
Integration来连接消息代理中间件以实现消息事件驱动。Spring Cloud Stream为一些供应商的消息中间件产品提供了个性化的自动化配置实现，引用了发布-订阅、消费组、分区的三个核心概念。目前仅支持RabbitMQ、Kafka。
这里还要讲解一下什么是Spring Integration ？ Integration 集成企业应用集成（EAI）是集成应用之间数据和服务的一种应用技术。  

四种集成风格：

　　1.文件传输：两个系统生成文件，文件的有效负载就是由另一个系统处理的消息。该类风格的例子之一是针对文件轮询目录或FTP目录，并处理该文件。

　　2.共享数据库：两个系统查询同一个数据库以获取要传递的数据。一个例子是你部署了两个EAR应用，它们的实体类（JPA、Hibernate等）共用同一个表。

　　3.远程过程调用：两个系统都暴露另一个能调用的服务。该类例子有EJB服务，或SOAP和REST服务。

　　4.消息：两个系统连接到一个公用的消息系统，互相交换数据，并利用消息调用行为。该风格的例子就是众所周知的中心辐射式的（hub-and-spoke）JMS架构。

## 为什么需要SpringCloud Stream消息驱动呢？

比方说我们用到了RabbitMQ和Kafka，由于这两个消息中间件的架构上的不同，像RabbitMQ有exchange，kafka有Topic，partitions分区，这些中间件的差异性导致我们实际项目开发给我们造成了一定的困扰，我们如果用了两个消息队列的其中一种，

后面的业务需求，我想往另外一种消息队列进行迁移，这时候无疑就是一个灾难性的，一大堆东西都要重新推倒重新做，因为它跟我们的系统耦合了，这时候springcloud Stream给我们提供了一种解耦合的方式。

Spring Cloud Stream由一个中间件中立的核组成。应用通过Spring Cloud Stream插入的input(相当于消费者consumer，它是从队列中接收消息的)和output(相当于生产者producer，它是从队列中发送消息的。)通道与外界交流。

通道通过指定中间件的Binder实现与外部代理连接。业务开发者不再关注具体消息中间件，只需关注Binder对应用程序提供的抽象概念来使用消息中间件实现业务即可。

## Binder

通过定义绑定器作为中间层，实现了应用程序与消息中间件(Middleware)细节之间的隔离。通过向应用程序暴露统一的Channel通过，使得应用程序不需要再考虑各种不同的消息中间件的实现。当需要升级消息中间件，或者是更换其他消息中间件产品时，我们需要做的就是更换对应的Binder绑定器而不需要修改任何应用逻辑 。甚至可以任意的改变中间件的类型而不需要修改一行代码。目前只提供了RabbitMQ和Kafka的Binder实现。

 

Springcloud Stream还有个好处就是像Kafka一样引入了一点分区的概念，像RabbitMQ不支持分区的队列，你用了SpringCloud Stream技术，它就会帮RabbitMQ引入了分区的特性，SpringCloud Stream就是天然支持分区的，我们用起来还是很方便的。后面会详细讲解

 

接下来进行一个Demo进行演练。

首先我们要在先前的工程中新建三个子模块，分别是springcloud-stream，springcloud-stream1，springcloud-stream2  这三个模块，其中springcloud-stream作为生产者进行发消息模块，springcloud-stream1，springcloud-stream2作为消息接收模块。


分别在springcloud-stream，springcloud-stream1，springcloud-stream2  这三个模块引入如下依赖：

```
<dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-stream-binder-kafka</artifactId>
            <version>1.3.0.RELEASE</version>
        </dependency>

　　　　<dependency>
   　　　　<groupId>org.springframework.boot</groupId>
   　　　　<artifactId>spring-boot-starter-web</artifactId>
　　　　</dependency>
```

接着进行application.yml进行配置如下：

```
server:
  port: 7888
spring:
  application:
    name: producer
  cloud:
    stream:
      kafka:
        binder:
#Kafka的消息中间件服务器
          brokers: localhost:9092
#Zookeeper的节点，如果集群，后面加,号分隔
          zk-nodes: localhost:2181
#如果设置为false,就不会自动创建Topic 有可能你Topic还没创建就直接调用了。
          auto-create-topics: true
      bindings:
#这里用stream给我们提供的默认output，后面会讲到自定义output
        output:
#消息发往的目的地        
            destination: stream-demo
#消息发送的格式，接收端不用指定格式，但是发送端要            
            content-type: text/plain
```

接下来进行第一个springcloud-stream模块的代码编写，在该模块下定义一个SendService，如下：

```
package hjc.producer;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.cloud.stream.annotation.EnableBinding;
import org.springframework.cloud.stream.messaging.Source;
import org.springframework.messaging.support.MessageBuilder;

/**
 * Created by cong on 2018/5/28.
 */
//这个注解给我们绑定消息通道的，Source是Stream给我们提供的，可以点进去看源码，可以看到output和input,这和配置文件中的output，input对应的。
@EnableBinding(Source.class)

public class SendService {

    @Autowired
    private Source source;


    public void sendMsg(String msg){
        source.output().send(MessageBuilder.withPayload(msg).build());
    }

}
```

springcloud-stream 的controller层代码如下：

```
package hjc.producer;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * Created by cong 2018/5/28
 */
@RestController
public class ProducerController {


    @Autowired
    private SendService sendService;


    @RequestMapping("/send/{msg}")
    public void send(@PathVariable("msg") String msg){
        sendService.sendMsg(msg);
    }
}

```

接下来进行springcloud-stream1，springcloud-stream2两个模块的代码编写

首先需要引入的依赖，上面已经提到。

接着进行springcloud-stream1和springcloud-stream2模块application.yml的配置，如下：

springcloud-stream1配置如下：

```
server:
  port: 7889
spring:
  application:
    name: consumer_1
  cloud:
    stream:
      kafka:
        binder:
          brokers: localhost:9092
          zk-nodes: localhost:2181
          auto-create-topics: true
      bindings:
#input是接收，注意这里不能再像前面一样写output了
          input:
            destination: stream-demo

```

springcloud-stream2模块application.yml的配置如下：

```
server:
  port: 7890
spring:
  application:
    name: consumer_2
  cloud:
    stream:
      kafka:
        binder:
          brokers: localhost:9092
          zk-nodes: localhost:2181
          auto-create-topics: true
      bindings:
          input:
            destination: stream-demo
```

好了接下来进行springcloud-stream1模块和springcloud-stream2模块的消息接受代码的编写，springcloud-stream1模块和springcloud-stream2模块的消息接受代码都是一样的，如下：

```
//消息接受端，stream给我们提供了Sink,Sink源码里面是绑定input的，要跟我们配置文件的imput关联的。
@EnableBinding(Sink.class)
public class RecieveService {

    @StreamListener(Sink.INPUT)
    public void recieve(Object payload){
        System.out.println(payload);
    }

}
```

好了接着我们首先要启动上一篇随笔所提到的zookeeper，和Kafka，如下：

接着分别现后启动启动springcloud-stream，springcloud-stream1，springcloud-stream2,模块运行结果如下：

首先进行springcloud-stream模块的访问，如下：
可以看到这两消息模块都接收到了消息并且打印了出来。

 

 

好了到现在为止，我们进行了一个简单的消息发送和接收，用的是Stream给我们提供的默认Source，Sink，接下来我们要自己进行自定义，这种方式在工作中还是用的比较多的，因为我们要往不同的消息通道发消息，

必然不能全都叫input,output的，那样的话就乱套了，因此首先自定义一个接口，如下：


from： https://www.cnblogs.com/huangjuncong/p/9102843.html