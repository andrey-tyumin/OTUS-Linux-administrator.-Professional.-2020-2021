# OSPF
- Поднять три виртуалки
- Объединить их разными vlan
1. Поднять OSPF между машинами на базе Quagga
2. Изобразить ассиметричный роутинг
3. Сделать один из линков "дорогим", но что бы при этом роутинг был симметричным

Формат сдачи:
Vagrantfile + ansible 

Схема стенда: 


![alt text](https://github.com/imustgetout/21th-homework-OSPF/blob/main/frr.png)

### 1. Поднять OSPF между машинами на базе Quagga
Прилагается Vagrantfile для создания виртуалок и playbook.yml для провижина.

### 2. Изобразить ассиметричный роутинг
Начальные конфиги OSPF:
```
r2# show ip ospf interface
eth1 is up
  ifindex 3, MTU 1500 bytes, BW 1000 Mbit <UP,BROADCAST,RUNNING,MULTICAST>
  Internet Address 10.0.0.2/24, Broadcast 10.0.0.255, Area 0.0.0.0
  MTU mismatch detection: disabled
  Router ID 10.20.0.1, Network Type POINTOPOINT, Cost: 100
  Transmit Delay is 1 sec, State Point-To-Point, Priority 1
  No backup designated router on this network
  Multicast group memberships: OSPFAllRouters
  Timer intervals configured, Hello 5s, Dead 10s, Wait 10s, Retransmit 5
    Hello due in 1.794s
  Neighbor Count is 1, Adjacent neighbor count is 1
eth2 is up
  ifindex 4, MTU 1500 bytes, BW 1000 Mbit <UP,BROADCAST,RUNNING,MULTICAST>
  Internet Address 10.20.0.1/24, Broadcast 10.20.0.255, Area 0.0.0.0
  MTU mismatch detection: disabled
  Router ID 10.20.0.1, Network Type POINTOPOINT, Cost: 100
  Transmit Delay is 1 sec, State Point-To-Point, Priority 1
  No backup designated router on this network
  Multicast group memberships: OSPFAllRouters
  Timer intervals configured, Hello 5s, Dead 10s, Wait 10s, Retransmit 5
    Hello due in 1.795s
  Neighbor Count is 1, Adjacent neighbor count is 1

  r3# show ip ospf interface
eth1 is up
  ifindex 3, MTU 1500 bytes, BW 1000 Mbit <UP,BROADCAST,RUNNING,MULTICAST>
  Internet Address 10.20.0.2/24, Broadcast 10.20.0.255, Area 0.0.0.0
  MTU mismatch detection: disabled
  Router ID 10.20.0.2, Network Type POINTOPOINT, Cost: 100
  Transmit Delay is 1 sec, State Point-To-Point, Priority 1
  No backup designated router on this network
  Multicast group memberships: OSPFAllRouters
  Timer intervals configured, Hello 5s, Dead 10s, Wait 10s, Retransmit 5
    Hello due in 4.061s
  Neighbor Count is 1, Adjacent neighbor count is 1
eth2 is up
  ifindex 4, MTU 1500 bytes, BW 1000 Mbit <UP,BROADCAST,RUNNING,MULTICAST>
  Internet Address 10.10.0.2/24, Broadcast 10.10.0.255, Area 0.0.0.0
  MTU mismatch detection: disabled
  Router ID 10.20.0.2, Network Type POINTOPOINT, Cost: 100
  Transmit Delay is 1 sec, State Point-To-Point, Priority 1
  No backup designated router on this network
  Multicast group memberships: OSPFAllRouters
  Timer intervals configured, Hello 5s, Dead 10s, Wait 10s, Retransmit 5
    Hello due in 4.061s
  Neighbor Count is 1, Adjacent neighbor count is 1

  r1# show ip ospf interface
eth1 is up
  ifindex 3, MTU 1500 bytes, BW 1000 Mbit <UP,BROADCAST,RUNNING,MULTICAST>
  Internet Address 10.0.0.1/24, Broadcast 10.0.0.255, Area 0.0.0.0
  MTU mismatch detection: disabled
  Router ID 10.10.0.1, Network Type POINTOPOINT, Cost: 100
  Transmit Delay is 1 sec, State Point-To-Point, Priority 1
  No backup designated router on this network
  Multicast group memberships: OSPFAllRouters
  Timer intervals configured, Hello 5s, Dead 10s, Wait 10s, Retransmit 5
    Hello due in 3.636s
  Neighbor Count is 1, Adjacent neighbor count is 1
eth2 is up
  ifindex 4, MTU 1500 bytes, BW 1000 Mbit <UP,BROADCAST,RUNNING,MULTICAST>
  Internet Address 10.10.0.1/24, Broadcast 10.10.0.255, Area 0.0.0.0
  MTU mismatch detection: disabled
  Router ID 10.10.0.1, Network Type POINTOPOINT, Cost: 100
  Transmit Delay is 1 sec, State Point-To-Point, Priority 1
  No backup designated router on this network
  Multicast group memberships: OSPFAllRouters
  Timer intervals configured, Hello 5s, Dead 10s, Wait 10s, Retransmit 5
    Hello due in 3.636s
  Neighbor Count is 1, Adjacent neighbor count is 1
  ```
  
  На роутере r1 для линка eth2 меняем стоимость в файле /etc/frr/ospfd.conf ставим 300: ip ospf cost 300, 
  
  На роутере r3 для линка eth2 меняем стоимость в файле /etc/frr/ospfd.conf ставим 300: ip ospf cost 300, 
  
  На обоих перезагружаем frr: systemctl restart frr
  
   С r3 пингуем адрес 10.0.0.1(r1 eth1):
   ```
  [root@r3 vagrant]# ping 10.0.0.1
PING 10.0.0.1 (10.0.0.1) 56(84) bytes of data.
64 bytes from 10.0.0.1: icmp_seq=1 ttl=63 time=10.5 ms
64 bytes from 10.0.0.1: icmp_seq=2 ttl=63 time=10.4 ms
64 bytes from 10.0.0.1: icmp_seq=3 ttl=63 time=6.75 ms
64 bytes from 10.0.0.1: icmp_seq=4 ttl=63 time=6.96 ms
64 bytes from 10.0.0.1: icmp_seq=5 ttl=63 time=9.41 ms
64 bytes from 10.0.0.1: icmp_seq=6 ttl=63 time=7.77 ms
64 bytes from 10.0.0.1: icmp_seq=7 ttl=63 time=7.59 ms
64 bytes from 10.0.0.1: icmp_seq=8 ttl=63 time=11.8 ms
64 bytes from 10.0.0.1: icmp_seq=9 ttl=63 time=12.8 ms
64 bytes from 10.0.0.1: icmp_seq=10 ttl=63 time=8.72 ms
64 bytes from 10.0.0.1: icmp_seq=11 ttl=63 time=11.2 ms
64 bytes from 10.0.0.1: icmp_seq=12 ttl=63 time=4.79 ms
64 bytes from 10.0.0.1: icmp_seq=13 ttl=63 time=13.2 ms
64 bytes from 10.0.0.1: icmp_seq=14 ttl=63 time=7.23 ms
64 bytes from 10.0.0.1: icmp_seq=15 ttl=63 time=5.96 ms
64 bytes from 10.0.0.1: icmp_seq=16 ttl=63 time=8.42 ms
64 bytes from 10.0.0.1: icmp_seq=17 ttl=63 time=6.54 ms
64 bytes from 10.0.0.1: icmp_seq=18 ttl=63 time=6.63 ms
64 bytes from 10.0.0.1: icmp_seq=19 ttl=63 time=6.43 ms
64 bytes from 10.0.0.1: icmp_seq=20 ttl=63 time=6.24 ms
64 bytes from 10.0.0.1: icmp_seq=21 ttl=63 time=8.41 ms
```
 Ловим трафик на eth2 роутера r2:
  tcpdump -nvvv -ieth2 icmp
  ```
  [root@r2 vagrant]# tcpdump -nvvv -ieth1 icmp
dropped privs to tcpdump
tcpdump: listening on eth1, link-type EN10MB (Ethernet), capture size 262144 bytes
09:18:28.471063 IP (tos 0x0, ttl 63, id 3529, offset 0, flags [DF], proto ICMP (1), length 84)
    10.20.0.2 > 10.0.0.1: ICMP echo request, id 29889, seq 1, length 64
09:18:28.476084 IP (tos 0x0, ttl 64, id 2670, offset 0, flags [none], proto ICMP (1), length 84)
    10.0.0.1 > 10.20.0.2: ICMP echo reply, id 29889, seq 1, length 64
09:18:29.477580 IP (tos 0x0, ttl 63, id 3633, offset 0, flags [DF], proto ICMP (1), length 84)
    10.20.0.2 > 10.0.0.1: ICMP echo request, id 29889, seq 2, length 64
09:18:29.482868 IP (tos 0x0, ttl 64, id 3615, offset 0, flags [none], proto ICMP (1), length 84)
    10.0.0.1 > 10.20.0.2: ICMP echo reply, id 29889, seq 2, length 64
09:18:30.477864 IP (tos 0x0, ttl 63, id 4420, offset 0, flags [DF], proto ICMP (1), length 84)
    10.20.0.2 > 10.0.0.1: ICMP echo request, id 29889, seq 3, length 64
09:18:30.483215 IP (tos 0x0, ttl 64, id 4482, offset 0, flags [none], proto ICMP (1), length 84)
    10.0.0.1 > 10.20.0.2: ICMP echo reply, id 29889, seq 3, length 64
09:18:31.478766 IP (tos 0x0, ttl 63, id 4906, offset 0, flags [DF], proto ICMP (1), length 84)
    10.20.0.2 > 10.0.0.1: ICMP echo request, id 29889, seq 4, length 64
09:18:31.482646 IP (tos 0x0, ttl 64, id 5371, offset 0, flags [none], proto ICMP (1), length 84)
    10.0.0.1 > 10.20.0.2: ICMP echo reply, id 29889, seq 4, length 64
09:18:32.481044 IP (tos 0x0, ttl 63, id 5175, offset 0, flags [DF], proto ICMP (1), length 84)
    10.20.0.2 > 10.0.0.1: ICMP echo request, id 29889, seq 5, length 64
09:18:32.487963 IP (tos 0x0, ttl 64, id 6175, offset 0, flags [none], proto ICMP (1), length 84)
    10.0.0.1 > 10.20.0.2: ICMP echo reply, id 29889, seq 5, length 64
```
    
###  3. Сделать один из линков "дорогим", но что бы при этом роутинг был симметричным

На роутерах r1 и r3 ставим в /etc/frr/ospfd.conf для интерфейсов eth2 стоимость 95

С r3 пускаем пинг на r1:
```
[root@r3 vagrant]# ping 10.0.0.1
PING 10.0.0.1 (10.0.0.1) 56(84) bytes of data.
64 bytes from 10.0.0.1: icmp_seq=1 ttl=64 time=4.89 ms
64 bytes from 10.0.0.1: icmp_seq=2 ttl=64 time=8.02 ms
64 bytes from 10.0.0.1: icmp_seq=3 ttl=64 time=2.65 ms
64 bytes from 10.0.0.1: icmp_seq=4 ttl=64 time=2.58 ms
64 bytes from 10.0.0.1: icmp_seq=5 ttl=64 time=3.07 ms
64 bytes from 10.0.0.1: icmp_seq=6 ttl=64 time=2.93 ms
64 bytes from 10.0.0.1: icmp_seq=7 ttl=64 time=5.18 ms
64 bytes from 10.0.0.1: icmp_seq=8 ttl=64 time=2.51 ms
64 bytes from 10.0.0.1: icmp_seq=9 ttl=64 time=4.87 ms
64 bytes from 10.0.0.1: icmp_seq=10 ttl=64 time=2.65 ms
64 bytes from 10.0.0.1: icmp_seq=11 ttl=64 time=2.23 ms
64 bytes from 10.0.0.1: icmp_seq=12 ttl=64 time=2.31 ms
64 bytes from 10.0.0.1: icmp_seq=13 ttl=64 time=2.23 ms
64 bytes from 10.0.0.1: icmp_seq=14 ttl=64 time=3.40 ms
64 bytes from 10.0.0.1: icmp_seq=15 ttl=64 time=2.19 ms
64 bytes from 10.0.0.1: icmp_seq=16 ttl=64 time=5.94 ms
```
Ловим его на r1:
```
[root@r1 vagrant]# tcpdump -nvvv -ieth2 icmp
dropped privs to tcpdump
tcpdump: listening on eth2, link-type EN10MB (Ethernet), capture size 262144 bytes
11:06:19.421632 IP (tos 0x0, ttl 64, id 4933, offset 0, flags [DF], proto ICMP (1), length 84)
    10.10.0.2 > 10.0.0.1: ICMP echo request, id 31149, seq 109, length 64
11:06:19.421707 IP (tos 0x0, ttl 64, id 36319, offset 0, flags [none], proto ICMP (1), length 84)
    10.0.0.1 > 10.10.0.2: ICMP echo reply, id 31149, seq 109, length 64
11:06:20.422518 IP (tos 0x0, ttl 64, id 5164, offset 0, flags [DF], proto ICMP (1), length 84)
    10.10.0.2 > 10.0.0.1: ICMP echo request, id 31149, seq 110, length 64
11:06:20.422577 IP (tos 0x0, ttl 64, id 36411, offset 0, flags [none], proto ICMP (1), length 84)
    10.0.0.1 > 10.10.0.2: ICMP echo reply, id 31149, seq 110, length 64
11:06:21.424894 IP (tos 0x0, ttl 64, id 5451, offset 0, flags [DF], proto ICMP (1), length 84)
    10.10.0.2 > 10.0.0.1: ICMP echo request, id 31149, seq 111, length 64
11:06:21.424946 IP (tos 0x0, ttl 64, id 36559, offset 0, flags [none], proto ICMP (1), length 84)
    10.0.0.1 > 10.10.0.2: ICMP echo reply, id 31149, seq 111, length 64
```
