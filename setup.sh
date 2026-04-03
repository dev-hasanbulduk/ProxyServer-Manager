#!/bin/bash
max_ip=`wc -l /root/ip.list | cut -d/ -f1`
count=1
type=proxy #socks
while IFS= read -r line3 <&3 || ((eof3=1))
      !((eof3))
do
        bash /root/ipv4.sh $line3 proxy 4232525252 $type 8000 1.1.1.1 #user pass
		sleep 3
		#bash /root/ipv4.sh $line3 proxy 4232525252 $type 8000 '"*"' #anonim
		#bash /root/ipv4.sh $line3 proxy 4232525252 $type 8000 167.13.13.51 #ip allow
        ((count+=1))
        if [ $count -eq $max_ip ]; then
                exit
        fi
done 3</root/ip.list

#single setup
#ipv4 https & http
#ip allow > bash /root/ipv4.sh '176.98.43.162' proxy 4232525252 proxy 8000 167.13.13.51
#user pass > bash /root/ipv4.sh '176.98.43.162' proxy 4232525252 proxy 8000 1.1.1.1
#Non pass > bash /root/ipv4.sh '95.173.184.83' proxy 4232525252 proxy 8000 '"*"'