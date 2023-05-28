### 1. Запустить nginx на нестандартном порту 3-мя разными способами:
##### - переключатели setsebool;
##### - добавление нестандартного порта в имеющийся тип;
##### - формирование и установка модуля SELinux.
***
Реализация:

На всякий случай ставим пакеты для работы с selinux:

    [root@otus ~]# yum install setools-console
    [root@otus ~]# yum install policycoreutils-python
    [root@otus ~]# yum install setroubleshoot-server

***
##### 1 вариант решения - Добавление нестандартного порта в имеющийся тип:

Ставим nginx:

    [root@otus ~]# yum install nginx
Запускаем

    [root@otus ~]# systemctl start nginx

Проверяем:

    [root@otus ~]# systemctl status |grep nginx
           │     └─5803 grep --color=auto nginx
             ├─nginx.service
             │ ├─5437 nginx: master process /usr/sbin/ngin
             │ ├─5438 nginx: worker proces
             │ └─5439 nginx: worker proces


    [root@otus ~]# netstat -nlp |grep nginx
    tcp        0      0 0.0.0.0:80              0.0.0.0:*               LISTEN      5437/nginx: master
    tcp6       0      0 :::80                   :::*                    LISTEN      5437/nginx: master

Останавливаем:

    [root@otus ~]# systemctl stop nginx

Редактируем /etc/nginx/nginx.conf:

Меняем listen       80 default_server;

На     listen       5080 default_server;

Стартуем:

    [root@otus ~]# systemctl start nginx
    Job for nginx.service failed because the control process exited with error code. See "systemctl status nginx.service" and "journalctl -xe" for details.

Смотрим /var/log/audit/audit.log:

    cat /var/log/audit/audit.log
    type=AVC msg=audit(1601837639.651:464282): avc:  denied  { name_bind } for  pid=7974 comm="nginx" src=5080 scontext=system_u:system_r:httpd_t:s0     tcontext=system_u:object_r:unreserved_port_t:s0 tclass=tcp_socket permissive=0
    type=SYSCALL msg=audit(1601837639.651:464282): arch=c000003e syscall=49 success=no exit=-13 a0=6 a1=5560d248c6b0 a2=10 a3=7ffd84cb3220 items=0 ppid=1 pid=7974 auid=4294967295 uid=0 gid=0 euid=0 suid=0 fsuid=0 egid=0 sgid=0 fsgid=0 tty=(none) ses=4294967295 comm="nginx" exe="/usr/sbin/nginx" subj=system_u:system_r:httpd_t:s0 key=(null)
    type=PROCTITLE msg=audit(1601837639.651:464282): proctitle=2F7573722F7362696E2F6E67696E78002D74
    type=SERVICE_START msg=audit(1601837639.659:464283): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=system_u:system_r:init_t:s0 msg='unit=nginx comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=failed'

Смотрим какие порты прописаны в контексте httpd:

    [root@otus ~]# semanage port -l | grep http
    http_cache_port_t              tcp      8080, 8118, 8123, 10001-10010
    http_cache_port_t              udp      3130
    http_port_t                    tcp      80, 81, 443, 488, 8008, 8009, 8443, 9000
    pegasus_http_port_t            tcp      5988
    pegasus_https_port_t           tcp      5989

Само решение:

    [root@otus ~]# semanage port -a -t http_port_t -p tcp 5080

Запустим nginx и

Проверяем:

    [root@otus ~]# netstat -nlpt |grep nginx
    tcp        0      0 0.0.0.0:5080            0.0.0.0:*               LISTEN      8114/nginx: master
    tcp6       0      0 :::80                   :::*                    LISTEN      8114/nginx: master

nginx запустился на порту 5080

Проверим правило:

    [root@otus ~]# semanage port -l | grep http
    http_cache_port_t              tcp      8080, 8118, 8123, 10001-10010
    http_cache_port_t              udp      3130
    http_port_t                    tcp      5080, 80, 81, 443, 488, 8008, 8009, 8443, 9000
    pegasus_http_port_t            tcp      5988
    pegasus_https_port_t           tcp      5989
Порт 5080 добавлен в правило

    [root@otus ~]# seinfo --portcon=5080
	portcon tcp 5080 system_u:object_r:http_port_t:s0
	portcon tcp 1024-32767 system_u:object_r:unreserved_port_t:s0
	portcon udp 1024-32767 system_u:object_r:unreserved_port_t:s0
	portcon sctp 1024-65535 system_u:object_r:unreserved_port_t:s0
  
 Возвращаем все обратно:
 
    [root@otus ~]# systemctl stop nginx

    [root@otus ~]# semanage port -d -t http_port_t -p tcp 5080

