## **1. Определить алгоритм с наилучшим сжатием**

Установка ZFS <br>
(по инструкции с https://openzfs.github.io/openzfs-docs/Getting%20Started/RHEL%20and%20CentOS.html)<br>
```
yum install -y yum-utils
```
Проверяем версию centos:<br>
```
[root@otus ~]# cat /etc/centos-release
CentOS Linux release 7.6.1810 (Core)
```
Устанавливаем репозиторий ZFS в соответсвии с версией CentOS:<br>
```
[root@otus ~]# yum install -y http://download.zfsonlinux.org/epel/zfs-release.el7_6.noarch.rpm

```
Устанавливаем открытый ключ:<br>
```
[root@otus ~]# gpg --quiet --with-fingerprint /etc/pki/rpm-gpg/RPM-GPG-KEY-zfsonlinux

```
Проверяем:<br>
```
[root@otus ~]# yum repolist
Загружены модули: fastestmirror
Loading mirror speeds from cached hostfile
 * base: ams.edge.kernel.org
 * extras: ams.edge.kernel.org
 * updates: ftp.nluug.nl
Идентификатор репозитория                                                       репозиторий                                                                        состояние
base/7/x86_64                                                                   CentOS-7 - Base                                                                    10 070
extras/7/x86_64                                                                 CentOS-7 - Extras                                                                     413
updates/7/x86_64                                                                CentOS-7 - Updates                                                                  1 127
zfs/x86_64                                                                      ZFS on Linux for EL7 - dkms                                                            26
repolist: 11 636
```

По умолчанию zfs устанавливается в варианте DKMS(из исходников для самосборных ядер)<br>
Будем ставить zfs через kmod(kABI-tracking kmod driver).

Включаем репозиторий с kmod:<br>
```
yum-config-manager --enable zfs-kmod

```
Проверяем:<br>
```
[root@otus ~]# yum repolist
Загружены модули: fastestmirror
Loading mirror speeds from cached hostfile
 * base: ams.edge.kernel.org
 * extras: ams.edge.kernel.org
 * updates: ftp.nluug.nl
zfs                                                                                                                                                  | 2.9 kB  00:00:00
zfs-kmod                                                                                                                                             | 2.9 kB  00:00:00
zfs-kmod/x86_64/primary_db                                                                                                                           |  84 kB  00:00:00
Идентификатор репозитория                                                       репозиторий                                                                        состояние
base/7/x86_64                                                                   CentOS-7 - Base                                                                    10 070
extras/7/x86_64                                                                 CentOS-7 - Extras                                                                     413
updates/7/x86_64                                                                CentOS-7 - Updates                                                                  1 127
zfs/x86_64                                                                      ZFS on Linux for EL7 - dkms                                                            26
zfs-kmod/x86_64                                                                 ZFS on Linux for EL7 - kmod                                                            34
repolist: 11 670
```

Отключаем репозиторий с dkms:<br>
`[root@otus ~]# yum-config-manager --disable zfs`<br>
Проверяем:<br>
```
[root@otus ~]# yum repolist
Загружены модули: fastestmirror
Loading mirror speeds from cached hostfile
 * base: ams.edge.kernel.org
 * extras: ams.edge.kernel.org
 * updates: ftp.nluug.nl
Идентификатор репозитория                                                       репозиторий                                                                        состояние
base/7/x86_64                                                                   CentOS-7 - Base                                                                    10 070
extras/7/x86_64                                                                 CentOS-7 - Extras                                                                     413
updates/7/x86_64                                                                CentOS-7 - Updates                                                                  1 127
zfs-kmod/x86_64                                                                 ZFS on Linux for EL7 - kmod                                                            34
repolist: 11 644
```

Устанавливаем zfs:<br>
```
yum install -y zfs.

```
Создаем файлы, кот. будем использовать в качестве дисков:<br>
```
echo disk{1..6} | xargs -n 1 fallocate -l 500M

```
Создадим raidz1 из 6 дисков:<br>
```
zpool create super_raid raidz1 $PWD/disk[1-6]

```
Проверяем:<br>
```
[root@otus ~]# zpool list
NAME         SIZE  ALLOC   FREE  EXPANDSZ   FRAG    CAP  DEDUP  HEALTH  ALTROOT
super_raid  2,89G   848K  2,89G         -     0%     0%  1.00x  ONLINE  -
```
или<br>
```
[root@otus ~]# zpool status
  pool: super_raid
 state: ONLINE
  scan: none requested
config:

	NAME             STATE     READ WRITE CKSUM
	super_raid       ONLINE       0     0     0
	  raidz1-0       ONLINE       0     0     0
	    /root/disk1  ONLINE       0     0     0
	    /root/disk2  ONLINE       0     0     0
	    /root/disk3  ONLINE       0     0     0
	    /root/disk4  ONLINE       0     0     0
	    /root/disk5  ONLINE       0     0     0
	    /root/disk6  ONLINE       0     0     0

errors: No known data errors
```

```
[root@otus ~]# df -h
Файловая система Размер Использовано  Дост Использовано% Cмонтировано в
/dev/vda1           80G         4,0G   77G            5% /
devtmpfs           1,9G            0  1,9G            0% /dev
tmpfs              1,9G            0  1,9G            0% /dev/shm
tmpfs              1,9G          17M  1,9G            1% /run
tmpfs              1,9G            0  1,9G            0% /sys/fs/cgroup
tmpfs              379M            0  379M            0% /run/user/0
super_raid         2,3G            0  2,3G            0% /super_raid
```

Создаем файловые системы:<br>
```
[root@otus ~]# zfs create super_raid/st1
[root@otus ~]# zfs create super_raid/st2
[root@otus ~]# zfs create super_raid/st3
[root@otus ~]# zfs create super_raid/st4
[root@otus ~]# zfs create super_raid/st5
[root@otus ~]# zfs create super_raid/st6
```
Проверяем:<br>
```
root@otus ~]# zfs list
NAME             USED  AVAIL  REFER  MOUNTPOINT
super_raid       373K  2,27G  46,5K  /super_raid
super_raid/st1  36,5K  2,27G  36,5K  /super_raid/st1
super_raid/st2  36,5K  2,27G  36,5K  /super_raid/st2
super_raid/st3  36,5K  2,27G  36,5K  /super_raid/st3
super_raid/st4  36,5K  2,27G  36,5K  /super_raid/st4
super_raid/st5  36,5K  2,27G  36,5K  /super_raid/st5
super_raid/st6  36,5K  2,27G  36,5K  /super_raid/st6
```

Смотрим какие методы сжатия поддерживает эта версия zfs:<br>
```
compression     YES      YES   on | off | lzjb | gzip | gzip-[1-9] | zle | lz4
```
Для примера смотрим параметр compression на super_raid/st1:<br>
```
[root@otus ~]# zfs get compression super_raid/st1
NAME            PROPERTY     VALUE     SOURCE
super_raid/st1  compression  off       default
```
Включаем сжатие:<br>
```
[root@otus ~]# zfs set compression=on super_raid/st1

```
Проверяем:<br>
```
[root@otus ~]# zfs get compression super_raid/st1
NAME            PROPERTY     VALUE     SOURCE
super_raid/st1  compression  on        local
```
На других фс ставим разные способы сжатия:<br>
```
[root@otus ~]# zfs set compression=lzjb super_raid/st2
[root@otus ~]# zfs get compression super_raid/st2
NAME            PROPERTY     VALUE     SOURCE
super_raid/st2  compression  lzjb      local
[root@otus ~]# zfs set compression=gzip super_raid/st3
[root@otus ~]# zfs get compression super_raid/st3
NAME            PROPERTY     VALUE     SOURCE
super_raid/st3  compression  gzip      local
[root@otus ~]# zfs set compression=gzip-9 super_raid/st4
[root@otus ~]# zfs get compression super_raid/st4
NAME            PROPERTY     VALUE     SOURCE
super_raid/st4  compression  gzip-9    local
[root@otus ~]# zfs set compression=zle super_raid/st5
[root@otus ~]# zfs get compression super_raid/st5
NAME            PROPERTY     VALUE     SOURCE
super_raid/st5  compression  zle       local
[root@otus ~]# zfs set compression=lz4 super_raid/st6
[root@otus ~]# zfs get compression super_raid/st6
NAME            PROPERTY     VALUE     SOURCE
super_raid/st6  compression  lz4       local
```

Скачиваем "Войну и мир":<br>
```
wget -O War_and_Peace.txt http://www.gutenberg.org/ebooks/2600.txt.utf-8

```
Копируем на новые фс, и проверяем:<br>
```
[root@otus super_raid]# zfs get compressratio /super_raid/st{1..6}
NAME            PROPERTY       VALUE  SOURCE
super_raid/st1  compressratio  1.08x  -
super_raid/st2  compressratio  1.07x  -
super_raid/st3  compressratio  1.08x  -
super_raid/st4  compressratio  1.08x  -
super_raid/st5  compressratio  1.08x  -
super_raid/st6  compressratio  1.08x  -
```
lzjb немного хуже сжатие. Остальные в данном случае одинаково.<br>


## **2.  Определить настройки pool’a**
Скачиваем:
```
wget https://drive.google.com/open?id=1KRBNW33QWqbvbVHa3hLJivOAt60yukkg

```
```
gunzip ./zfs_task1.tar.gz
tar xvf ./zfs_task1.tar
```
Получили каталог zpoolexport.<br>

Получим инфо о pool-е:<br>
```
[root@otus ~]# zpool import -d zpoolexport
   pool: otus
     id: 6554193320433390805
  state: UNAVAIL
status: The pool can only be accessed in read-only mode on this system. It
	cannot be accessed in read-write mode because it uses the following
	feature(s) not supported on this system:
	org.zfsonlinux:project_quota (space/object accounting based on project ID.)
	com.delphix:spacemap_v2 (Space maps representing large segments are more efficient.)
action: The pool cannot be imported in read-write mode. Import the pool with
	"-o readonly=on", access the pool on a system that supports the
	required feature(s), or recreate the pool from backup.
 config:

	otus                         UNAVAIL  unsupported feature(s)
	  mirror-0                   ONLINE
	    /root/zpoolexport/filea  ONLINE
	    /root/zpoolexport/fileb  ONLINE
```
Пробуем импортировать:<br>
```
[root@otus ~]# zpool import -d ${PWD}/zpoolexport/ otus
This pool uses the following feature(s) not supported by this system:
	org.zfsonlinux:project_quota (space/object accounting based on project ID.)
	com.delphix:spacemap_v2 (Space maps representing large segments are more efficient.)
All unsupported features are only required for writing to the pool.
The pool can be imported using '-o readonly=on'.
cannot import 'otus': unsupported version or feature
```
У меня версия zfs старее чем версия этого пула, импорт только на чтение.<br>

```
[root@otus ~]# zpool import -o readonly=on -d ${PWD}/zpoolexport/ otus

```
Проверяем:<br>
```
[root@otus ~]# zpool status
  pool: otus
 state: ONLINE
  scan: none requested
config:

	NAME                         STATE     READ WRITE CKSUM
	otus                         ONLINE       0     0     0
	  mirror-0                   ONLINE       0     0     0
	    /root/zpoolexport/filea  ONLINE       0     0     0
	    /root/zpoolexport/fileb  ONLINE       0     0     0

errors: No known data errors

  pool: super_raid
 state: ONLINE
  scan: none requested
config:

	NAME             STATE     READ WRITE CKSUM
	super_raid       ONLINE       0     0     0
	  raidz1-0       ONLINE       0     0     0
	    /root/disk1  ONLINE       0     0     0
	    /root/disk2  ONLINE       0     0     0
	    /root/disk3  ONLINE       0     0     0
	    /root/disk4  ONLINE       0     0     0
	    /root/disk5  ONLINE       0     0     0
	    /root/disk6  ONLINE       0     0     0

errors: No known data errors
```

Получаем информацию о пуле:<br>
```
[root@otus ~]# zfs get all otus
NAME  PROPERTY              VALUE                      SOURCE
otus  type                  filesystem                 -
otus  creation              Пт май 15  4:00 2020  -
otus  used                  2,03M                      -
otus  available             350M                       -
otus  referenced            24K                        -
otus  compressratio         1.00x                      -
otus  mounted               yes                        -
otus  quota                 none                       default
otus  reservation           none                       default
otus  recordsize            128K                       local
otus  mountpoint            /otus                      default
otus  sharenfs              off                        default
otus  checksum              sha256                     local
otus  compression           zle                        local
otus  atime                 on                         default
otus  devices               on                         default
otus  exec                  on                         default
otus  setuid                on                         default
otus  readonly              on                         temporary
otus  zoned                 off                        default
otus  snapdir               hidden                     default
otus  aclinherit            restricted                 default
otus  createtxg             1                          -
otus  canmount              on                         default
otus  xattr                 on                         default
otus  copies                1                          default
otus  version               5                          -
otus  utf8only              off                        -
otus  normalization         none                       -
otus  casesensitivity       sensitive                  -
otus  vscan                 off                        default
otus  nbmand                off                        default
otus  sharesmb              off                        default
otus  refquota              none                       default
otus  refreservation        none                       default
otus  guid                  14592242904030363272       -
otus  primarycache          all                        default
otus  secondarycache        all                        default
otus  usedbysnapshots       0B                         -
otus  usedbydataset         24K                        -
otus  usedbychildren        2,01M                      -
otus  usedbyrefreservation  0B                         -
otus  logbias               latency                    default
otus  dedup                 off                        default
otus  mlslabel              none                       default
otus  sync                  standard                   default
otus  dnodesize             legacy                     default
otus  refcompressratio      1.00x                      -
otus  written               24K                        -
otus  logicalused           1019K                      -
otus  logicalreferenced     12K                        -
otus  volmode               default                    default
otus  filesystem_limit      none                       default
otus  snapshot_limit        none                       default
otus  filesystem_count      none                       default
otus  snapshot_count        none                       default
otus  snapdev               hidden                     default
otus  acltype               off                        default
otus  context               none                       default
otus  fscontext             none                       default
otus  defcontext            none                       default
otus  rootcontext           none                       default
otus  relatime              off                        default
otus  redundant_metadata    all                        default
otus  overlay               off                        default

```
Продолжение на другой виртуалке, т.к. в этой zfs старой версии.

## **3.Найти сообщение от преподавателей.**
Скачиваем файл со снапшотом, и получаем его:<br>
```
zfs receive otus/storage@task2 <otus_task2.file

```
смотрим файл:<br>
```
 vi /otus/storage/task1/file_mess/secret_message

```
 там:<br>
```
 https://github.com/sindresorhus/awesome

```


