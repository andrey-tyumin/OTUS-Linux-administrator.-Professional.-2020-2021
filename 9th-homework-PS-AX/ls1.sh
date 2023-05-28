#!/bin/bash
echo -e "PID\tTTY\tSTAT\tTIME\tCOMMAND"
pid_array=$(ls /proc/|egrep [[:digit:]]|sort -n)
for i in ${pid_array[@]}
do
#echo -e -n "$i\t"
termin='?'
if [ -h /proc/$i/fd/0 ]
then
        if [ -c $(readlink /proc/$i/fd/0) ]
        then
        termi=$(readlink /proc/$i/fd/0)
                if [ $termi != '/dev/null' ]
                then
                termin=$(readlink /proc/$i/fd/0 |cut -c6-10)
                fi
        fi
fi
#echo -e -n "$termin\t"
if [ -f /proc/$i/status ]
then
procstat=$(sed -n '/State/p' /proc/$i/status |cut -d':' -f2 |cut -d'(' -f1 2>/dev/null)
fi
#echo -e -n "$procstat\t"
utime=$(cut -d' ' -f14 /proc/$i/stat 2>/dev/null)
ctime=$(cut -d' ' -f15 /proc/$i/stat 2>/dev/null)
proctime=$((utime+ctime))
proctime_min=$(($proctime/100/60))
proctime_sec=$(($proctime/100%60))
#echo -e -n "$proctime_min:$proctime_sec\t"
if [ -d /proc/$i ]
then
	cmdline_length=$(wc -m /proc/$i/cmdline | cut -d' ' -f1)
	if [ "$cmdline_length" -gt "0" ]
	then
		proccommand=$(tr -d '\0' </proc/$i/cmdline)
	else
		proccommand=$(tr -d '\0' </proc/$i/stat | cut -d' ' -f2)
	fi
fi
#echo -e "$proccommand"
echo -e "$i\t$termin\t$procstat\t$proctime_min:$proctime_sec\t$proccommand"
done