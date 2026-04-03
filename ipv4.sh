#!/bin/bash

ulimit -n 655360

IP_STATIC=$1
MAXIP=2
MAXIP_OTHER=1
USER=$2
PASS=$3
TYPE=$4
CFG_USER=`date +%s | sha256sum | base64 | head -c 6 ; echo`
IP_ALLOW=$6
EXPIRATION=$7

mkdir -p /var/log/3proxyipv4/
chmod 0777 /var/log/3proxyipv4/

if [ $TYPE == 'proxy' ]; then
PROXY_PORT=$5
else
PROXY_PORT=$5
fi

echo 'nameserver 8.8.8.8' > /etc/resolv.conf
echo 'nameserver 8.8.4.4' >> /etc/resolv.conf

echo 'deb http://us.archive.ubuntu.com/ubuntu/ xenial main restricted' > /etc/apt/sources.list
echo 'deb http://us.archive.ubuntu.com/ubuntu/ xenial-updates main restricted' >> /etc/apt/sources.list
echo 'deb http://us.archive.ubuntu.com/ubuntu/ xenial universe' >> /etc/apt/sources.list
echo 'deb http://us.archive.ubuntu.com/ubuntu/ xenial-updates universe' >> /etc/apt/sources.list
echo 'deb http://us.archive.ubuntu.com/ubuntu/ xenial multiverse' >> /etc/apt/sources.list
echo 'deb http://us.archive.ubuntu.com/ubuntu/ xenial-updates multiverse' >> /etc/apt/sources.list
echo 'deb http://us.archive.ubuntu.com/ubuntu/ xenial-backports main restricted universe multiverse' >> /etc/apt/sources.list
echo 'deb http://security.ubuntu.com/ubuntu xenial-security main restricted' >> /etc/apt/sources.list
echo 'deb http://security.ubuntu.com/ubuntu xenial-security universe' >> /etc/apt/sources.list
echo 'deb http://security.ubuntu.com/ubuntu xenial-security multiverse' >> /etc/apt/sources.list


IP=`/sbin/ifconfig|grep inet|head -1|sed 's/\:/ /'|awk '{print $3}' | grep -v '127.0.0.1'`
ETH=`ip -o link show | awk -F': ' '{print $2}' | grep -v "lo" | grep -v "eth1"| grep -v "eno2"`

ip addr add $IP_STATIC dev $ETH
echo "ip addr add $IP_STATIC dev $ETH" >> /usr/src/ip_add.list

if [ -d /opt/3proxy ]; then

