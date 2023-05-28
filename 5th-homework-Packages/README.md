# otus-5th-homework
##  Управление пакетами. Дистрибьюция софта 
Устанавливаем необходимые пакеты:

yum install redhat-lsb-core wget rpmdevtools rpm-build createrepo yum-utils

Загружаем пакет с исходниками NGINX:

wget https://nginx.org/packages/centos/7/SRPMS/nginx-1.18.0-1.el7.ngx.src.rpm

Устанавливаем:

rpm -i nginx-1.18.0-1.el7.ngx.src.rpm

Скачиваем исходники openssl:

wget https://www.openssl.org/source/latest.tar.gz

Распаковываем:

tar -xvf latest.tar.gz

Поставим зависимости:

yum-builddep rpmbuild/SPECS/nginx.spec


В nginx.spec в секцию %build вставляем:

--with-openssl=/home/ec2-user/openssl-1.1.1g

### Сборка:
yum install gcc
rpmbuild -bb rpmbuild/SPECS/nginx.spec


Проверям есть ли пакеты:
ll rpmbuild/RPMS/x86_64/

Ставим nginx из собранного пакета:
yum localinstall -y rpmbuild/RPMS/x86_64/nginx-1.18.0-1.el8.ngx.x86_64.rpm


Стартуем:
systemctl start nginx

Проверяем:
systemctl status nginx

### Создаем свой репозиторий.

Каталог для репозитория:
mkdir /usr/share/nginx/html/repo

Копируем туда собранный rpm:
cp rpmbuild/RPMS/x86_64/nginx-1.18.0-1.el8.ngx.x86_64.rpm /usr/share/nginx/html/repo/

И rpm для Persona-Server:
wget http://www.percona.com/downloads/percona-release/redhat/0.1-6/percona-release-0.1-6.noarch.rpm -O /usr/share/nginx/html/repo/percona-release-0.1-6.noarch.rpm

Инициализируем репозиторий:
createrepo /usr/share/nginx/html/repo

##### Настройка nginx для доступа к листингу каталога:
В /etc/nginx/conf.d/default.conf в секцию location добавляем autoindex on;

Проверяем синтаксис:
nginx -t

перезагружаем:
nginx -s reload

Проверяем:

lynx http://localhost/repo

или

curl -a http://localhost/repo/


Добавляем созданный репозиторий в /etc/yum.repos.d:
cat >> /etc/yum.repos.d/otus.repo << EOF
[otus]
name=otus-linux
baseurl=http://localhost/repo
gpgcheck=0
enabled=1
EOF

Проверяем подключился ли репозиторий:

yum repolist enabled | grep otus

yum list | grep otus

Установим репозиторий percona-release:

yum install percona-release -y
