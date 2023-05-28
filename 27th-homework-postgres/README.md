### репликация postgres
- Настроить hot_standby репликацию с использованием слотов
- Настроить правильное резервное копирование

Для сдачи работы присылаем ссылку на репозиторий, в котором должны обязательно быть
- Vagranfile (2 машины)
- плейбук Ansible
- конфигурационные файлы postgresql.conf, pg_hba.conf и recovery.conf,
- конфиг barman, либо скрипт резервного копирования.

Команда "vagrant up" должна поднимать машины с настроенной репликацией и резервным копированием.
Рекомендуется в README.md файл вложить результаты (текст или скриншоты) проверки работы репликации и резервного копирования.

#### Реализация:

После 
```
vagrant up
```
Стенд готов к проверке
Заходим на masterServer, проверяем, список баз:
```
[root@masterServer vagrant]# su -l postgres
-bash-4.2$ psql -l
                                  List of databases
   Name    |  Owner   | Encoding |   Collate   |    Ctype    |   Access privileges   
-----------+----------+----------+-------------+-------------+-----------------------
 postgres  | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | 
 template0 | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/postgres          +
           |          |          |             |             | postgres=CTc/postgres
 template1 | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/postgres          +
           |          |          |             |             | postgres=CTc/postgres
 test_db   | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | 
(4 rows)
```

test_db создана, проверяем её наличие на slaveServer:

```
[root@slaveServer vagrant]# su - postgres
-bash-4.2$ psql -l
                                  List of databases
   Name    |  Owner   | Encoding |   Collate   |    Ctype    |   Access privileges   
-----------+----------+----------+-------------+-------------+-----------------------
 postgres  | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | 
 template0 | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/postgres          +
           |          |          |             |             | postgres=CTc/postgres
 template1 | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/postgres          +
           |          |          |             |             | postgres=CTc/postgres
 test_db   | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | 
(4 rows)
```

На slaveServer база тоже появилась.

Создадим на masterServer еще одну базу:
```
[root@masterServer vagrant]# su -l postgres
-bash-4.2$ psql -l
                                  List of databases
   Name    |  Owner   | Encoding |   Collate   |    Ctype    |   Access privileges   
-----------+----------+----------+-------------+-------------+-----------------------
 postgres  | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | 
 template0 | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/postgres          +
           |          |          |             |             | postgres=CTc/postgres
 template1 | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/postgres          +
           |          |          |             |             | postgres=CTc/postgres
 test_db   | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | 
(4 rows)

-bash-4.2$ createdb test_db2
-bash-4.2$ psql -l
                                  List of databases
   Name    |  Owner   | Encoding |   Collate   |    Ctype    |   Access privileges   
-----------+----------+----------+-------------+-------------+-----------------------
 postgres  | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | 
 template0 | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/postgres          +
           |          |          |             |             | postgres=CTc/postgres
 template1 | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/postgres          +
           |          |          |             |             | postgres=CTc/postgres
 test_db   | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | 
 test_db2  | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | 
(5 rows)
```

Проверим её наличиен на slaveServer:

```
[root@slaveServer vagrant]# su - postgres
-bash-4.2$ psql -l
                                  List of databases
   Name    |  Owner   | Encoding |   Collate   |    Ctype    |   Access privileges   
-----------+----------+----------+-------------+-------------+-----------------------
 postgres  | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | 
 template0 | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/postgres          +
           |          |          |             |             | postgres=CTc/postgres
 template1 | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/postgres          +
           |          |          |             |             | postgres=CTc/postgres
 test_db   | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | 
(4 rows)

-bash-4.2$ psql -l
                                  List of databases
   Name    |  Owner   | Encoding |   Collate   |    Ctype    |   Access privileges   
-----------+----------+----------+-------------+-------------+-----------------------
 postgres  | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | 
 template0 | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/postgres          +
           |          |          |             |             | postgres=CTc/postgres
 template1 | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/postgres          +
           |          |          |             |             | postgres=CTc/postgres
 test_db   | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | 
 test_db2  | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | 
(5 rows)
```
Готово.

### Проверка бэкапа с помощью Barman:

Заходим на barman.

Наберем команды:

barman cron -чтобы начать архивирование WAL.

barman switch-wal --force --archive masterServer -чтобы postgres переключился на следующий wal.

barman check masterServer -проверим конфиг и соединение с masterServer

barman backup masterServer - сделать бэкап postgres на masterServer.

