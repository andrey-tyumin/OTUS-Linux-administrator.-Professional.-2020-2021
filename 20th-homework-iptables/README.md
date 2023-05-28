### Сценарии iptables
#### Задание
1) реализовать knocking port
- centralRouter может попасть на ssh inetrRouter через knock скрипт
пример в материалах
2) добавить inetRouter2, который виден(маршрутизируется (host-only тип сети для виртуалки)) с хоста или форвардится порт через локалхост
3) запустить nginx на centralServer
4) пробросить 80й порт на inetRouter2 8080
5) дефолт в инет оставить через inetRouter

* реализовать проход на 80й порт без маскарадинга 


![alt text](https://github.com/imustgetout/20th-homework-iptables/blob/main/iptables.png)

### Решение:
Прилагается Vagrantfile и файлы для provision.
После 
```
vagrant up
```
стенд готов к проверке.
Доступ по ssh с CentralRouter к inetRouter через запуск ssh_to_inetRouter.sh
```
    centralServer: Complete!
    centralServer: Created symlink from /etc/systemd/system/multi-user.target.wants/nginx.service to /usr/lib/systemd/system/nginx.service.
[root@vps13419 iptables]# curl -I 172.28.128.3:8080
HTTP/1.1 200 OK
Server: nginx/1.16.1
Date: Mon, 11 Jan 2021 19:07:54 GMT
Content-Type: text/html
Content-Length: 4833
Last-Modified: Fri, 16 May 2014 15:12:48 GMT
Connection: keep-alive
ETag: "53762af0-12e1"
Accept-Ranges: bytes

[root@vps13419 iptables]# vagrant ssh centralRouter
[vagrant@centralRouter ~]$ ./ssh_to_inetRouter.sh 

Starting Nmap 6.40 ( http://nmap.org ) at 2021-01-11 19:10 UTC
Warning: 192.168.255.1 giving up on port because retransmission cap hit (0).
Nmap scan report for 192.168.255.1
Host is up (0.0030s latency).
PORT     STATE    SERVICE
8881/tcp filtered unknown
MAC Address: 08:00:27:58:75:9A (Cadmus Computer Systems)

Nmap done: 1 IP address (1 host up) scanned in 0.41 seconds

Starting Nmap 6.40 ( http://nmap.org ) at 2021-01-11 19:10 UTC
Warning: 192.168.255.1 giving up on port because retransmission cap hit (0).
Nmap scan report for 192.168.255.1
Host is up (0.0026s latency).
PORT     STATE    SERVICE
7777/tcp filtered cbt
MAC Address: 08:00:27:58:75:9A (Cadmus Computer Systems)

Nmap done: 1 IP address (1 host up) scanned in 0.40 seconds

Starting Nmap 6.40 ( http://nmap.org ) at 2021-01-11 19:10 UTC
Warning: 192.168.255.1 giving up on port because retransmission cap hit (0).
Nmap scan report for 192.168.255.1
Host is up (0.0032s latency).
PORT     STATE    SERVICE
9991/tcp filtered issa
MAC Address: 08:00:27:58:75:9A (Cadmus Computer Systems)

Nmap done: 1 IP address (1 host up) scanned in 0.42 seconds
The authenticity of host '192.168.255.1 (192.168.255.1)' can't be established.
ECDSA key fingerprint is SHA256:nHA/HQODFVwhIDet5SKX4aA++A9tLGdoxHTaPSqvVO8.
ECDSA key fingerprint is MD5:da:ad:7e:ee:53:b5:ae:e9:5a:cb:16:ce:53:61:da:4d.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added '192.168.255.1' (ECDSA) to the list of known hosts.
vagrant@192.168.255.1's password: 
[vagrant@inetRouter ~]$ 
```
