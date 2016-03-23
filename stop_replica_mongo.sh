#!/bin/bash
		/usr/local/bin/aws ec2 stop-instances --instance-ids i-40600ee4 --region ap-southeast-1
	( echo "Subject: Replica Mongo Server Stopped" ; echo "Replica Mongo Server Stopped " ) | /usr/sbin/sendmail -F Thoughtbuzz-Jenkins tarun.saxena@tothenew.com