```
[root@vps13419 postgresql]# vagrant ssh barman
Last login: Tue Jan 19 09:59:54 2021 from 10.0.2.2
[vagrant@barman ~]$ sudo su
[root@barman vagrant]# su - barman
-bash-4.2$ barman cron
Starting WAL archiving for server masterServer
-bash-4.2$ barman switch-wal --force --archive masterServer
The WAL file 000000010000000000000003 has been closed on server 'masterServer'
Waiting for the WAL file 000000010000000000000003 from server 'masterServer' (max: 30 seconds)
Processing xlog segments from streaming for masterServer
	000000010000000000000003
-bash-4.2$ barman check masterServer
Server masterServer:
	PostgreSQL: OK
	superuser or standard user with backup privileges: OK
	PostgreSQL streaming: OK
	wal_level: OK
	replication slot: OK
	directories: OK
	retention policy settings: OK
	backup maximum age: OK (no last_backup_maximum_age provided)
	compression settings: OK
	failed backups: OK (there are 0 failed backups)
	minimum redundancy requirements: OK (have 0 backups, expected at least 0)
	pg_basebackup: OK
	pg_basebackup compatible: OK
	pg_basebackup supports tablespaces mapping: OK
	systemid coherence: OK (no system Id stored on disk)
	pg_receivexlog: OK
	pg_receivexlog compatible: OK
	receive-wal running: OK
	archiver errors: OK
-bash-4.2$ barman backup masterServer
Starting backup using postgres method for server masterServer in /var/lib/barman/masterServer/base/20210119T101536
Backup start at LSN: 0/4000060 (000000010000000000000004, 00000060)
Starting backup copy via pg_basebackup for 20210119T101536
Copy done (time: 9 seconds)
Finalising the backup.
This is the first backup for server masterServer
WAL segments preceding the current backup have been found:
	000000010000000000000003 from server masterServer has been removed
Backup size: 30.1 MiB
Backup end at LSN: 0/6000000 (000000010000000000000005, 00000000)
Backup completed (start time: 2021-01-19 10:15:36.864060, elapsed time: 15 seconds)
Processing xlog segments from streaming for masterServer
	000000010000000000000004
	000000010000000000000005
```

Бэкап работает

Проверим:
```
-bash-4.2$ barman list-backup masterServer
masterServer 20210119T101536 - Tue Jan 19 10:15:46 2021 - Size: 46.1 MiB - WAL Size: 16.0 MiB
-bash-4.2$ barman recover masterServer 20210119T101536 /var/log/barman/
Starting local restore for server masterServer using backup 20210119T101536
Destination directory: /var/log/barman/
Copying the base backup.
Copying required WAL segments.
Generating archive status files
Identify dangerous settings in destination directory.

Recovery completed (start time: 2021-01-19 10:44:40.489435, elapsed time: 6 seconds)

Your PostgreSQL server has been successfully prepared for recovery!
-bash-4.2$ ls -al /var/log/barman
total 92
drwx------. 20 barman barman  4096 Jan 19 10:44 .
drwxr-xr-x. 10 root   root    4096 Jan 19 09:59 ..
-rw-------.  1 barman barman   224 Jan 19 10:15 backup_label
-rw-rw-r--.  1 barman barman  1642 Jan 19 10:44 barman.log
-rw-rw-r--.  1 barman barman   917 Jan 19 10:44 .barman-recover.info
drwx------.  6 barman barman    54 Jan 19 10:15 base
-rw-------.  1 barman barman    44 Jan 19 10:15 current_logfiles
drwx------.  2 barman barman  4096 Jan 19 10:15 global
drwx------.  2 barman barman   112 Jan 19 10:15 log
drwx------.  2 barman barman     6 Jan 19 10:15 pg_commit_ts
drwx------.  2 barman barman     6 Jan 19 10:15 pg_dynshmem
-rw-r--r--.  1 barman barman  4754 Jan 19 10:15 pg_hba.conf
-rw-------.  1 barman barman  4269 Jan 19 10:15 pg_hba.conf.4202.2021-01-19@09:51:42~
-rw-------.  1 barman barman  1636 Jan 19 10:15 pg_ident.conf
drwx------.  4 barman barman    68 Jan 19 10:15 pg_logical
drwx------.  4 barman barman    36 Jan 19 10:15 pg_multixact
drwx------.  2 barman barman     6 Jan 19 10:15 pg_notify
drwx------.  2 barman barman     6 Jan 19 10:15 pg_replslot
drwx------.  2 barman barman     6 Jan 19 10:15 pg_serial
drwx------.  2 barman barman     6 Jan 19 10:15 pg_snapshots
drwx------.  2 barman barman     6 Jan 19 10:15 pg_stat
drwx------.  2 barman barman     6 Jan 19 10:15 pg_stat_tmp
drwx------.  2 barman barman     6 Jan 19 10:15 pg_subtrans
drwx------.  2 barman barman     6 Jan 19 10:15 pg_tblspc
drwx------.  2 barman barman     6 Jan 19 10:15 pg_twophase
-rw-------.  1 barman barman     3 Jan 19 10:15 PG_VERSION
drwx------.  3 barman barman    92 Jan 19 10:44 pg_wal
drwx------.  2 barman barman    18 Jan 19 10:15 pg_xact
-rw-------.  1 barman barman    88 Jan 19 10:44 postgresql.auto.conf
-rw-------.  1 barman barman    88 Jan 19 10:15 postgresql.auto.conf.origin
-rw-r--r--.  1 barman barman  1030 Jan 19 10:44 postgresql.conf
-rw-------.  1 barman barman 23987 Jan 19 10:15 postgresql.conf.4083.2021-01-19@09:51:41~
-rw-r--r--.  1 barman barman  1030 Jan 19 10:15 postgresql.conf.origin
```
Работает (каталог для воссановления был выбран произвольно).
