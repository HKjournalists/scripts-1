#!/bin/bash
#	inst_ids=($(aws ec2 start-instances --filter Name=tag:Environment,Values=qa --region us-east-1 --query 'Reservations[].Instances[].InstanceId' --output text))
#	for i in "${inst_ids[@]}"
#	do
#		inst_name=($(aws ec2 start-instances --region us-east-1 --instance-ids $i --query 'Reservations[].Instances[].Tags[?Key==`Name`].Value' --output text))
#
#		echo "Starting up instance :- $inst_name"
#		aws ec2 start-instances --instance-ids $i --region us-east-1 
#	done
#	#echo "Druid staging servers started"| /usr/sbin/sendmail -F Thoughtbuzz-Jenkins tarun.saxena@tothenew.com
#	( echo "Subject: Druid Staging Servers Started" ; echo "Druid Staging servers in Virgina have been started up" ) | /usr/sbin/sendmail -F Thoughtbuzz-Jenkins tarun.saxena@tothenew.com
echo "starting cordinator"
aws ec2 start-instances --region us-east-1 --instance-ids i-90b6816f 
sleep 180
echo "starting historical"
aws ec2 start-instances --region us-east-1 --instance-ids  i-68b68197
 
echo "starting broker"
aws ec2 start-instances --region us-east-1 --instance-ids i-91b6816e 

echo "starting overload"
aws ec2 start-instances --region us-east-1 --instance-ids  i-93b6816c 
( echo "Subject: Druid Staging Servers Started" ; echo "Druid Staging servers in Virgina have been started up" ) | /usr/sbin/sendmail -F Thoughtbuzz-Jenkins tarun.saxena@tothenew.com