if [ -f /opt/3proxy/cfg_file/$CFG_USER.cfg ]; then
echo {\'status\':0 , \'hata\':\'1\', \'info\':\'başarısız\:cfgçakışması\'}
exit
else
echo ""
fi

PORT_CHECK=`grep "$IP_STATIC" /opt/3proxy/cfg_file/*.cfg | grep "$PROXY_PORT" | wc -l`
if [ "$PORT_CHECK" == "0" ]; then
echo ""
else
echo {\'status\':0 , \'hata\':\'1\', \'info\':\'başarısız\:portçakışması\'}
exit
fi


rm -f /opt/3proxy/script_file/$CFG_USER-3proxy.sh
rm -f /opt/3proxy/script_file/$CFG_USER-gen-64.sh
rm -f /opt/3proxy/ip_file/$CFG_USER-ip.list
rm -f /opt/3proxy/cfg_file/$CFG_USER.cfg

cat > /opt/3proxy/script_file/$CFG_USER-pass-gen.sh << END
#!/usr/local/bin/bash
rm -f /opt/3proxy/network_add/"$CFG_USER"_ip.list
array=( 1 2 3 4 5 6 7 8 9 0 a b c d e f )
MAXCOUNT=$MAXIP
count=1
rnd_ip_block ()
{
    a=\${array[\$RANDOM%16]}\${array[\$RANDOM%16]}\${array[\$RANDOM%16]}\${array[\$RANDOM%16]}
    b=\${array[\$RANDOM%16]}\${array[\$RANDOM%16]}\${array[\$RANDOM%16]}\${array[\$RANDOM%16]}
    c=\${array[\$RANDOM%16]}\${array[\$RANDOM%16]}\${array[\$RANDOM%16]}\${array[\$RANDOM%16]}
    d=\${array[\$RANDOM%16]}\${array[\$RANDOM%16]}\${array[\$RANDOM%16]}\${array[\$RANDOM%16]}
        echo $USER:CL:$PASS >> /opt/3proxy/other_file/"$CFG_USER"_user_pass.list
        echo $USER >> /opt/3proxy/other_file/"$CFG_USER"_user.list
        echo $PASS >> /opt/3proxy/other_file/"$CFG_USER"_pass.list
}
while [ "\$count" -le \$MAXCOUNT ]
do
        rnd_ip_block
        let "count += 1"
        done
END

bash /opt/3proxy/script_file/$CFG_USER-pass-gen.sh
echo $IP_STATIC|sed 's/, /\n/g' > /opt/3proxy/ip_file/$CFG_USER-ip.list

rm -f /opt/3proxy/other_file/"$CFG_USER"_proxy.list
cat > /opt/3proxy/script_file/$CFG_USER-3proxy.sh << END
#!/bin/bash
echo daemon
echo maxconn 100000
echo nscache 65536
echo timeouts 1 5 30 60 180 1800 15 60
echo setgid 65535
echo setuid 65535
echo log /var/log/3proxyipv4/3proxy.log D
echo rotate 30
echo flush
port=$PORT_START
count=1
while IFS= read -r line3 <&3 || ((eof3=1))
      IFS= read -r line4 <&4 || ((eof4=1))
      IFS= read -r line5 <&5 || ((eof5=1))
      !((eof3 & eof4 & eof5))
do
                echo users \$line4:CL:\$line5
                echo auth strong iponly
                echo allow \$line4
				echo allow "*" $IP_ALLOW
                echo "$TYPE -s0 -n -a1 -p$PROXY_PORT -i\$line3 -e\$line3"
                echo flush
                echo ""
                echo \$line3:$PROXY_PORT:\$line4:\$line5 >> /opt/3proxy/user_info/"$CFG_USER"_proxy.list
				echo "\$(date +%Y-%m-%d) $EXPIRATION $CFG_USER" > /opt/3proxy/expiration/$CFG_USER
        ((port+=1))
        ((count+=1))
        if [ \$count -eq $MAXIP ]; then
                exit
        fi
done 3</opt/3proxy/ip_file/$CFG_USER-ip.list 4</opt/3proxy/other_file/"$CFG_USER"_user.list 5</opt/3proxy/other_file/"$CFG_USER"_pass.list
END


ulimit -n 655360
echo $BANLIST > /opt/3proxy/banlist/$CFG_USER.list
bash /opt/3proxy/script_file/$CFG_USER-3proxy.sh > /opt/3proxy/cfg_file/$CFG_USER.cfg
/opt/3proxy/src/3proxy /opt/3proxy/cfg_file/$CFG_USER.cfg
while IFS= read -r line3 <&3 || ((eof3=1))
      !((eof3 ))
do
		echo {\'status\':\'1\' , \'hata\':\'0\', \'info\':\'başarıyla oluşturuldu\', \'snc\': \'$line3:$CFG_USER\'}
        ((port+=1))
        ((count+=1))
        if [ $count -eq $MAXIP_OTHER ]; then
                exit
        fi
done 3</opt/3proxy/user_info/"$CFG_USER"_proxy.list
else
apt-get update
apt-get -y install iproute2 gcc g++ git make bc pwgen conntrack libnet-rawip-perl libnet-pcap-perl libnetpacket-perl libarchive-extract-perl libnet-ssleay-perl
apt install bind9 -y && systemctl enable bind9 && systemctl start bind9
cd /opt/3proxy/other_file/ && git clone https://github.com/rghose/kill-close-wait-connections
mv /opt/3proxy/other_file/kill-close-wait-connections/kill_close_wait_connections.pl /opt/3proxy/other_file/kill_close_wait_connections.pl

cat >> /etc/systemd/system/killconnections.service << END
[Unit]
Description=Kill Close Wait Connections
After=network.target
[Service]
ExecStart=/opt/3proxy/other_file/kill_close_wait_connections.pl
Restart=always
RestartSec=3
[Install]
WantedBy=multi-user.target
END

chmod 0777 /etc/systemd/system/killconnections.service
chmod 0777 /opt/3proxy/other_file/kill_close_wait_connections.pl
#systemctl enable killconnections.service
#systemctl start killconnections.service

cat >> /etc/sysctl.conf << END
net.ipv6.ip_nonlocal_bind = 1
END


cat >> /etc/security/limits.conf << END
opt hard nofile 250000
opt soft nofile 500000
nobody hard nofile 250000
nobody soft nofile 500000
* hard nofile 250000
* soft nofile 500000
opt hard nproc 655360
opt soft nproc 655360
nobody hard nproc 655360
nobody soft nproc 655360
* hard nproc 655360
* soft nproc 655360
END
sysctl -p

cd /opt
wget --no-check-certificate https://github.com/z3APA3A/3proxy/archive/0.8.10.tar.gz
tar xzf 0.8.10.tar.gz
mv /opt/3proxy-0.8.10 /opt/3proxy
cd /opt/3proxy
make -f Makefile.Linux
mkdir -p /opt/3proxy/cfg_file/ /opt/3proxy/ip_file/ /opt/3proxy/script_file/ /opt/3proxy/expiration \
/opt/3proxy/user_info/ /opt/3proxy/other_file/ /opt/3proxy/refresh/ /opt/3proxy/network_add/ /opt/3proxy/banlist/

cat > /opt/3proxy/script_file/$CFG_USER-pass-gen.sh << END
#!/usr/local/bin/bash
rm -f /opt/3proxy/network_add/"$CFG_USER"_ip.list
array=( 1 2 3 4 5 6 7 8 9 0 a b c d e f )
MAXCOUNT=$MAXIP
count=1
rnd_ip_block ()
{
    a=\${array[\$RANDOM%16]}\${array[\$RANDOM%16]}\${array[\$RANDOM%16]}\${array[\$RANDOM%16]}
    b=\${array[\$RANDOM%16]}\${array[\$RANDOM%16]}\${array[\$RANDOM%16]}\${array[\$RANDOM%16]}
    c=\${array[\$RANDOM%16]}\${array[\$RANDOM%16]}\${array[\$RANDOM%16]}\${array[\$RANDOM%16]}
    d=\${array[\$RANDOM%16]}\${array[\$RANDOM%16]}\${array[\$RANDOM%16]}\${array[\$RANDOM%16]}
        echo $USER:CL:$PASS >> /opt/3proxy/other_file/"$CFG_USER"_user_pass.list
        echo $USER >> /opt/3proxy/other_file/"$CFG_USER"_user.list
        echo $PASS >> /opt/3proxy/other_file/"$CFG_USER"_pass.list
}
while [ "\$count" -le \$MAXCOUNT ]
do
        rnd_ip_block
        let "count += 1"
        done
END

bash /opt/3proxy/script_file/$CFG_USER-pass-gen.sh
echo $IP_STATIC|sed 's/, /\n/g' > /opt/3proxy/ip_file/$CFG_USER-ip.list

cat > /etc/rc.local << END
#!/bin/bash
ulimit -n 655360
ulimit -u 655360
echo 600000 > /proc/sys/vm/max_map_count
echo 200000 > /proc/sys/kernel/pid_max
for i in /opt/3proxy/cfg_file/*.cfg; do ""/opt/3proxy/src/3proxy \$i""; done
bash /usr/src/ip_add.list
END

rm -f /opt/3proxy/other_file/"$CFG_USER"_proxy.list

cat > /opt/3proxy/script_file/$CFG_USER-3proxy.sh << END
#!/bin/bash
echo daemon
echo maxconn 100000
echo nscache 65536
echo timeouts 1 5 30 60 180 1800 15 60
echo setgid 65535
echo setuid 65535
echo log /var/log/3proxyipv4/3proxy.log D
echo rotate 30
echo flush
port=$PORT_START
count=1
while IFS= read -r line3 <&3 || ((eof3=1))
      IFS= read -r line4 <&4 || ((eof4=1))
      IFS= read -r line5 <&5 || ((eof5=1))
      !((eof3 & eof4 & eof5))
do
                echo users \$line4:CL:\$line5
                echo auth strong iponly
                echo allow \$line4
				echo allow "*" $IP_ALLOW
                echo "$TYPE -s0 -n -a1 -p$PROXY_PORT -i\$line3 -e\$line3"
                echo flush
                echo ""
                echo \$line3:$PROXY_PORT:\$line4:\$line5 >> /opt/3proxy/user_info/"$CFG_USER"_proxy.list
				echo "\$(date +%Y-%m-%d) $EXPIRATION $CFG_USER" > /opt/3proxy/expiration/$CFG_USER
        ((port+=1))
        ((count+=1))
        if [ \$count -eq $MAXIP ]; then
                exit
        fi
done 3</opt/3proxy/ip_file/$CFG_USER-ip.list 4</opt/3proxy/other_file/"$CFG_USER"_user.list 5</opt/3proxy/other_file/"$CFG_USER"_pass.list
END


ulimit -n 655360
echo $BANLIST > /opt/3proxy/banlist/$CFG_USER.list
bash /opt/3proxy/script_file/$CFG_USER-3proxy.sh > /opt/3proxy/cfg_file/$CFG_USER.cfg
/opt/3proxy/src/3proxy /opt/3proxy/cfg_file/$CFG_USER.cfg

echo 'nf_conntrack' >> /etc/modules
echo 'nf_conntrack_ipv4' >>  /etc/modules
echo 'fs.file-max = 700000' >> /etc/sysctl.conf
echo 'net.ipv4.tcp_timestamps=1' >> /etc/sysctl.conf
echo 'net.ipv4.tcp_max_tw_buckets=1440000' >> /etc/sysctl.conf
echo 'net.ipv4.ip_local_port_range = 512 65535' >> /etc/sysctl.conf
echo 'net.core.somaxconn = 61440' >> /etc/sysctl.conf
echo 'net.core.rmem_max = 12582912' >> /etc/sysctl.conf
echo 'net.core.wmem_default = 31457280' >> /etc/sysctl.conf
echo 'net.core.wmem_max = 12582912' >> /etc/sysctl.conf
echo 'net.ipv4.tcp_keepalive_time = 300' >> /etc/sysctl.conf
echo 'net.ipv4.tcp_keepalive_probes = 5' >> /etc/sysctl.conf
echo 'net.ipv4.tcp_keepalive_intvl = 15' >> /etc/sysctl.conf
echo 'net.ipv4.tcp_fin_timeout = 15' >> /etc/sysctl.conf
echo 'net.ipv4.tcp_rfc1337 = 1' >> /etc/sysctl.conf
echo 'net.core.optmem_max = 25165824' >> /etc/sysctl.conf
echo 'net.ipv4.tcp_mem = 65536 131072 262144' >> /etc/sysctl.conf
echo 'net.ipv4.udp_mem = 65536 131072 262144' >> /etc/sysctl.conf
echo 'net.ipv4.tcp_rmem = 8192 87380 16777216' >> /etc/sysctl.conf
echo 'net.ipv4.udp_rmem_min = 66384' >> /etc/sysctl.conf
echo 'net.ipv4.tcp_wmem = 8192 65536 16777216' >> /etc/sysctl.conf
echo 'net.ipv4.udp_wmem_min = 76384' >> /etc/sysctl.conf
echo 'net.ipv4.xfrm4_gc_thresh = 52768' >> /etc/sysctl.conf
echo 'kernel.threads-max = 220000' >> /etc/sysctl.conf
echo 'kernel.pid_max = 200000' >> /etc/sysctl.conf

sysctl -p

echo 'UserTasksMax=100000' >> /etc/systemd/logind.conf
echo 'DefaultTasksMax=100000' >> /etc/systemd/system.conf

echo '*       soft    nofile    655360' >> /etc/security/limits.d/90-nproc.conf
echo '*       hard    nofile    655360' >> /etc/security/limits.d/90-nproc.conf
echo '*       soft    nproc     655360' >> /etc/security/limits.d/90-nproc.conf
echo '*       hard    nproc     655360' >> /etc/security/limits.d/90-nproc.conf

echo 'root       soft    nofile    655360' >> /etc/security/limits.d/90-nproc.conf
echo 'root       hard    nofile    655360' >> /etc/security/limits.d/90-nproc.conf
echo 'root       soft    nproc     655360' >> /etc/security/limits.d/90-nproc.conf
echo 'root       hard    nproc     655360' >> /etc/security/limits.d/90-nproc.conf

rm -f /opt/0.8.10.tar.gz
rm -f /opt/3proxy/other_file/kill_close_wait_connections.pl
while IFS= read -r line3 <&3 || ((eof3=1))
      !((eof3 ))
do
		echo {\'status\':\'1\' , \'hata\':\'0\', \'info\':\'başarıyla oluşturuldu\', \'snc\': \'$line3:$CFG_USER\',}
        ((port+=1))
        ((count+=1))
        if [ $count -eq $MAXIP_OTHER ]; then
                exit
        fi
done 3</opt/3proxy/user_info/"$CFG_USER"_proxy.list
echo > /opt/3proxy/cfg_file/sakinsilme.cfg
fi

chown root:crontab /var/spool/cron/crontabs/root
chmod +x /etc/rc.local


#(crontab -l; echo "* * * * * bash /root/expiration.sh";) | crontab -

#https://gettraffic.pro/setup-proxies-vps-3proxy/
#reboot


