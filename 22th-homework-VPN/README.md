## VPN
1. Между двумя виртуалками поднять vpn в режимах
- tun
- tap
Прочуствовать разницу.

2. Поднять RAS на базе OpenVPN с клиентскими сертификатами, подключиться с локальной машины на виртуалку

3*. Самостоятельно изучить, поднять ocserv и подключиться с хоста к виртуалке 

### Задание 1. Между двумя виртуалками поднять vpn в режимах tun tap

#### tap

#### Клиент:

#### [vagrant@client ~]$ cat /etc/openvpn/server.conf

    dev tap

    remote 192.168.10.10

    ifconfig 10.10.10.2 255.255.255.0

    topology subnet

    route 192.168.10.0 255.255.255.0

    secret /etc/openvpn/static.key

    comp-lzo

    status /var/log/openvpn-status.log

    log /var/log/openvpn.log

    verb 3

#### [vagrant@client ~]$ syatemctl status openvpn@server

    - bash: syatemctl: command not found

#### [vagrant@client ~]$ systemctl status openvpn@server

    ● openvpn@server.service - OpenVPN Robust And Highly Flexible Tunneling Application On server

    Loaded: loaded (/usr/lib/systemd/system/openvpn@.service; disabled; vendor preset: disabled)

    Active: inactive (dead)

#### [vagrant@client ~]$ systemctl start openvpn@server

    ==== AUTHENTICATING FOR org.freedesktop.systemd1.manage-units ===

    Для управления системными службами и юнитами, необходимо пройти аутентификацию.

    Authenticating as: root

    Password:

    ==== AUTHENTICATION COMPLETE ===

#### [vagrant@client ~]$ sudo systemctl enable openvpn@server

    Created symlink from /etc/systemd/system/multi-user.target.wants/openvpn@server.service to /usr/lib/systemd/system/openvpn@.service.

#### [vagrant@client ~]$ systemctl status openvpn@server

    ● openvpn@server.service - OpenVPN Robust And Highly Flexible Tunneling Application On server

    Loaded: loaded (/usr/lib/systemd/system/openvpn@.service; enabled; vendor preset: disabled)

    Active: active (running) since Sat 2020-12-12 16:51:46 UTC; 17s ago

    Main PID: 3437 (openvpn)

    Status: "Initialization Sequence Completed"

    CGroup: /system.slice/system-openvpn.slice/openvpn@server.service

    └─3437 /usr/sbin/openvpn --cd /etc/openvpn/ --config server.conf

#### [vagrant@client ~]$ iperf3 -c 10.10.10.1 -t 40 -i 5

    Connecting to host 10.10.10.1, port 5201

    [  4] local 10.10.10.2 port 49560 connected to 10.10.10.1 port 5201

    [ ID] Interval           Transfer     Bandwidth       Retr  Cwnd

    [  4]   0.00-5.00   sec  18.5 MBytes  31.0 Mbits/sec    0    672 KBytes

    [  4]   5.00-10.00  sec  15.1 MBytes  25.4 Mbits/sec   46    806 KBytes

    [  4]  10.00-15.00  sec  13.7 MBytes  23.0 Mbits/sec    0    886 KBytes

    [  4]  15.00-20.00  sec  12.7 MBytes  21.2 Mbits/sec    0    937 KBytes

    [  4]  20.00-25.00  sec  16.8 MBytes  28.2 Mbits/sec    0   1.29 MBytes

    [  4]  25.00-30.00  sec  14.9 MBytes  25.0 Mbits/sec   54    869 KBytes

    [  4]  30.00-35.01  sec  14.9 MBytes  24.9 Mbits/sec    0   1019 KBytes

    [  4]  35.01-40.01  sec  16.1 MBytes  27.1 Mbits/sec    0   1.02 MBytes

    - - - - - - - - - - - - - - - - - - - - - - - - -

    [ ID] Interval           Transfer     Bandwidth       Retr

    [  4]   0.00-40.01  sec   123 MBytes  25.7 Mbits/sec  100             sender

    [  4]   0.00-40.01  sec   121 MBytes  25.3 Mbits/sec                  receiver

    iperf Done.

