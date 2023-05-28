#!/bin/bash
date_stat=$1
date_date=$(date --date "@${date_stat}" +%d/%b/%Y:%H:%M:%S)
date_end=$(date +%d/%b/%Y:%H:%M:%S)
echo 'Processing start time at: '
echo ${date_date}
echo 'Processing end time: '
echo ${date_end}

while IFS= read -r LINE
do
last_run_time=$(echo $LINE|cut -d ' ' -f4| tr / -| tr -d [|sed 's/:/ /')
date_date=$(date --date "${last_run_time}" +%s)
if ((date_date>date_stat))
then
date_date_a=$(date --date "@${date_date}" +%d/%b/%Y:%H:%M)
string_num=$(grep -n -m 1 "$date_date_a" /root/access.log|cut -d':' -f1)
#echo ${string_num}
#echo ${date_date}
#echo ${date_date_a}
break
fi
done < access.log
echo 'top 10 ip:'
tail -n +${string_num} access.log | awk  '{print $1}'| sort| uniq -c| sort -rn| head -n 25
echo 'top 10 request:'
tail -n +${string_num} access.log | cut -d' ' -f15| egrep "https?://"| cut -d')' -f1| sort -k1| uniq -c| sort -k1| head -n 10
echo 'all errors:'
tail -n +${string_num} access.log | cut -d' ' -f9| sort | uniq -c | sort -r| grep "4[0-9][0-9]"
echo 'all codes:'
tail -n +${string_num} access.log | cut -d' ' -f9| sort | uniq -c | sort -r