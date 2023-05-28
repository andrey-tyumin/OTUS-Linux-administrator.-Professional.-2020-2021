
### Задачи 
#### Dockerfile

Создайте свой кастомный образ nginx на базе alpine. (ссылка на образ: https://hub.docker.com/repository/docker/imustgetout/nginxalpine )

После запуска nginx должен отдавать кастомную страницу (достаточно изменить дефолтную страницу nginx)

Определите разницу между контейнером и образом

Вывод опишите в домашнем задании.

Ответьте на вопрос: Можно ли в контейнере собрать ядро?

Собранный образ необходимо запушить в docker hub и дать ссылку на ваш репозиторий.




#### Что должно быть Dockerfile:

FROM image name

RUN apt update -y && apt upgrade -y 

COPY или ADD filename /path/in/image

EXPOSE portopenning

CMD or ENTRYPOINT or both

#не забываем про разницу между COPY и ADD#or - одна из опций на выбор

### Ответы на вопросы

#### Описать разницу между контейнером и образом:

образ -источник контейнеров, контейнер без слоя для записи, 

Мне больше нравится определение в сравнении с програмированием: 

Образ - это класс, контейнер -объект.

#### Можно ли в контейнере собрать ядро?

Ничто не мешает скомпилировать своё ядро в контейнере. Только смысла в этом нет(я не смог придумать, но возможно что все-таки это где-то нужно),

т.к. использовать его в контейнере по определению нельзя.

Попробовал сделать это в докере из образа centos7:

    yum update
    yum install -y ncurses-devel make gcc bc bison flex elfutils-libelf-devel openssl-devel grub2 wget perl
    cd /usr/src/
    wget https://cdn.kernel.org/pub/linux/kernel/v4.x/linux-4.17.11.tar.xz
    tar -xvf linux-4.17.11.tar.xz
    cd linux-4.17.11/
    make menuconfig
    Выбрать Save->Exit.
    make bzImage
 
 Вывод:

    Setup is 15356 bytes (padded to 15360 bytes).
    System is 8013 kB
    CRC 2607950c
    Kernel: arch/x86/boot/bzImage is ready  (#1)
    [root@cd487e5896df linux-4.17.11]# ls -al arch/x86/boot/bzImage
    -rw-r--r--. 1 root root 8220208 Oct 29 20:41 arch/x86/boot/bzImage
    [root@cd487e5896df linux-4.17.11]#
 
 Готово.
