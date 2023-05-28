# install and configure nginx on centos7
sudo yum install epel-release -y
sudo yum install nginx -y
sudo yum install rsyslog -y
sudo yum install audispd-plugins.x86_64 -y
sudo systemctl start nginx
sudo systemctl enable nginx
sudo systemctl start rsyslog
sudo systemctl enable rsyslog
sudo auditctl -w /etc/nginx/ -k nginx_watch
sudo auditctl -l >> /etc/audit/rules.d/nginx.rules
sudo sed -i 's/.*access_log.*/access_log syslog:server=192.168.50.11:514 main;/' /etc/nginx/nginx.conf
sudo sed -i 's/.*error_log.*/error_log syslog:server=192.168.50.11:514;/' /etc/nginx/nginx.conf
sudo sed -i '/.*error_log.*/a error_log /var/log/nginx/error.log;' /etc/nginx/nginx.conf
sudo touch /etc/rsyslog.d/err.conf
sudo echo "*.err @@192.168.50.11:514" >> /etc/rsyslog.d/err.conf
sudo touch /etc/rsyslog.d/alert.conf
sudo echo "*.alert @@192.168.50.11:514" >> /etc/rsyslog.d/alert.conf
sudo touch /etc/rsyslog.d/crit.conf
sudo echo "*.crit @@192.168.50.11:514" >> /etc/rsyslog.d/crit.conf
sudo touch /etc/rsyslog.d/warning.conf
sudo echo "*.warning @@192.168.50.11:514" >> /etc/rsyslog.d/warning.conf
sudo touch /etc/rsyslog.d/notice.conf
sudo echo "*.notice @@192.168.50.11:514" >> /etc/rsyslog.d/notice.conf
sudo sed -i 's/active = no/active = yes/' /etc/audisp/plugins.d/au-remote.conf
sudo sed -i 's/remote_server =/remote_server = 192.168.50.11/' /etc/audisp/audisp-remote.conf
sudo sed -i 's/write_logs = yes/write_logs = no/' /etc/audit/auditd.conf
sudo service auditd restart
sudo systemctl restart rsyslog
sudo systemctl restart nginx