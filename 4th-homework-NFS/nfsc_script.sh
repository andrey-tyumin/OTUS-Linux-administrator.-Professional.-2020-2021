yum install nfs-utils nfs-utils-lib autofs -y
mkdir /mnt/mega-shara
cat << EOF | sudo tee '/etc/systemd/system/mnt-mega\x2dshara.mount'
[Unit]
Description=Mount NFS share
After=network-online.service
Wants=network-online.service

[Mount]
What=192.168.50.10:/var/super_shara
Where=/mnt/mega-shara
Options=rw,sync,hard,intr
Type=nfs
TimeoutSec=60

[Install]
WantedBy=multi-user.target
EOF
echo 'Defaultvers=3'>>/etc/nfsmount.conf
systemctl daemon-reload
systemctl enable 'mnt-mega\x2dshara.mount'
systemctl start 'mnt-mega\x2dshara.mount'
