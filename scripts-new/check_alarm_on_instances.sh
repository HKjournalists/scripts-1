#!/bin/bash
	sudo rm details.text
	echo "Here is the list of alarms on your instances:" >>details.text
	aws cloudwatch describe-alarms --query 'MetricAlarms[*].[MetricName,Dimensions[].Value]' >> details.text
	ids=($(aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" --query 'Reservations[*].Instances[*].InstanceId[*]'))
	echo "*********************************************************************************************">>details.text
	echo "Termination detection details on your instances:" >>details.text
 	for i in "${ids[@]}"
		do
		echo $i: >> details.text
		aws ec2 describe-instance-attribute --instance-id $i --attribute disableApiTermination | awk '{print $2}' >> details.text
	
		done
	
	cat details.text | mail -s "details" "tarun.saxena@intelligrape.com"