#### [vagrant@client ~]$

#### Сервер:

#### [vagrant@server ~]$ cat /etc/openvpn/server.conf

    dev tap

    ifconfig 10.10.10.1 255.255.255.0

    topology subnet

    secret /etc/openvpn/static.key

    comp-lzo

    status /var/log/openvpn-status.log

    log /var/log/openvpn.log

    verb 3

#### [vagrant@server ~]$ systemctl status openvpn@server

    ● openvpn@server.service - OpenVPN Robust And Highly Flexible Tunneling Application On server

    Loaded: loaded (/usr/lib/systemd/system/openvpn@.service; enabled; vendor preset: disabled)

    Active: active (running) since Sat 2020-12-12 16:43:05 UTC; 7min ago

    Main PID: 3387 (openvpn)

    Status: "Pre-connection initialization successful"

    CGroup: /system.slice/system-openvpn.slice/openvpn@server.service

    └─3387 /usr/sbin/openvpn --cd /etc/openvpn/ --config server.conf

#### [vagrant@server ~]$ iperf3 -s &

    [1] 3470

#### [vagrant@server ~]$ -----------------------------------------------------------

    Server listening on 5201

    \-----------------------------------------------------------

    Accepted connection from 10.10.10.2, port 49558

    [  5] local 10.10.10.1 port 5201 connected to 10.10.10.2 port 49560

    [ ID] Interval           Transfer     Bandwidth

    [  5]   0.00-1.00   sec  2.92 MBytes  24.5 Mbits/sec

    [  5]   1.00-2.00   sec  3.22 MBytes  27.0 Mbits/sec

    [  5]   2.00-3.00   sec  3.39 MBytes  28.5 Mbits/sec

    [  5]   3.00-4.00   sec  3.22 MBytes  27.0 Mbits/sec

    [  5]   4.00-5.00   sec  3.68 MBytes  30.9 Mbits/sec

    [  5]   5.00-6.00   sec  2.54 MBytes  21.3 Mbits/sec

    [  5]   6.00-7.00   sec  3.80 MBytes  31.9 Mbits/sec

    [  5]   7.00-8.00   sec  2.88 MBytes  24.1 Mbits/sec

    [  5]   8.00-9.00   sec  2.42 MBytes  20.3 Mbits/sec

    [  5]   9.00-10.00  sec  2.69 MBytes  22.6 Mbits/sec

    [  5]  10.00-11.00  sec  2.79 MBytes  23.4 Mbits/sec

    [  5]  11.00-12.00  sec  2.62 MBytes  22.0 Mbits/sec

    [  5]  12.00-13.00  sec  2.62 MBytes  22.0 Mbits/sec

    [  5]  13.00-14.00  sec  3.09 MBytes  25.9 Mbits/sec

    [  5]  14.00-15.00  sec  2.49 MBytes  20.9 Mbits/sec

    [  5]  15.00-16.00  sec  2.44 MBytes  20.5 Mbits/sec

    [  5]  16.00-17.00  sec  3.35 MBytes  28.1 Mbits/sec

    [  5]  17.00-18.00  sec  2.45 MBytes  20.6 Mbits/sec

    [  5]  18.00-19.00  sec  2.39 MBytes  20.1 Mbits/sec

    [  5]  19.00-20.00  sec  2.54 MBytes  21.3 Mbits/sec

    [  5]  20.00-21.00  sec  3.21 MBytes  26.9 Mbits/sec

    [  5]  21.00-22.00  sec  2.96 MBytes  24.8 Mbits/sec

    [  5]  22.00-23.00  sec  3.02 MBytes  25.4 Mbits/sec

    [  5]  23.00-24.00  sec  3.16 MBytes  26.5 Mbits/sec

    [  5]  24.00-25.00  sec  3.64 MBytes  30.5 Mbits/sec

    [  5]  25.00-26.00  sec  3.38 MBytes  28.4 Mbits/sec

    [  5]  26.00-27.00  sec  3.02 MBytes  25.3 Mbits/sec

    [  5]  27.00-28.00  sec  3.00 MBytes  25.2 Mbits/sec

    [  5]  28.00-29.01  sec  2.95 MBytes  24.5 Mbits/sec

    [  5]  29.01-30.00  sec  3.07 MBytes  26.0 Mbits/sec

    [  5]  30.00-31.00  sec  2.90 MBytes  24.3 Mbits/sec

    [  5]  31.00-32.00  sec  3.14 MBytes  26.3 Mbits/sec

    [  5]  32.00-33.00  sec  3.20 MBytes  26.8 Mbits/sec

    [  5]  33.00-34.00  sec  2.53 MBytes  21.2 Mbits/sec

    [  5]  34.00-35.00  sec  3.25 MBytes  27.3 Mbits/sec

    [  5]  35.00-36.00  sec  2.92 MBytes  24.5 Mbits/sec

    [  5]  36.00-37.01  sec  3.02 MBytes  25.2 Mbits/sec

    [  5]  37.01-38.00  sec  3.39 MBytes  28.6 Mbits/sec

    [  5]  38.00-39.00  sec  3.19 MBytes  26.8 Mbits/sec

    [  5]  39.00-40.00  sec  3.02 MBytes  25.3 Mbits/sec

    [  5]  40.00-40.45  sec  1.13 MBytes  21.1 Mbits/sec

    - - - - - - - - - - - - - - - - - - - - - - - - -

    [ ID] Interval           Transfer     Bandwidth

    [  5]   0.00-40.45  sec  0.00 Bytes  0.00 bits/sec                  sender

    [  5]   0.00-40.45  sec   121 MBytes  25.0 Mbits/sec                  receiver

    \-----------------------------------------------------------

    Server listening on 5201

    \-----------------------------------------------------------


