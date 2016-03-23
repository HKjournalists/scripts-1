#!/bin/bash
#	inst_ids=($(/usr/local/bin/aws ec2 describe-instances --filter Name=tag:Environment,Values=docker-staging --region us-east-1 --query 'Reservations[].Instances[].InstanceId' --output text))
#	for i in "${inst_ids[@]}"
#	do
#		inst_name=`/usr/local/bin/aws ec2 describe-instances --instance-ids $i --region us-east-1 --query 'Reservations[].Instances[].KeyName[]' --output text`
#		echo "Starting up instance :- $inst_name"
		/usr/local/bin/aws ec2 start-instances --instance-ids i-bcc6360c --region us-east-1 
#	done

sleep 120


	    /usr/local/bin/aws ec2 start-instances --instance-ids i-7f4979df --region us-east-1





	#echo "staging servers started"| /usr/sbin/sendmail -F Thoughtbuzz-Jenkins tarun.saxena@tothenew.com
	( echo "Subject: Staging Servers Started" ; echo "Staging servers in Virgina have been started up" ) | /usr/sbin/sendmail -F Thoughtbuzz-Jenkins tarun.saxena@tothenew.com
