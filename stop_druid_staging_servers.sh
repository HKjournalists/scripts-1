#!/bin/bash
	inst_ids=($(aws ec2 describe-instances --filter Name=tag:Environment,Values=qa --region us-east-1 --query 'Reservations[].Instances[].InstanceId' --output text))
	for i in "${inst_ids[@]}"
	do
		inst_name=($(aws ec2 describe-instances --region us-east-1 --instance-ids $i --query 'Reservations[].Instances[].Tags[?Key==`Name`].Value' --output text))

		echo "Shuting down instance :- $inst_name"
		aws ec2 stop-instances --instance-ids $i --region us-east-1 
	done
#	echo "Druid staging servers stopped"| /usr/sbin/sendmail -F Thoughtbuzz-Jenkins tarun.saxena@tothenew.com
	( echo "Subject: Druid Staging Servers Stopped" ; echo "Druid Staging servers in Virgina have been shut down" ) | /usr/sbin/sendmail -F Thoughtbuzz-Jenkins tarun.saxena@tothenew.com