***

##### 2 вариант решения - Создание модуля политики:

Стартуем, получаем ту же ошибку.

Смотрим журнал аудита:

    [root@otus ~]# sealert -a /var/log/audit/audit.log
    100% done
    found 1 alerts in /var/log/audit/audit.log
    --------------------------------------------------------------------------------
    
    SELinux запрещает /usr/sbin/nginx доступ name_bind к tcp_socket port 5080.
    
    Модуль bind_ports предлагает (точность 92.2)  *************************
 
 часть вывода обрезано.
 
 Создадим модуль политики:

    [root@otus ~]# ausearch -c 'nginx' --raw | audit2allow -M my-nginx
    IMPORTANT 
    To make this policy package active, execute:
    
    semodule -i my-nginx.pp

Установим:

    [root@otus ~]# semodule -i my-nginx.pp
    [root@otus ~]# semodule -l |grep my-nginx
    my-nginx	1.0
    
Проверим:
    
    [root@otus ~]# systemctl start nginx
    [root@otus ~]# netstat -lntp |grep nginx
    tcp        0      0 0.0.0.0:5080            0.0.0.0:*               LISTEN      9554/nginx: master
    tcp6       0      0 :::80                   :::*                    LISTEN      9554/nginx: master
 
 nginx запустился на порту 5080
***

##### 3 вариант решения - Параметризованные политики(getsebool/setsebool)

Третий вариант делал на другой виртуалке, т.л. проинсталированная политика не удалялась(конфиг такой же).

Стартуем, получаем ту же самую ошибку.

Решение:

    [root@centos-s-2vcpu-4gb-fra1-01 ~]# setsebool -P nis_enabled 1
    
Проверяем:

    [root@centos-s-2vcpu-4gb-fra1-01 ~]# systemctl start nginx
    [root@centos-s-2vcpu-4gb-fra1-01 ~]# systemctl status nginx
    [root@centos-s-2vcpu-4gb-fra1-01 ~]# netstat -nltp |grep nginx
    tcp        0      0 0.0.0.0:5080            0.0.0.0:*               LISTEN      147515/nginx: maste
    tcp6       0      0 :::80                   :::*                    LISTEN      147515/nginx: maste

nginx запустился на порту 5080

***

### 2. Обеспечить работоспособность приложения при включенном selinux.

Сначала на клиенте попробуем обновить А запись на сервере, чтобы в логе появилась ошибка.

На сервере выполняем:

    [root@ns01 vagrant]# sealert -a /var/log/audit/audit.log
    100% done
    found 1 alerts in /var/log/audit/audit.log
    --------------------------------------------------------------------------------
    
    SELinux is preventing /usr/sbin/named from create access on the file named.ddns.lab.view1.jnl.

    *****  Plugin catchall_labels (83.8 confidence) suggests   *******************
    
    If you want to allow named to have create access on the named.ddns.lab.view1.jnl file
    Then you need to change the label on named.ddns.lab.view1.jnl
    Do
    # semanage fcontext -a -t FILE_TYPE 'named.ddns.lab.view1.jnl'
    where FILE_TYPE is one of the following: dnssec_trigger_var_run_t, ipa_var_lib_t, krb5_host_rcache_t, krb5_keytab_t, named_cache_t, named_log_t, named_tmp_t, named_var_run_t, named_zone_t.
    Then execute:
    restorecon -v 'named.ddns.lab.view1.jnl'
    
    
    *****  Plugin catchall (17.1 confidence) suggests   **************************
    
    If you believe that named should be allowed create access on the named.ddns.lab.view1.jnl file by default.
    Then you should report this as a bug.
    You can generate a local policy module to allow this access.
    Do
    allow this access for now by executing:
    # ausearch -c 'isc-worker0000' --raw | audit2allow -M my-iscworker0000
    # semodule -i my-iscworker0000.pp
    
    
    Additional Information:
    Source Context                system_u:system_r:named_t:s0
    Target Context                system_u:object_r:etc_t:s0
    Target Objects                named.ddns.lab.view1.jnl [ file ]
    Source                        isc-worker0000
    Source Path                   /usr/sbin/named
    Port                          <Unknown>
    Host                          <Unknown>
    Source RPM Packages           bind-9.11.4-16.P2.el7_8.6.x86_64
    Target RPM Packages           
    Policy RPM                    selinux-policy-3.13.1-266.el7.noarch
    Selinux Enabled               True
    Policy Type                   targeted
    Enforcing Mode                Enforcing
    Host Name                     ns01
    Platform                      Linux ns01 3.10.0-1127.el7.x86_64 #1 SMP Tue Mar
                                  31 23:36:51 UTC 2020 x86_64 x86_64
    Alert Count                   1
    First Seen                    2020-10-06 11:13:27 UTC
    Last Seen                     2020-10-06 11:13:27 UTC
    Local ID                      c972b6d7-31d3-4f75-9d69-1f1d3dc99f80
    
    Raw Audit Messages
    type=AVC msg=audit(1601982807.989:1835): avc:  denied  { create } for  pid=4877 comm="isc-worker0000" name="named.ddns.lab.view1.jnl" scontext=system_u:system_r:named_t:s0 tcontext=system_u:object_r:etc_t:s0 tclass=file permissive=0
    
    
    type=SYSCALL msg=audit(1601982807.989:1835): arch=x86_64 syscall=open success=no exit=EACCES a0=7f5b5936a050 a1=241 a2=1b6 a3=24 items=0 ppid=1 pid=4877 auid=4294967295 uid=25 gid=25 euid=25 suid=25 fsuid=25 egid=25 sgid=25 fsgid=25 tty=(none) ses=4294967295 comm=isc-worker0000 exe=/usr/sbin/named subj=system_u:system_r:named_t:s0 key=(null)
    
    Hash: isc-worker0000,named_t,etc_t,file,create

