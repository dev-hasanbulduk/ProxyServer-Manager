#!/bin/bash

for user in $(ls /opt/3proxy/expiration/); do
    # Kullanıcı başlangıç ve bitiş tarihlerini al
    start_date=$(cut -d " " -f 1 /opt/3proxy/expiration/$user)
    current_date=$(date +%Y-%m-%d)
    elapsed_days=$(( ($(date -d $current_date +%s) - $(date -d $start_date +%s)) / 86400 ))
    total_days=$(cut -d " " -f 2 /opt/3proxy/expiration/$user)

    # Süre kontrolü
    if [ "$elapsed_days" -lt "$total_days" ]; then
        echo "Süre devam ediyor. $((total_days - elapsed_days)) gün kaldı"
        bash /opt/3proxy/script_file/${user}-3proxy.sh > /opt/3proxy/cfg_file/${user}.cfg
        /opt/3proxy/src/3proxy /opt/3proxy/cfg_file/${user}.cfg
    else
        echo "Süre bitti. -$((elapsed_days - total_days)) gün geçti. Hesap siliniyor."
        bash /root/delete.sh $user
    fi
done
