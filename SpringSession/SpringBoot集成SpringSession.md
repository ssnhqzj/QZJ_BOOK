1. 引入redis及springsession依赖
```
<dependency>
    <groupId>redis.clients</groupId>
    <artifactId>jedis</artifactId>
</dependency>

<dependency>
    <groupId>org.springframework.session</groupId>
    <artifactId>spring-session-data-redis</artifactId>
</dependency>

<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-data-redis</artifactId>
</dependency>
```

2. application.yml配置文件中加入一下配置：
```
spring:
  application:
    name: consumer-feign

  session:
      store-type: redis
      redis:
        flush-mode: immediate
        namespace: spring:session

  redis:
  # 单机redis配置
  #    host: localhost
  #    password:
  #    port: 6379
  
  #    集群redis配置
    cluster:
      nodes: 192.168.204.130:7000,192.168.204.130:7001,192.168.204.130:7002
      max-redirects: 3
    jedis:
      pool:
        max-active: 50
        max-idle: 8
```

3. Application上加上@EnableRedisHttpSession注解
```
@SpringBootApplication
@EnableRedisHttpSession
@EnableEurekaClient
@EnableDiscoveryClient
@EnableFeignClients
public class ConsumerFeignApplication {

    public static void main(String[] args) {
        SpringApplication.run(ConsumerFeignApplication.class, args);
    }
}
```

4. 测试
```
@RestController
public class HiController {

    @GetMapping(value = "/setsession")
    public String setSession(HttpServletRequest request) {
        request.getSession().setAttribute("name","qzj");
        return "session: name=qzj已设置";
    }

    @GetMapping(value = "/getsession")
    public String getSession(HttpServletRequest request) {
        return "获取session: name="+request.getSession().getAttribute("name");
    }

}
```