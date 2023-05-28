### Systemd

Выполнить следующие задания и подготовить развёртывание результата выполнения с использованием Vagrant и Vagrant shell provisioner (или Ansible, на Ваше усмотрение):

1. Написать service, который будет раз в 30 секунд мониторить лог на предмет наличия ключевого слова (файл лога и ключевое слово должны задаваться в /etc/sysconfig);

2. Из репозитория epel установить spawn-fcgi и переписать init-скрипт на unit-файл (имя service должно называться так же: spawn-fcgi);

3. Дополнить unit-файл httpd (он же apache) возможностью запустить несколько инстансов сервера с разными конфигурационными файлами;

#### 1 задание. Написать service, который будет раз в 30 секунд мониторить лог на предмет наличия ключевого слова (файл лога и ключевое слово должны задаваться в /etc/sysconfig);:

Создаем необходимые файлы:

Watchlog.sh(кладем его в /opt/):

    #!/bin/bash
    WORD=$1
    LOG=$2
    DATE=`date`
    
    if grep $WORD $LOG &> /dev/null
    then
	    logger "$DATE: I found word, Master!"
    else
	    exit 0
    fi

watchlog(кладем его в /etc/sysconfig):

    #put it in /etc/sysconfig
    WORD="ALERT"
    LOG=/var/log/watchlog.log
    
watchlog.log(кладем в /var/log/)

    string1
    string2
    string3
    ALERT
    string4
    string5

watchlog.service(кладем в /etc/systemd/system/)

    [Unit]
    Description=My watchlog service
    
    [Service]
    
    Type=oneshot
    EnvironmentFile=/etc/sysconfig/watchlog
    ExecStart=/opt/watchlog.sh $WORD $LOG

watchlog.timer(кладем в /etc/systemd/system/)

    [Unit]
    Description=Run watchlog script every 30 second
    
    [Timer]
    # Run every 30 second
    OnUnitActiveSec=30
    Unit=watchlog.service
    [Install]
    WantedBy=multi-user.target

Прописываем в playbook.yml распихивание этих файлов и старт сервисов:

    - name: copy watchlog
      copy:
      src: files/test_systemd/watchlog
      dest: /etc/sysconfig/
      owner: root
      group: root
      mode: 0644

    - name: copy watchlog.log
      copy:
      src: files/test_systemd/watchlog.log
      dest: /var/log/
      owner: root
      group: root
      mode: 0666

    - name: copy watchlog.sh
      copy:
      src: files/test_systemd/watchlog.sh
      dest: /opt/
      owner: root
      group: root
      mode: 0755


    - name: copy watchlog.service
      copy:
      src: files/test_systemd/watchlog.service
      dest: /etc/systemd/system/
      owner: root
      group: root
      mode: 0644

    - name: copy watchlog.timer
      copy:
      src: files/test_systemd/watchlog.timer
      dest: /etc/systemd/system/
      owner: root
      group: root
      mode: 0644

    - name: starting service watchlog
      shell: systemctl start watchlog.timer watchlog.service
      
  #### 2 задание. Из репозитория epel установить spawn-fcgi и переписать init-скрипт на unit-файл (имя service должно называться так же: spawn-fcgi);
  
  В playbook.yml прописываем:
  
  установка репозитория и epel и установку spawn-fcgi:
  
    - name: install the latest version of spawn-fcgi
      shell: yum install epel-release -y && yum install spawn-fcgi php php-cli mod_fcgid httpd -y
      
  раскомметируем опции для работы:
  
    - name: change /etc/sysconfig/spawn-fcgi
      shell: sed -i 's/#SOCKET/SOCKET/' /etc/sysconfig/spawn-fcgi && sed -i 's/#OPTIONS/OPTIONS/' /etc/sysconfig/spawn-fcgi
  
  Копируем unit файл:
  
    - name: copy spawn-fcgi unit file
      copy:
      src: files/test_systemd/spawn-fcgi.service
      dest: /etc/systemd/system/
      owner: root
      group: root
      mode: 0644
      
  Стартуем сервис и получаем статус:
  
    - name: start spawn-fcgi service and get status
      shell: systemctl start spawn-fcgi.service && systemctl status spawn-fcgi.service
  
  #### 3 задание. Дополнить unit-файл httpd (он же apache) возможностью запустить несколько инстансов сервера с разными конфигурационными файлами.
  
   В playbook.yml прописываем:
   
   Копируем unit файл сервиса из /usr/lib/systemd/system/httpd.service в /etc/systemd/system/httpd@.service:
   
     - name: copy /usr/lib/systemd/system/httpd.service to /etc/systemd/system/httpd@.service
       shell: cp /usr/lib/systemd/system/httpd.service /etc/systemd/system/httpd@.service
   
   Изменяем строку в unit файле:
   
     - name: change /etc/systemd/system/httpd@.service
       shell: sed -i 's/EnvironmentFile=\/etc\/sysconfig\/httpd/EnvironmentFile=\/etc\/sysconfig\/httpd-%I/' /etc/systemd/system/httpd@.service
       
   Копируем файлы окружения для экземпляров:
   
     - name: copy /etc/sysconfig/httpd-first
      copy:
      src: files/test_systemd/httpd-first
      dest:  /etc/sysconfig/
      owner: root
      group: root
      mode: 0644

    - name: copy /etc/sysconfig/httpd-second
      copy:
      src: files/test_systemd/httpd-second
      dest:  /etc/sysconfig/
      owner: root
      group: root
      mode: 0644
  
  Создаем(копируем из старого конфига) конфиги для экземпляров:
  
    - name: copy httpd config to first and second
      shell: cp /etc/httpd/conf/httpd.conf /etc/httpd/conf/first.conf && cp /etc/httpd/conf/httpd.conf /etc/httpd/conf/second.conf
  
  В конфиге второго экземпляра меняем параметры PidFile и Listen:
  
    - name: edit httpd second conf
      shell: sed -i 's/Listen 80/Listen 8080/' /etc/httpd/conf/second.conf && sed -i 's/PidFile/PidFile \/var\/run\/httpd-second.pid/' /etc/httpd/conf/second.conf && sed -i 's/# least PidFile/PidFile/' /etc/httpd/conf/second.conf
  
  Перезагружаем кофигурацию systemd:
  
    - name: stop httpd service and reload systemd manager configuration
      shell: systemctl stop httpd && systemctl daemon-reload
  
  Стартуем сервисы:
  
    - name: Start httpd-first and httpd-second
      shell: systemctl start httpd@first && systemctl start httpd@second
      
  После разворачивания стенда, заходим в него, и проверяем:
  
    su -tnulp |grep httpd
    tail -f /var/log/messages
    systemctl start spawn-fcgi
    systemctl status spawn-fcgi

Мой вывод этих команд в скриншоте.
