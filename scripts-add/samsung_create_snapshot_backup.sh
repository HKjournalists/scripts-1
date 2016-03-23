#!/bin/bash
	REGION=us-east-1
	PROFILE=tb-samsung
	DATE=$(date +%Y-%m-%d-%H:%M)
	echo "* * * * * * * * * * * * * * * * *$DATE* * * * * * * * * * * * * * * * * * * * *****"
        #vol_id=($(/usr/local/bin/aws ec2 describe-volumes --query 'Volumes[].VolumeId' --region ap-southeast-1 --output text))
        vol_id=($(/usr/local/bin/aws ec2 describe-volumes --filters "Name=attachment.status, Values=attached" "Name=tag:Environment,Values=UAT" --query 'Volumes[].Attachments[].VolumeId' --output text --region $REGION  --profile $PROFILE))
        for i in "${vol_id[@]}"
        do
                inst_id=`/usr/local/bin/aws ec2 describe-volumes --volume-ids $i --query 'Volumes[].Attachments[].InstanceId' --output text --region $REGION  --profile $PROFILE`
		state=`/usr/local/bin/aws ec2 describe-instances --instance-ids $inst_id  --query 'Reservations[].Instances[].State[].Name' --output text --region $REGION  --profile $PROFILE`
		if [ $state = 'running' ]
		then 
                inst_name=`/usr/local/bin/aws ec2 describe-tags --filters "Name=resource-id,Values=$inst_id" "Name=key,Values=Name" --query 'Tags[].Value' --output text --region $REGION  --profile $PROFILE`
                block=`/usr/local/bin/aws ec2 describe-volumes --volume-ids $i --query 'Volumes[].Attachments[].Device'  --output text --region $REGION  --profile $PROFILE`
                snapid=`/usr/local/bin/aws ec2 create-snapshot --volume-id $i --query 'SnapshotId' --description  "New Automated-SnapShot-$inst_name-$block-$DATE" --output text --region $REGION  --profile $PROFILE`
			if [ $? == 0 ]
				then
                                echo $block | grep sda1
                                if [ $? == 0 ]
                                then
                                        /usr/local/bin/aws ec2 create-tags --resources $snapid --tags Key=Name,Value=$inst_name-root-disk --output text --region $REGION  --profile $PROFILE
                                else
                                        /usr/local/bin/aws ec2 create-tags --resources $snapid --tags Key=Name,Value=$inst_name-mongo-disk --output text --region $REGION  --profile $PROFILE
                                fi
			else
			echo "Snapshots creation error !! ....Please Check and Resolve" | /usr/sbin/sendmail -F THoughtbuzz-Jenkins tarun.saxena@tothenew.com
			fi
		else
		echo "stopped instance $inst_id"
		fi
        done
        echo "====================================Job executed successfully================================"
	
	echo "= = = = = = = = = = = = = = D E L E T I N G -- 30 D A Y S -- O L D -- S N A P S H O T= = = = = = = = = = = = = = = "
        bash /var/lib/jenkins/scripts/samsung_delete_30_days_old_snapshots.sh
