yum install nfs-utils nfs-utils-lib -y
mkdir -p /var/super_shara/upload
chown nfsnobody /var/super_shara/upload
sudo systemctl enable rpcbind
sudo systemctl enable nfs-server
sudo  systemctl enable nfs-lock
sudo  systemctl enable nfs-idmap
sudo systemctl start rpcbind
sudo systemctl start nfs-server
sudo systemctl start nfs-lock
sudo systemctl start nfs-idmap
echo "/var/super_shara 192.168.50.11(rw,sync,root_squash,all_squash)" >> /etc/exports
exportfs -a
systemctl start firewalld.service
firewall-cmd --zone=public --add-service=nfs3 --permanent
firewall-cmd --zone=public --add-service=rpc-bind --permanent
firewall-cmd --zone=public --add-service=mountd --permanent
firewall-cmd --reload