Судя по логам named не имеет прав для создания файла журнала зоны в /etc/named/dynamic

    [root@ns01 vagrant]# ls -alZ /etc/named/dynamic
    drw-rwx---. root  named unconfined_u:object_r:etc_t:s0   .
    drw-rwx---. root  named system_u:object_r:etc_t:s0       ..
    -rw-rw----. named named system_u:object_r:etc_t:s0       named.ddns.lab
    -rw-rw----. named named system_u:object_r:etc_t:s0       named.ddns.lab.view1
 
    [root@ns01 vagrant]# ls -alZ /etc/named/
    drw-rwx---. root named system_u:object_r:etc_t:s0       .
    drwxr-xr-x. root root  system_u:object_r:etc_t:s0       ..
    drw-rwx---. root named unconfined_u:object_r:etc_t:s0   dynamic
    -rw-rw----. root named system_u:object_r:etc_t:s0       named.50.168.192.rev
    -rw-rw----. root named system_u:object_r:etc_t:s0       named.dns.lab
    -rw-rw----. root named system_u:object_r:etc_t:s0       named.dns.lab.view1
    -rw-rw----. root named system_u:object_r:etc_t:s0       named.newdns.lab

Добавим прав:

    [root@ns01 vagrant]# semanage fcontext -a -t named_log_t "/etc/named/dynamic(/.*)?"

    [root@ns01 vagrant]# restorecon -v "/etc/named/dynamic"
    restorecon reset /etc/named/dynamic context unconfined_u:object_r:etc_t:s0->unconfined_u:object_r:named_log_t:s0
    
Проверим:

    [root@ns01 vagrant]# ls -alZ /etc/named/
    drw-rwx---. root named system_u:object_r:etc_t:s0       .
    drwxr-xr-x. root root  system_u:object_r:etc_t:s0       ..
    drw-rwx---. root named unconfined_u:object_r:named_log_t:s0 dynamic
    -rw-rw----. root named system_u:object_r:etc_t:s0       named.50.168.192.rev
    -rw-rw----. root named system_u:object_r:etc_t:s0       named.dns.lab
    -rw-rw----. root named system_u:object_r:etc_t:s0       named.dns.lab.view1
    -rw-rw----. root named system_u:object_r:etc_t:s0       named.newdns.lab

    [root@ns01 vagrant]# ls -alZ /etc/named/dynamic
    drw-rwx---. root  named unconfined_u:object_r:named_log_t:s0 .
    drw-rwx---. root  named system_u:object_r:etc_t:s0       ..
    -rw-rw----. named named system_u:object_r:etc_t:s0       named.ddns.lab
    -rw-rw----. named named system_u:object_r:etc_t:s0       named.ddns.lab.view1

На клиенте попробуем обновить А запись на сервере.

