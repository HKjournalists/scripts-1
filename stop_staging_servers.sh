#!/bin/bash
#	inst_ids=($(/usr/local/bin/aws ec2 describe-instances --filter Name=tag:Environment,Values=docker-staging --region us-east-1 --query 'Reservations[].Instances[].InstanceId' --output text))
#	for i in "${inst_ids[@]}"
#	do
#		inst_name=`/usr/local/bin/aws ec2 describe-instances --instance-ids $i --region us-east-1 --query 'Reservations[].Instances[].KeyName[]' --output text`
		echo "Shutting down instance :- $inst_name"
		/usr/local/bin/aws ec2 stop-instances --instance-ids i-7f4979df --region us-east-1 
		/usr/local/bin/aws ec2 stop-instances --instance-ids i-bcc6360c --region us-east-1
#	done
	#echo "staging servers stopped"| /usr/sbin/sendmail -F Thoughtbuzz-jenkins tarun.saxena@tothenew.com
	( echo "Subject: Staging Servers Stopped" ; echo "Staging servers in Virgina have been shut down" ) | /usr/sbin/sendmail -F Thoughtbuzz-Jenkins tarun.saxena@tothenew.com
