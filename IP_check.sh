#!/bin/bash
	echo "enter your Public IP:"
	read ip

	echo "Checking this file exist in ssh config or not..."
	grep -q $ip /etc/ssh/ssh_config
		if [ $? == 0 ]
			then
			echo "exist"
			grep -B1 "HostName" /etc/ssh/ssh_config	
		else
			echo "doesnt exist..Want to create alias for this IP"
			echo "enter your choice (y/n)"
			read ch 
			echo "enter Host:"
			read host
			echo "enter path of identity file (PEM)"
			read path
			echo "Updating ssh config file ..please wait...."
			echo "Host   $host" >> /etc/ssh/ssh_config
			echo "HostName  $ip" >> /etc/ssh/ssh_config
			echo "IdentityFile  $path" >> /etc/ssh/ssh_config
			echo "User  ubuntu" >> /etc/ssh/ssh_config
			echo "File Updated Successfully"
		fi  
