#setup log server on centos7
sudo yum install epel-release -y
sudo yum install rsyslog -y
sudo systemctl enable rsyslog
sudo systemctl start rsyslog
#sudo sed -i 's/#tcp_listen_port = 60/tcp_listen_port = 60/' /etc/audit/auditd.conf
sudo sed -i '/.*#tcp_listen_port.*/a tcp_listen_port = 60' /etc/audit/auditd.conf
sudo sed -i 's/#$ModLoad imudp/$ModLoad imudp/' /etc/rsyslog.conf
sudo sed -i 's/#$UDPServerRun 514/$UDPServerRun 514/' /etc/rsyslog.conf
sudo sed -i 's/#$ModLoad imtcp/$ModLoad imtcp/' /etc/rsyslog.conf
sudo sed -i 's/#$InputTCPServerRun 514/$InputTCPServerRun 514/' /etc/rsyslog.conf
sudo echo "\$template RemoteLogs,\"/var/log/%HOSTNAME%/%PROGRAMNAME%.log\"" >> /etc/rsyslog.conf
sudo echo "*.* ?RemoteLogs" >> /etc/rsyslog.conf
sudo echo "& ~" >> /etc/rsyslog.conf
sudo service auditd restart
sudo systemctl restart rsyslog
