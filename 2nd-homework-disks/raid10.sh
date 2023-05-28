#zeroed superblocks
mdadm --zero-superblock --force /dev/sd{b,c,d,e,f,g} >/dev/null

#create raid
echo yes | mdadm--create --verbose /ev/md0 -l 10 -n 6 /dev/sd{b,c,d,e,f,g}

#create mdadm.conf
mkdir /etc/mdadm
echo "DEVICE partitions" > /etc/mdadm/mdadm.conf
mdadm --detail --scan --verbose | awk '/ARRAY/ {print}' >> /etc/mdadm/mdadm.conf