#### tun

#### Клиент

#### [vagrant@client ~]$ systemctl status openvpn@server

    ● openvpn@server.service - OpenVPN Robust And Highly Flexible Tunneling Application On server

    Loaded: loaded (/usr/lib/systemd/system/openvpn@.service; enabled; vendor preset: disabled)

    Active: active (running) since Sat 2020-12-12 16:59:53 UTC; 40s ago

    Main PID: 604 (openvpn)

    Status: "Initialization Sequence Completed"

    CGroup: /system.slice/system-openvpn.slice/openvpn@server.service

    └─604 /usr/sbin/openvpn --cd /etc/openvpn/ --config server.conf

#### [vagrant@client ~]$ cat /etc/openvpn/server.conf

    dev tun

    remote 192.168.10.10

    ifconfig 10.10.10.2 255.255.255.0

    topology subnet

    route 192.168.10.0 255.255.255.0

    secret /etc/openvpn/static.key

    comp-lzo

    status /var/log/openvpn-status.log

    log /var/log/openvpn.log

    verb 3

#### [vagrant@client ~]$ iperf3 -c 10.10.10.1 -t 40 -i 5

    Connecting to host 10.10.10.1, port 5201

    [  4] local 10.10.10.2 port 47476 connected to 10.10.10.1 port 5201

    [ ID] Interval           Transfer     Bandwidth       Retr  Cwnd

    [  4]   0.00-5.00   sec  18.5 MBytes  31.0 Mbits/sec   23    488 KBytes

    [  4]   5.00-10.01  sec  17.3 MBytes  28.9 Mbits/sec    5    510 KBytes

    [  4]  10.01-15.00  sec  16.9 MBytes  28.4 Mbits/sec    0    556 KBytes

    [  4]  15.00-20.00  sec  13.7 MBytes  23.0 Mbits/sec    0    642 KBytes

    [  4]  20.00-25.01  sec  14.6 MBytes  24.4 Mbits/sec   11    646 KBytes

    [  4]  25.01-30.00  sec  14.6 MBytes  24.5 Mbits/sec    7    552 KBytes

    [  4]  30.00-35.00  sec  15.3 MBytes  25.7 Mbits/sec    0    575 KBytes

    [  4]  35.00-40.01  sec  15.1 MBytes  25.4 Mbits/sec   46    392 KBytes

    - - - - - - - - - - - - - - - - - - - - - - - - -

    [ ID] Interval           Transfer     Bandwidth       Retr

    [  4]   0.00-40.01  sec   126 MBytes  26.4 Mbits/sec   92             sender

    [  4]   0.00-40.01  sec   125 MBytes  26.1 Mbits/sec                  receiver

    iperf Done.

