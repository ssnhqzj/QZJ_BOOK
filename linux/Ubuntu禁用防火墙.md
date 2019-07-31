### 1、关闭ubuntu的防火墙
```bash
ufw disable
```

## 2. 开启防火墙

```bash
ufw enable
```

### 3. 卸载了iptables

```
apt-get remove iptables
```

### 4.关闭ubuntu中的防火墙的其余命令

```bash
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT
iptables -F
```

