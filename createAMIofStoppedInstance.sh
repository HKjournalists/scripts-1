#!/bin/bash
	inst=($(aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" --query 'Reservations[*].Instances[*].InstanceId[]' --output text))

 for i in "${inst[@]}"
       do
	aws ec2 stop-instances --instance-ids $i
	done
echo "instance stopped"