#### [vagrant@client ~]$

#### Сервер

#### vagrant@server ~]$ systemctl status openvpn@server

    ● openvpn@server.service - OpenVPN Robust And Highly Flexible Tunneling Application On server

    Loaded: loaded (/usr/lib/systemd/system/openvpn@.service; enabled; vendor preset: disabled)

    Active: active (running) since Sat 2020-12-12 16:59:37 UTC; 30s ago

    Main PID: 672 (openvpn)

    Status: "Initialization Sequence Completed"

    CGroup: /system.slice/system-openvpn.slice/openvpn@server.service

    └─672 /usr/sbin/openvpn --cd /etc/openvpn/ --config server.conf

#### [vagrant@server ~]$ cat /etc/openvpn/server.conf

    dev tun

    ifconfig 10.10.10.1 255.255.255.0

    topology subnet

    secret /etc/openvpn/static.key

    comp-lzo

    status /var/log/openvpn-status.log

    log /var/log/openvpn.log

    verb 3

#### [vagrant@server ~]$ iperf3 -s &

    [1] 959

#### [vagrant@server ~]$ -----------------------------------------------------------

    Server listening on 5201

    \-----------------------------------------------------------

    Accepted connection from 10.10.10.2, port 47474

    [  5] local 10.10.10.1 port 5201 connected to 10.10.10.2 port 47476

    [ ID] Interval           Transfer     Bandwidth

    [  5]   0.00-1.00   sec  2.63 MBytes  22.1 Mbits/sec

    [  5]   1.00-2.00   sec  3.42 MBytes  28.8 Mbits/sec

    [  5]   2.00-3.01   sec  4.23 MBytes  35.3 Mbits/sec

    [  5]   3.01-4.00   sec  3.60 MBytes  30.3 Mbits/sec

    [  5]   4.00-5.01   sec  2.67 MBytes  22.3 Mbits/sec

    [  5]   5.01-6.00   sec  3.75 MBytes  31.7 Mbits/sec

    [  5]   6.00-7.00   sec  3.43 MBytes  28.8 Mbits/sec

    [  5]   7.00-8.00   sec  2.97 MBytes  24.9 Mbits/sec

    [  5]   8.00-9.00   sec  3.69 MBytes  30.9 Mbits/sec

    [  5]   9.00-10.00  sec  3.57 MBytes  29.9 Mbits/sec

    [  5]  10.00-11.00  sec  3.37 MBytes  28.3 Mbits/sec

    [  5]  11.00-12.00  sec  3.51 MBytes  29.4 Mbits/sec

    [  5]  12.00-13.00  sec  2.85 MBytes  24.0 Mbits/sec

    [  5]  13.00-14.00  sec  3.49 MBytes  29.2 Mbits/sec

    [  5]  14.00-15.00  sec  3.37 MBytes  28.3 Mbits/sec

    [  5]  15.00-16.00  sec  2.89 MBytes  24.3 Mbits/sec

    [  5]  16.00-17.00  sec  2.40 MBytes  20.1 Mbits/sec

    [  5]  17.00-18.00  sec  3.11 MBytes  26.1 Mbits/sec

    [  5]  18.00-19.00  sec  2.71 MBytes  22.7 Mbits/sec

    [  5]  19.00-20.00  sec  2.60 MBytes  21.8 Mbits/sec

    [  5]  20.00-21.00  sec  3.22 MBytes  27.0 Mbits/sec

    [  5]  21.00-22.00  sec  2.85 MBytes  23.9 Mbits/sec

    [  5]  22.00-23.00  sec  2.80 MBytes  23.5 Mbits/sec

    [  5]  23.00-24.00  sec  2.96 MBytes  24.8 Mbits/sec

    [  5]  24.00-25.00  sec  3.07 MBytes  25.8 Mbits/sec

    [  5]  25.00-26.00  sec  3.29 MBytes  27.6 Mbits/sec

    [  5]  26.00-27.00  sec  2.66 MBytes  22.3 Mbits/sec

    [  5]  27.00-28.00  sec  2.73 MBytes  22.9 Mbits/sec

    [  5]  28.00-29.00  sec  2.71 MBytes  22.7 Mbits/sec

    [  5]  29.00-30.00  sec  2.74 MBytes  23.0 Mbits/sec

    [  5]  30.00-31.00  sec  3.00 MBytes  25.1 Mbits/sec

    [  5]  31.00-32.00  sec  2.52 MBytes  21.1 Mbits/sec

    [  5]  32.00-33.00  sec  3.60 MBytes  30.2 Mbits/sec

    [  5]  33.00-34.00  sec  3.17 MBytes  26.6 Mbits/sec

    [  5]  34.00-35.00  sec  3.15 MBytes  26.5 Mbits/sec

    [  5]  35.00-36.00  sec  3.01 MBytes  25.2 Mbits/sec

    [  5]  36.00-37.00  sec  2.59 MBytes  21.7 Mbits/sec

    [  5]  37.00-38.00  sec  3.46 MBytes  29.1 Mbits/sec

    [  5]  38.00-39.00  sec  3.54 MBytes  29.7 Mbits/sec

    [  5]  39.00-40.00  sec  2.70 MBytes  22.7 Mbits/sec

    [  5]  40.00-40.17  sec   488 KBytes  24.0 Mbits/sec

    - - - - - - - - - - - - - - - - - - - - - - - - -

    [ ID] Interval           Transfer     Bandwidth

    [  5]   0.00-40.17  sec  0.00 Bytes  0.00 bits/sec                  sender

    [  5]   0.00-40.17  sec   125 MBytes  26.0 Mbits/sec                  receiver

    \-----------------------------------------------------------

    Server listening on 5201

    \-----------------------------------------------------------

    Скорость передачи примерно одинакова, немного впереди tun, По повторно отправленным сегментам также tun лучше (92 против 100).

