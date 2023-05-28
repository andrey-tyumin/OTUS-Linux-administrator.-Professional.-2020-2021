## Загрузка Linux.

Попасть в систему без пароля несколькими способами.

Открыть GUI VirtualBox, запустить виртуальную машину, при выборе загрузки нажать e(edit).

Попадаем в окно редактирования параметров загрузки.


#### Способ 1. init=/bin/sh

В этом случае вместо процесса init запускаем shell.

В конце строки начинающейся с linux16 добавляем init=/bin/sh и нажимаем ctrl-x для загрузки в систему. Но / смонтирован в read only. Перемонтируем на запись:

mount -o remount,rw /

Проверим:

mount | grep root


#### Способ 2. rd.break

В этом случае прерывается процесс загрузки перед монтированием root файловой системы в /, после загрузки initramfs.

В конце строки начинающейся с linux16 добавляем rd.break и нажимаем ctrl-x для загрузки в систему.

/ смонтироваен в /sysroot read-only и мы не в нём.

Перемонтируем:

mount -o remount,rw /sysroot

Поменяем корень:

chroot /sysroot

Сменим пароль:

passwd root

Если не используется SELinux, то на этом можно закончить.

CentOS 7 использует SELinux в принудительном режиме, поэтому продолжаем:

В рез-те изменения пароля изменен файл /etc/shadow и будет несоответствие с контекстом SELinux. 

Для расстановки новых меток файлов делаем:

touch /.autorelabel

После перезагрузки система обнаружит этот файл и сделает relabel всех файлов системы.


#### Способ 3. rw init=/sysroot/bin/sh

В строке начинающейся с linux16 заменяем ro на rw init=/sysroot/bin/sh и нажимаем ctrl-x для загрузки в систему.

Загружаемся, меняем пароль:

passwd root

## Установить систему с LVM, после чего переименовать VG

Проверяем что есть:

vgs

Смотрим на строку с Volume Group


переименовываем:

vgrename VolGroup00 OtusRoot

В файлах /etc/fstab, /etc/default/grub, /boot/grub2/grub.cfg (у меня grub.cfg был в /boot/efi?EFI/centos/grub.cfg) 

меняем старое название(VolGroup00) на новое(OtusRoot)

Пересоздаем initrd image, чтобы он "знал" новое название:

mkinitrd -f -v /boot/initramfs-$(uname -r).img $(uname -r)

Перезагружаемся.

Проверяем что есть теперь:

vgs

## Добавить модуль в initrd.

Скрипты модулей лежат в /usr/lib/dracut/modules.d/

Создаем папку для своих скриптов:

mkdir /usr/lib/dracut/modules.d/01test

Скачиваем туда два скрипта:

wget https://gist.github.com/lalbrekht/e51b2580b47bb5a150bd1a002f16ae85 -o /usr/lib/dracut/modules.d/01test

wget https://gist.github.com/lalbrekht/ac45d7a6c6856baea348e64fac43faf0 -o /usr/lib/dracut/modules.d/01test

Пересобираем образ initrd:

mkinitrd -f -v /boot/initramfs-$(uname -r).img $(uname -r)

или 

dracut -f -v

Проверяем загружен ли модуль в initramfs:

lsinitrd -m /boot/initramfs-$(uname -r).img | grep test

В grub.cfg убираем опции rghb и quiet

Перезагружаемся и смотрим на пингвина.
