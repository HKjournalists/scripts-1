#!/bin/bash

    vol_id=($(aws ec2 describe-volumes --query 'Volumes[].Attachments[].VolumeId[]'))
      	
	for i in "${vol_id[@]}"
		do
			inst_id=`aws ec2 describe-volumes --volume-id  $i --query 'Volumes[].Attachments[].InstanceId'`

			name=`aws ec2 describe-instances  --instance-id $inst_id --query 'Reservations[].Instances[].Tags[].Value'`

			snap=`aws ec2 create-snapshot --volume-id $i  | awk '{print $4}'`
		
			aws ec2 create-tags --resources $snap --tags Key=Name,Value=$name 


		done

     echo "snapshot created successfully"
