#!/bin/bash
#bash /root/delete.sh user
rm -f /opt/3proxy/*/$1.*
rm -f /opt/3proxy/*/$1-*.*
rm -f /opt/3proxy/*/$1_*.*
rm -f /opt/3proxy/expiration/$1*
pkill -f $1.cfg

if [ -f /opt/3proxy/cfg_file/$1.cfg ]; then
echo {\'status\':0 , \'hata\':\'1\', \'info\':\'başarısız\'}
exit
else
echo {\'status\':1 , \'hata\':\'0\', \'info\':\'başarılı\'}
fi


