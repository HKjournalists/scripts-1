#!/bin/bash
        
       

	
        echo "*********************installing nginx***************************************"
        sudo apt-get update -y
        sudo apt-get install nginx -y
        sudo chmod 777 /etc/nginx/sites-enabled
        sudo chmod 777 /user/share/nginx/html


        echo "************************configuring php5 module******************************"
        sudo apt-get install php5 -y
        sudo apt-get install php5-fpm php5-mysql -y

        echo "************************configuring default.conf for nginx******************** "
        cd /etc/nginx/sites-enabled
        sudo rm default
        wget https://s3.amazonaws.com/aws_us/default


