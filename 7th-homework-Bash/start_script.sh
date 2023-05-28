#!/bin/bash
date_stat=$(stat --format=%X fucking_sript.sh)
/usr/bin/flock -w 600 /var/tmp/fucking_sript.lock /root/fucking_sript.sh $date_stat | mail -s "access.log report" post@post.com