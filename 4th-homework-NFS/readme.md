## Установка  и настройка NFS сервер\клиент CentOS7

### Серверная часть</br>
устанавливаем компоненты NFS:</br>
  *nfs-utils - NFS utilities and supporting clients and daemons for the kernel NFS server.</br>*
  *nfs-utils-lib - Network File System Support Library</br>*
  *yum install nfs-utils nfs-utils -y</br>*
Создаем директорию, которую будем экспортировать:</br>
  *mkdir -p /var/super_shara/upload</br>*
Ключ -p создает все отсутствующие каталоги в пути. Экспортировать будем каталог /var/super_shara, но право записи дадим только в каталог /var/super_shara/upload.</br>
Меняем владельца /var/super_shara/upload на анонимного пользователя nfsnobody:</br>
  *chown nfsnobody /var/super_shara/upload.</br>*
В параметрах /etc/exportfs укажем ключ all_squash - все будут писать в каталог /var/super_shara/upload от имени пользователя nfsnobody.</br>
Включаем и запускаем сервисы:</br>
  *sudo systemctl enable rpcbind</br>*
  *sudo systemctl enable nfs-server</br>*
  *sudo  systemctl enable nfs-lock</br>*
  *sudo systemctl start rpcbind</br>*
  *sudo systemctl start nfs-server</br>*
  *sudo systemctl start nfs-lock</br>*

Вносим изменения в etc/exports:</br>
*echo "/var/super_shara 192.168.50.11(rw,sync,root_squash,all_squash)" >> /etc/exports</br>*
Перечитываем конфиг:</br>
*exportfs -a</br>*
#### Настройка firewall:</br>
Запустим firewall:</br>
*systemctl start firewalld.service</br>*
Для NFS3 нужно открыть порты: 111(RPC)(Для NFS4 не нужно),2049(NFS), и mountd(произвольный порт, можно назначить постоянный в /etc/sysconfig/nfs)</br>
*firewall-cmd --zone=public --add-service=nfs3 --permanent</br>*
*firewall-cmd --zone=public --add-service=rpc-bind --permanent</br>*
*firewall-cmd --zone=public --add-service=mountd --permanent</br>*
*firewall-cmd --reload</br>*



## Клиентская часть</br>

Также устанавливаем компоненты  NFS:</br>
*yum install nfs-utils nfs-utils -y</br>*
создаем каталог, в который будем монтировать:</br>
*mkdir /mnt/mega-shara</br>*
Монтируем:</br>
*mount -t nfs -o vers=3,proto=udp 192.168.50.10:/var/super_shara /mnt/mega-shara</br>*
Дабавляем запись в /etc/fstab:</br>
*echo "192.168.50.10: /var/super_shara/  /mnt/mega-shara/        nfs     rw,sync,hard,intr       0 0" >>/etc/fstab</br>*

### Использование autofilesystem  вместо /etc/fstab:</br>
Устанавливаем пакет autosf:</br>
*yum install autofs -y</br>*
Редактируем  Master map file (/etc/auto.master):</br>
Добавляем строку:</br>
*/mnt	/etc/auto.mega	--timeout=180</br>*
Формат записи: точка куда монтируем	map файл	опции(опции не обязательны, тут timeout - количество секунд простоя после которых устройство будет отмонтировано)</br>
Создаем map file(auto.mega) и записываем туда строку:</br>
*mega-shara	-fstype=nfs,rw,soft,intr	192.168.50.10:/var/super_shara/</br>*
Перестартуем autofs:</br>
*service autofs restart</br>*

### Использование systemd automount:</br>
*yum install nfs-utils nfs-utils-lib autofs -y</br>*
*mkdir /mnt/mega-shara</br>*
Перед созданием unit нужно будет преобразовать путь к точке монтирования в \x2descape -стиль.</br>
systemd-escape \mnt\mega-shara. Это имя используем для именования юнита.</br>
Генерим юнит:</br>
*cat << EOF | sudo tee '/etc/systemd/system/mnt-mega\x2dshara.mount'</br>*
*[Unit]</br>*
*Description=Mount NFS share</br>*
*After=network-online.service</br>*
*Wants=network-online.service</br>*
</br>
*[Mount]</br>*
*What=192.168.50.10:/var/super_shara</br>*
*Where=/mnt/mega-shara</br>*
*Options=rw,sync,hard,intr</br>*
*Type=nfs</br>*
*TimeoutSec=60</br>*
</br>
*[Install]</br>*
*WantedBy=multi-user.target</br>*
*EOF</br>*
</br>
Прописываем использование 3-й версии nfs в клиенте:</br>
*echo 'Defaultvers=3'>>/etc/nfsmount.conf</br>*
Перестартуем system manager:</br>
*systemctl daemon-reload</br>*
Включаем монтирование:</br>
*systemctl enable 'mnt-mega\x2dshara.mount'</br>*
Монтируем:</br>
*systemctl start 'mnt-mega\x2dshara.mount'</br>*


используемые источники:</br>
http://www.bog.pp.ru/work/NFS.html</br>
https://montazhtv.ru/firewall-otkryt-port-centos-7/</br>
https://www.linuxtechi.com/automount-nfs-share-in-linux-using-autofs/</br>
https://linuxconfig.org/how-to-configure-the-autofs-daemon-on-centos-7-rhel-7</br>
https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/storage_administration_guide/ch-nfs#s2-nfs-how-daemons</br>
https://www.digitalocean.com/community/tutorials/how-to-set-up-an-nfs-mount-on-ubuntu-20-04-ru</br>
https://blog.sleeplessbeastie.eu/2019/09/23/how-to-mount-nfs-share-using-systemd/</br>
https://wiki.it-kb.ru/unix-linux/centos/linux-how-to-setup-nfs-server-with-share-and-nfs-client-in-centos-7-2</br>