Потом смотрим:

    [root@ns01 vagrant]# ls -alZ /etc/named/dynamic
    drw-rwx---. root  named unconfined_u:object_r:named_log_t:s0 .
    drw-rwx---. root  named system_u:object_r:etc_t:s0       ..
    -rw-rw----. named named system_u:object_r:etc_t:s0       named.ddns.lab
    -rw-rw----. named named system_u:object_r:etc_t:s0       named.ddns.lab.view1
    -rw-r--r--. named named system_u:object_r:named_log_t:s0 named.ddns.lab.view1.jnl

Файл журнала создан

Вывод на клиенте до и после:

    [andrey@localhost selinux_dns_problems]$ vagrant ssh client
    Last login: Tue Oct  6 11:05:21 2020 from 10.0.2.2
    ###############################
    ### Welcome to the DNS lab! ###
    ###############################
    
    - Use this client to test the enviroment
    - with dig or nslookup. Ex:
    dig @192.168.50.10 ns01.dns.lab
    
    - nsupdate is available in the ddns.lab zone. Ex:
    nsupdate -k /etc/named.zonetransfer.key
    server 192.168.50.10
    zone ddns.lab 
    update add www.ddns.lab. 60 A 192.168.50.15
    send
    
    - rndc is also available to manage the servers
    rndc -c ~/rndc.conf reload

    ###############################
    ### Enjoy! ####################
    ###############################

    [vagrant@client ~]$ su
    Password: 

    [root@client vagrant]# nsupdate -k /etc/named.zonetransfer.key
    > server 192.168.50.10
    > zone ddns.lab
    > update add www.ddns.lab. 60 A 192.168.50.15
    > send
    update failed: SERVFAIL
    > quit

    [root@client vagrant]# nsupdate -k /etc/named.zonetransfer.key
    > server 192.168.50.10
    > zone ddns.lab
    > update add www.ddns.lab. 60 A 192.168.50.15
    > send
    > 

### 2. Более правильный способ с исправленным стендом

Изменяем разворачиваемый стенд

Меняем 2 файла в provisioning: named.conf и playbook.yml.

named.conf

Было:

    // labs ddns zone
    zone "ddns.lab" {
        type master;
        allow-transfer { key "zonetransfer.key"; };
        allow-update { key "zonetransfer.key"; };
        file "/etc/named/dynamic/named.ddns.lab.view1";

	Секция view "default"
    // labs ddns zone
    zone "ddns.lab" {
        type master;
        allow-transfer { key "zonetransfer.key"; };
        allow-update { key "zonetransfer.key"; };
        file "/etc/named/dynamic/named.ddns.lab";

Стало:

    // labs ddns zone
    zone "ddns.lab" {
        type master;
        allow-transfer { key "zonetransfer.key"; };
        allow-update { key "zonetransfer.key"; };
        file "/var/named/dynamic/named.ddns.lab.view1";

    Секция view "default"
    // labs ddns zone
    zone "ddns.lab" {
        type master;
        allow-transfer { key "zonetransfer.key"; };
        allow-update { key "zonetransfer.key"; };
        file "/var/named/dynamic/named.ddns.lab";
	
Весь текст не показываю, остальные секции не менялись

playbook.yml:

Было:

    - name: copy dynamic zone ddns.lab
      copy:
      src: files/ns01/named.ddns.lab
      dest: /etc/named/dynamic/
      owner: named
      group: named
      mode: 0660

    - name: copy dynamic zone ddns.lab.view1
      copy:
      src: files/ns01/named.ddns.lab.view1
      dest: /etc/named/dynamic/
      owner: named
      group: named
      mode: 0660

    - name: set /etc/named/dynamic permissions
      file:
      path: /etc/named/dynamic
      owner: root
      group: named
      mode: 0670
      
  Стало:
  
    - name: copy dynamic zone ddns.lab
      copy:
      src: files/ns01/named.ddns.lab
      dest: /var/named/dynamic/
      owner: named
      group: named
      mode: 0660

    - name: copy dynamic zone ddns.lab.view1
      copy:
      src: files/ns01/named.ddns.lab.view1
      dest: /var/named/dynamic/
      owner: named
      group: named
      mode: 0660

    - name: set /var/named/dynamic permissions
      file:
      path: /var/named/dynamic
      owner: root
      group: named
      mode: 0670
      
  В named.conf переопределяем где будут лежать файлы зоны (/var/named/dynamic - туда есть право записи для named_log_t),
  
  В playbook.yml копируем уже в измененный каталог(+ права доступа на новый каталог)  
