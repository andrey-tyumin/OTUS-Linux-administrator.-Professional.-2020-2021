## Задача: 
Запретить всем пользователям, кроме группы admin логин в выходные (суббота и воскресенье), без учета праздников

## Реализация:
Выполнение через PAM

Создаем группу admin:

	[root@otus ~]# groupadd admin

Зачисляем туда пользователей:

	[root@otus ~]# usermod -aG admin test1
	[root@otus ~]# id test1
	uid=1002(test1) gid=1002(test1) группы=1002(test1),1003(admin)

В файл /etc/security/time.conf прописываем строку:

	*;*;*;MoTuWeThFr0000-2400
	
Значение: все сервисы;все терминалы;все пользователи; только в рабочие дни
	
В system-auth(/etc/pam.d/system-auth-ac) перед первой строкой с типом account и флагом sufficient добавляем:

	account  sufficient  pam_succeed_if.so user ingroup admin
	account  required    pam_time.so

До изменения:
	
	[test1@otus ~]$ cat /etc/pam.d/system-auth-ac
	#%PAM-1.0
	# This file is auto-generated.
	# User changes will be destroyed the next time authconfig is run.
	auth        required      pam_env.so
	auth        required      pam_faildelay.so delay=2000000
	auth        sufficient    pam_unix.so nullok try_first_pass
	auth        requisite     pam_succeed_if.so uid >= 1000 quiet_success
	auth        required      pam_deny.so
	
	account     required      pam_unix.so
	account     sufficient    pam_localuser.so
	account     sufficient    pam_succeed_if.so uid < 1000 quiet
	account     required      pam_permit.so
	
	password    requisite     pam_pwquality.so try_first_pass local_users_only retry=3 authtok_type=
	password    sufficient    pam_unix.so sha512 shadow nullok try_first_pass use_authtok
	password    required      pam_deny.so
	
	session     optional      pam_keyinit.so revoke
	session     required      pam_limits.so
	-session     optional      pam_systemd.so
	session     [success=1 default=ignore] pam_succeed_if.so service in crond quiet use_uid
	session     required      pam_unix.so

После изменения:

	[test1@otus ~]$ cat /etc/pam.d/system-auth-ac
	#%PAM-1.0
	# This file is auto-generated.
	# User changes will be destroyed the next time authconfig is run.
	auth        required      pam_env.so
	auth        required      pam_faildelay.so delay=2000000
	auth        sufficient    pam_unix.so nullok try_first_pass
	auth        requisite     pam_succeed_if.so uid >= 1000 quiet_success
	auth        required      pam_deny.so
	
	account     required      pam_unix.so
	account     sufficient    pam_succeed_if.so user ingroup admin
	account     required      pam_time.so
	account     sufficient    pam_localuser.so
	account     sufficient    pam_succeed_if.so uid < 1000 quiet
	account     required      pam_permit.so
	
	password    requisite     pam_pwquality.so try_first_pass local_users_only retry=3 authtok_type=
	password    sufficient    pam_unix.so sha512 shadow nullok try_first_pass use_authtok
	password    required      pam_deny.so
	
	session     optional      pam_keyinit.so revoke
	session     required      pam_limits.so
	-session     optional      pam_systemd.so
	session     [success=1 default=ignore] pam_succeed_if.so service in crond quiet use_uid
	session     required      pam_unix.so

Готово.

В первой добавленной строке проверяется, что пользователь принадлежит к группе admin.  

Если условие выполнено проверка прекращается(по флагу sufficient), если проверка не прошла(user не в группе admin), идет переход на след. правило.

В котором проверяется можно ли пользователю входить во время определенное в /etc/security/time.conf.
