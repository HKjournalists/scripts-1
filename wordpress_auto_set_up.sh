#!/bin/bash
echo "*********************Configuring NGINX**********************************************"
echo "*********************Installing nginx**********************************************"
sudo apt-get update
sudo apt-get install nginx -y


echo "*********************Installing Mysql***********************************************"

sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password root'
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password root'
sudo apt-get install mysql-server-5.6 -y
sudo mysql -uroot -proot << eof
create database wordpress;
create user 'test'@'%' identified by 'pass';
grant all on wordpress.* to 'test'@'%';
flush privileges;
eof
 
echo "*********************Configure Wordpress**********************************************"
wget http://wordpress.org/latest.tar.gz
sudo tar -xzvf latest.tar.gz 
sudo cp -r wordpress/* /usr/share/nginx/html
sudo mv /usr/share/nginx/html/wp-config-sample.php /usr/share/nginx/html/wp-config.php
cd /usr/share/nginx/html
sudo rm index.html
sudo sed -i 's/database_name_here/wordpress/' wp-config.php
sudo sed -i 's/username_here/test/' wp-config.php
sudo sed -i 's/password_here/pass/' wp-config.php 
cd /etc/nginx/sites-enabled
sudo rm default
wget https://s3.amazonaws.com/aws_us/default

echo "*********************************configure php*************************************"
sudo apt-get install php5-fpm -y
sudo apt-get install php5-fpm php5-mysql -y 

echo "**********************************restart nginx*************************************"
sudo service nginx restart

