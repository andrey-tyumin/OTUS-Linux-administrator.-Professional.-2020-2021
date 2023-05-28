### развернуть стенд с веб приложениями в vagrant
Варианты стенда
nginx + php-fpm (laravel/wordpress) + python (flask/django) + js(react/angular)
nginx + java (tomcat/jetty/netty) + go + ruby
можно свои комбинации

Реализации на выбор
- на хостовой системе через конфиги в /etc
- деплой через docker-compose

Для усложнения можно попросить проекты у коллег с курсов по разработке

К сдаче примается
vagrant стэнд с проброшенными на локалхост портами
каждый порт на свой сайт
через нжинкс

### Решение:

После 
```
vagrant up
```
стенд готов к проверке.

Порты веб приложений прокинуты с гостя на хост на порты 9002, 9003, 9004.

На порту 9002 golang бинарник.

На порту 9003 Python/Flask скрипт.

На порту 9004 NodeJS скрипт.
```
TASK [Add SELinux perm] ********************************************************
changed: [web]

RUNNING HANDLER [restart nginx] ************************************************
changed: [web]

PLAY RECAP *********************************************************************
web                        : ok=21   changed=20   unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

[root@vps13419 web]# curl http://127.0.0.1:9002
Hello otus! 
[root@vps13419 web]# curl http://127.0.0.1:9003
<h1 style='color:blue'>Hello otus! It's Python\Flask server!</h1> 
[root@vps13419 web]# curl http://127.0.0.1:9004
<!DOCTYPE html>
<html>
    <head>
        <title>Hello Otus!</title>
    </head>
    <body>
       <h1>Hello Otus! It's NodeJS server</h1>
    </body>
</html>
[root@vps13419 web]# 
```
