FROM java:8
VOLUME /logs

# 拷贝filebeat安装包到/usr/app目录并解压
ADD filebeat-6.2.3-linux-x86_64.tar.gz /usr/app/

# 拷贝配置文件
COPY filebeat_temp.yml /usr/app/filebeat-6.2.3-linux-x86_64/

RUN cd /usr/app/filebeat-6.2.3-linux-x86_64 \
    # 移除默认的filebeat.yml
    && rm filebeat.yml \
    # 将拷贝进来的filebeat_temp.yml重命名为filebeat.yml
    && mv filebeat_temp.yml filebeat.yml

ENTRYPOINT ["./usr/app/filebeat-6.2.3-linux-x86_64/filebeat","-e","-c","/usr/app/filebeat-6.2.3-linux-x86_64/filebeat.yml"]