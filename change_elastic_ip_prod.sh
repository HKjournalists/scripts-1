#!/bin/bash
	ass_id=`aws ec2 describe-addresses --filters "Name=public-ip,Values=54.169.197.229" --region ap-southeast-1 --query 'Addresses[].AssociationId' --output text`
	aws ec2 disassociate-address --association-id $ass_id  --region ap-southeast-1
	newly_launched_inst=`aws autoscaling describe-scaling-activities --auto-scaling-group-name tbip-production-render-autoscaling-group --region ap-southeast-1 | grep Launching | awk -F : '{print $3}' | head -n1 | awk -F\" '{print $1}'`
	alloc_id=`aws ec2 describe-addresses --public-ips 54.169.197.229 --region ap-southeast-1 --query 'Addresses[].AllocationId' --output text`
	aws ec2 associate-address --instance-id $newly_launched_inst --allocation-id $alloc_id  --region ap-southeast-1
