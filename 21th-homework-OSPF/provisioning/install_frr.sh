yum install git autoconf automake libtool make \
  readline-devel texinfo net-snmp-devel groff pkgconfig \
  json-c-devel pam-devel bison flex pytest c-ares-devel \
  python-devel systemd-devel python-sphinx libcap-devel
curl -O https://rpm.frrouting.org/repo/$FRRVER-repo-1-0.el6.noarch.rpm
yum install ./$FRRVER*
yum install frr
