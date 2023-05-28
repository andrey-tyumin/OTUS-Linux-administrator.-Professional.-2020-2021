### Строим бонды и вланы
в Office1 в тестовой подсети появляется сервера с доп интерфесами и адресами
в internal сети testLAN
- testClient1 - 10.10.10.254
- testClient2 - 10.10.10.254
- testServer1- 10.10.10.1
- testServer2- 10.10.10.1

равести вланами
testClient1 <-> testServer1
testClient2 <-> testServer2

между centralRouter и inetRouter
"пробросить" 2 линка (общая inernal сеть) и объединить их в бонд
проверить работу c отключением интерфейсов

### Решение
Прилагается Vagrantfile и playbook.yml

Все операции в yml реализованы с помощью модуля nmcli.

После поднятия вируталок:
```
vagrant up
```
Нужно будет обработать playbook.yml:
```
ansible-playbook playbook.yml
```
Схема стенда:
![alt text](https://github.com/imustgetout/24th-homework-BOND_and_VLAN/blob/main/network23-1801-024140.png)
