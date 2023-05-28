# LDAP
1. Установить FreeIPA;

2. Написать Ansible playbook для конфигурации клиента;

3*. Настроить аутентификацию по SSH-ключам;

4**. Firewall должен быть включен на сервере и на клиенте.

Решение: прилагается Vagrantfile и .yml. 

Разворачивается сервер и клиент, происходит настройка клиента. По окончании, можно зайти на клиент или сервер, завести пользователя, зайти под ним:
```
[root@vps13419 ldap]# vagrant ssh ldapclient
Last login: Sat Jan  9 18:39:03 2021 from 10.0.2.2
[vagrant@ldapclient ~]$ hostname
ldapclient.test.local
[vagrant@ldapclient ~]$ kinit admin
Password for admin@TEST.LOCAL: 
[vagrant@ldapclient ~]$ ipa user-add happy --first=First --last=Last --password
Password: 
Enter Password again to verify: 
------------------
Added user "happy"
------------------
  User login: happy
  First name: First
  Last name: Last
  Full name: First Last
  Display name: First Last
  Initials: FL
  Home directory: /home/happy
  GECOS: First Last
  Login shell: /bin/sh
  Principal name: happy@TEST.LOCAL
  Principal alias: happy@TEST.LOCAL
  User password expiration: 20210109184214Z
  Email address: happy@test.local
  UID: 1359200001
  GID: 1359200001
  Password: True
  Member of groups: ipausers
  Kerberos keys available: True
[vagrant@ldapclient ~]$ su -l happy
Password: 
Password expired. Change your password now.
Current Password: 
New password: 
Retype new password: 
Creating home directory for happy.
-sh-4.2$ 
```
