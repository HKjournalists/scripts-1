#!/bin/bash
	DATE=$(date +%Y-%m-%d-%H:%M)
        vol_id=vol-48eb5fa0
                inst_id=`/usr/local/bin/aws ec2 describe-volumes --volume-ids $vol_id --query 'Volumes[].Attachments[].InstanceId' --region ap-southeast-1 --output text`
		state=`/usr/local/bin/aws ec2 describe-instances --instance-ids $inst_id --region ap-southeast-1 --query 'Reservations[].Instances[].State[].Name' --output text`
		if [ $state = 'running' ]
		then 
                inst_name=`/usr/local/bin/aws ec2 describe-tags --filters "Name=resource-id,Values=$inst_id" "Name=key,Values=Name" --query 'Tags[].Value' --region ap-southeast-1  --output text`
                block=`/usr/local/bin/aws ec2 describe-volumes --volume-ids $vol_id --query 'Volumes[].Attachments[].Device'  --region ap-southeast-1  --output text`
                snapid=`/usr/local/bin/aws ec2 create-snapshot --volume-id $vol_id --query 'SnapshotId' --description  "New Automated-SnapShot-$inst_name-$block-$DATE" --region ap-southeast-1 --output text`
			if [ $? == 0 ]
        		then
				echo $block | grep sda1
                                if [ $? == 0 ]
                                then
					/usr/local/bin/aws ec2 create-tags --resources $snapid --tags Key=Name,Value=$inst_name-root-disk --region ap-southeast-1
                                else
                                        /usr/local/bin/aws ec2 create-tags --resources $snapid --tags Key=Name,Value=$inst_name-mongo-disk --region ap-southeast-1
                                fi
	
			fi
		fi
