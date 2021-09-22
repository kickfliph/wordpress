#!/bin/bash

apt update
apt upgrade -y
apt-get install nginx
systemctl start nginx
systemctl enable nginx
systemctl status nginx
apt-get install php php-mysql php-fpm php-curl php-gd php-intl php-mbstring php-soap php-xml php-xmlrpc php-zip mariadb-server mariadb-client
systemctl start mariadb

echo "================================================================================================================================"
echo " "

while [[ $valve != 1 ]]
do

read -p  "Please enter a valid hostname: " my_hostname

if [[ ! -z $my_hostname ]] && [[ ! -z `dig +short "$my_hostname"` ]] ; then
       valve=1
fi
done
valve=0


echo "======================================================================================================================================"
echo ""
while [[ $valve != 1 ]]
do

  echo ""
     read -p 'Please enter Data Base Name: ' dbname
  echo ""
     read -p 'Please enter Data Base user name: ' users
  echo ""
     read -s -p 'Please enter password Data Base user: ' shadows
  echo ""

  if [ ! -z "$dbname" ] || [ ! -z "$shadows" ] || [ ! -z "$users" ] ; then
     valve=1
   else
     echo 'Inputs cannot be blank please try again!'
  fi
done
valve=0

mysql -e "CREATE DATABASE ${dbname};"
mysql -e "CREATE USER '${users}'@'localhost' IDENTIFIED BY '${shadows}';"
mysql -e "GRANT ALL ON ${dbname}.* TO '${users}'@'localhost' IDENTIFIED BY '${shadows}' WITH GRANT OPTION;"
mysql -e "FLUSH PRIVILEGES;"

systemctl enable mariadb
systemctl status mariadb
systemctl start php7.4-fpm
systemctl enable php7.4-fpm
systemctl status php7.4-fpm

wget -O /tmp/wordpress.tar.gz https://wordpress.org/latest.tar.gz
tar -xzvf /tmp/wordpress.tar.gz -C /var/www/html
chown -R www-data.www-data /var/www/html/wordpress
chmod -R 755 /var/www/html/wordpress

cp ./wordpress.conf /etc/nginx/sites-available/
sed -i "s/my_domain_name/$my_hostname/g" /etc/nginx/sites-available/wordpress.conf
rm /etc/nginx/sites-enabled/default
rm /etc/nginx/sites-available/default
sed -i "s/my_domain_name/$my_hostname/g" /etc/nginx/sites-available/wordpress.conf
ln -s /etc/nginx/sites-available/wordpress.conf /etc/nginx/sites-enabled/
nginx -t

systemctl reload nginx
echo ""
echo "Please keep secure this information ")
echo "Data base name: " dbname
echo "Data base user: " users 
echo "Data base password: " shadows