### Задание 2. openvpn RAS

Сервер поднят и настроен по инструкции в методичке. Порядок команд не вывожу. Результаты тестирования:

##### На сервере:

#### [root@localhost openvpn]# ip r

    default via 10.0.2.2 dev eth0 proto dhcp metric 100

    10.0.2.0/24 dev eth0 proto kernel scope link src 10.0.2.15 metric 100

    10.10.10.0/24 via 10.10.10.2 dev tun0

    10.10.10.2 dev tun0 proto kernel scope link src 10.10.10.1

    192.168.10.0/24 via 10.10.10.2 dev tun0

#### [root@localhost openvpn]# ip a
    
    1: lo: <LOOPBACK,UP,LOWER\_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000

    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00

    inet 127.0.0.1/8 scope host lo

    valid\_lft forever preferred\_lft forever

    inet6 ::1/128 scope host

    valid\_lft forever preferred\_lft forever

    2: eth0: <BROADCAST,MULTICAST,UP,LOWER\_UP> mtu 1500 qdisc pfifo\_fast state UP group default qlen 1000

    link/ether 52:54:00:4d:77:d3 brd ff:ff:ff:ff:ff:ff

    inet 10.0.2.15/24 brd 10.0.2.255 scope global noprefixroute dynamic eth0

    valid\_lft 83862sec preferred\_lft 83862sec

    inet6 fe80::5054:ff:fe4d:77d3/64 scope link

    valid\_lft forever preferred\_lft forever

    3: eth1: <BROADCAST,MULTICAST,UP,LOWER\_UP> mtu 1500 qdisc pfifo\_fast state UP group default qlen 1000

    link/ether 08:00:27:2d:7f:9a brd ff:ff:ff:ff:ff:ff

    inet6 fe80::4465:dd40:763a:3f2c/64 scope link noprefixroute

    valid\_lft forever preferred\_lft forever

    4: tun0: <POINTOPOINT,MULTICAST,NOARP,UP,LOWER\_UP> mtu 1500 qdisc pfifo\_fast state UNKNOWN group default qlen 100

    link/none

    inet 10.10.10.1 peer 10.10.10.2/32 scope global tun0

    valid\_lft forever preferred\_lft forever

    inet6 fe80::f531:b392:f47c:9748/64 scope link flags 800

    valid\_lft forever preferred\_lft forever

