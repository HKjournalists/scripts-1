#!/bin/bash
		/usr/local/bin/aws ec2 start-instances --instance-ids i-40600ee4 --region ap-southeast-1
	( echo "Subject: Replica Mongo Server Started" ; echo "Replica Mongo Server Started " ) | /usr/sbin/sendmail -F Thoughtbuzz-Jenkins tarun.saxena@tothenew.com
