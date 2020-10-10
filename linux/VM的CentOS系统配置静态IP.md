### 进入 /etc/sysconfig/network-scripts

### 找到对应网卡的配置文件
```
[root@empty network-scripts]# ls
ifcfg-ens33  ifdown-eth   ifdown-post    ifdown-Team      ifup-aliases  ifup-ipv6   ifup-post    ifup-Team      init.ipv6-global
ifcfg-lo     ifdown-ippp  ifdown-ppp     ifdown-TeamPort  ifup-bnep     ifup-isdn   ifup-ppp     ifup-TeamPort  network-functions
ifdown       ifdown-ipv6  ifdown-routes  ifdown-tunnel    ifup-eth      ifup-plip   ifup-routes  ifup-tunnel    network-functions-ipv6
ifdown-bnep  ifdown-isdn  ifdown-sit     ifup             ifup-ippp     ifup-plusb  ifup-sit     ifup-wireless
```
当前机器的网卡配置文件是ifcfg-ens33，因为使用的网卡名称是ens33

### 编辑网卡文件
```
vim ifcfg-ens33
```
编辑关键字段
```
TYPE="Ethernet"
PROXY_METHOD="none"
BROWSER_ONLY="no"
#改成static
BOOTPROTO="static"
DEFROUTE="yes"
IPV4_FAILURE_FATAL="no"
IPV6INIT="yes"
IPV6_AUTOCONF="yes"
IPV6_DEFROUTE="yes"
IPV6_FAILURE_FATAL="no"
IPV6_ADDR_GEN_MODE="stable-privacy"
NAME="ens33"
UUID="ed2b221a-28b3-4120-a79a-d611683fd6a2"
DEVICE="ens33"
# 改成yes
ONBOOT="yes"
# 静态ip地址
IPADDR=192.168.36.200
# 掩码
NETMASK=255.255.255.0
# 网关，虚拟机在网络配置中查看
GATEWAY=192.168.36.2
# dns
DNS1=172.16.7.1
DNS2=192.168.36.2
NM_CONTROLLEN=no
```

### 重启网络服务
```
service network restart
```