#!/bin/bash
for user in `\ls /opt/3proxy/expiration/`; do 

A=`cat /opt/3proxy/expiration/$user | cut -d " " -f 1`
B=$(date +%Y-%m-%d)
DATE1=`echo $(( ($(date -d $B +%s) - $(date -d $A +%s)) / 86400 ))`
DATE2=`cat /opt/3proxy/expiration/$user | cut -d " " -f 2`

if [ $DATE1 \< $DATE2 ]; then
echo "sure devam ediyor. $((DATE2-$DATE1)) gun kaldi" 
bash /opt/3proxy/script_file/$user-3proxy.sh > /opt/3proxy/cfg_file/$user.cfg
/opt/3proxy/src/3proxy /opt/3proxy/cfg_file/$user.cfg
else
echo "sure bitti.  -$((DATE1-$DATE2)) gecti" hesap siliniyor
bash /root/delete.sh $user

fi; done


* 1 * * * docker start $(docker container ls -a -q)