##### На клиенте:

#### [andrey@localhost vpnclient]$ openvpn --config client.conf

     Mon Dec 14 11:41:51 2020 OpenVPN 2.4.9 x86\_64-redhat-linux-gnu [SSL (OpenSSL)] [LZO] [LZ4] [EPOLL] [PKCS11] [MH/PKTINFO] [AEAD] built on Apr 24 2020

    Mon Dec 14 11:41:51 2020 library versions: OpenSSL 1.1.1c FIPS  28 May 2019, LZO 2.08

    Mon Dec 14 11:41:51 2020 WARNING: No server certificate verification method has been enabled.  See http://openvpn.net/howto.html#mitm for more info.

    Mon Dec 14 11:41:51 2020 TCP/UDP: Preserving recently used remote address: [AF\_INET]192.168.10.10:1207

    Mon Dec 14 11:41:51 2020 Socket Buffers: R=[212992->212992] S=[212992->212992]

    Mon Dec 14 11:41:51 2020 UDP link local (bound): [AF\_INET][undef]:1194

    Mon Dec 14 11:41:51 2020 UDP link remote: [AF\_INET]192.168.10.10:1207

#### [andrey@localhost vpnclient]$ ip r

    default via 192.168.253.161 dev enp2s0 proto dhcp metric 100

    192.168.10.0/24 dev vboxnet2 proto kernel scope link src 192.168.10.1

    192.168.122.0/24 dev virbr0 proto kernel scope link src 192.168.122.1 linkdown

    192.168.253.0/24 dev enp2s0 proto kernel scope link src 192.168.253.103 metric 100

#### [andrey@localhost vpnclient]$ ping -c 4 10.10.10.1

    PING 10.10.10.1 (10.10.10.1) 56(84) bytes of data.

    64 bytes from 10.10.10.1: icmp\_seq=1 ttl=61 time=1.95 ms

    64 bytes from 10.10.10.1: icmp\_seq=2 ttl=61 time=3.11 ms

    64 bytes from 10.10.10.1: icmp\_seq=3 ttl=61 time=1.80 ms

    64 bytes from 10.10.10.1: icmp\_seq=4 ttl=61 time=1.63 ms

    --- 10.10.10.1 ping statistics ---

    4 packets transmitted, 4 received, 0% packet loss, time 7ms

    rtt min/avg/max/mdev = 1.625/2.117/3.106/0.584 ms

#### [andrey@localhost vpnclient]$
