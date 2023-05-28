yum install nfs-utils nfs-utils-lib autofs -y
mkdir /mnt/mega-shara
mount -t nfs -o vers=3,proto=udp 192.168.50.10:/var/super_shara /mnt/mega-shara
echo "192.168.50.10: /var/super_shara/	/mnt/mega-shara/	nfs	rw,sync,hard,intr	0 0" >>/etc/fstab