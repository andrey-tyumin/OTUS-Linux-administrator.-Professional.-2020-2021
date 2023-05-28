утилиты для работы с SELinux
пакет setools-console 
    •sesearch просмотр\поиск политик SELinux
    •seinfo поиск параметров политик
    •findcon поиск\просмотр файловых контекстов
    Параметризованные политики
    •getsebool просмотр политик
    •setsebool - установка политик

пакет policycoreutils-python 
    •audit2allow - генерация модулей политик
    •audit2why - просмотр и вывод сообщений аудита (с описанием) в audit.log

semanage - настройка элементов политик, без перекомпиляции политик.
restorecon -восстановление файлового контекста(сбрасывает кэш). Делаем после изменения контекста.
chcon - изменение файлового контекста
sestatus - статус SELinux
setenforce - установить режим работы SELinux
getenforce - получить режим работы SELinux
semodule - управление модулями политик (установка\обновление\удаление\просмотр)
sealert - просмотр ошибок в логе audit.log (пример: sealert -a /var/log/audit/audit.log)