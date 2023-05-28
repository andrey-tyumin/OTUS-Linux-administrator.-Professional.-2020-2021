yum install nfs-utils nfs-utils-lib autofs -y
mkdir /mnt/mega-shara
echo "/mnt	/etc/auto.mega	--timeout=180">>/etc/auto.master
touch /etc/auto.mega
echo "mega-shara	-fstype=nfs,rw,soft,intr	192.168.50.10:/var/super_shara/">>/etc/auto.mega
service autofs restart
