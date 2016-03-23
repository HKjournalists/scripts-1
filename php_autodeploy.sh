#!/bin/bash
	
	
	


	echo "3 modules of php are available in my nginx"
	echo "press 1 for phpmyinfo page"
	echo "press 2 for phptest"
	echo "press 3 for myfirstphp"
	echo "enter your choice:"
	read ch
	
	
    		case $ch in
        		"1")
            		echo "deploying phpmyinfo page on nginx..Please wait"
			cd /usr/share/nginx/html
			sudo rm * 
			wget https://s3.amazonaws.com/aws_us/a/index.php
			sudo service nginx restart
			echo "deployment successful"
            		;;
        		"2")
            		 echo "deploying phptest page on nginx..please wait"
                        cd /usr/share/nginx/html
                        sudo rm *
                        wget https://s3.amazonaws.com/aws_us/b/index.php
                        sudo service nginx restart
			 echo "deployment successful"
			;;
        		"3")
            		echo "deploying myfistphp page on nginx..please wait"
                        cd /usr/share/nginx/html
                        sudo rm *
                        wget https://s3.amazonaws.com/aws_us/b/index.php
                        sudo service nginx restart
                         echo "deployment successful"

            		;;
                      	*) echo invalid option;;
    		esac
		
