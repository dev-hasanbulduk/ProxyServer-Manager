3proxy > ubuntu 16.0.04

Kurulum öncesi notlar.
a.) sunucu max kaç ip açılır limit hesaplaması > putty > cat /proc/sys/kernel/threads-max > çıkan rakamın yarısı

1.) putty ile sunucuya giriş yap.
2.) nano /root/ipv4.sh diyerek yeni bir dosya aç
3.) scripti kopyala 
4.) putty ekranında sağ click yaparak scripti yapıştır. ctrl+o yapıp kaydet. ctrl+x yapıp çıkış yap.
5.) hangi tip kurulacaksa onu copy edip putty'a sağ click yaparak tetikleyin. 

ipv4 https & http (instagram,twitter,facebook gibi yerlerde kullanabilirsin)
ip izinli > bash /root/ipv4.sh '176.98.43.162' user pass proxy 8000 167.13.13.51
user pass > bash /root/ipv4.sh '176.98.43.162' user pass proxy 8000 1.1.1.1
şifresiz > 


ipv4 socks (oyunlarda kullanabilirsin)
ip izinli > bash /root/ipv4.sh '176.98.43.162' user pass socks 8000 167.13.13.51
user pass > bash /root/ipv4.sh '185.111.244.132' erhan kul12345 socks 8000 1.1.1.1 #örneğin videodaki kurulumu bu kısımdan tetikledim.
şifresiz > bash /root/ipv4.sh '46.16.191.165' user pass socks 8000 '"*"'


6.) kurulum bittikten sonra sunucuya reboot yazıp restart atıyoruz.
7.) sunucu erişimi gelmiş mi diye bakıyoruz putty aracılığı ile.

NjcyMz > proxy config dosyasının adı


Proxy delete
bash /root/delete.sh NjcyMz

ubunt22 kurmak için 
sudo apt-get install build-essential

ubunt22 kurmak için 
sudo apt-get install build-essential
