#!/bin/bash
	DATE=$(date +%Y-%m-%d-%H:%M)
	echo "* * * * * * * * * * * * * * * * *$DATE* * * * * * * * * * * * * * * * * * * * *****"
        #vol_id=($(/usr/local/bin/aws ec2 describe-volumes --query 'Volumes[].VolumeId' --region ap-southeast-1 --output text))
        vol_id=($(/usr/local/bin/aws ec2 describe-volumes --filters "Name=attachment.status, Values=attached" --query 'Volumes[].Attachments[].VolumeId' --output text --region ap-southeast-1 --output text))
        for i in "${vol_id[@]}"
        do
                inst_id=`/usr/local/bin/aws ec2 describe-volumes --volume-ids $i --query 'Volumes[].Attachments[].InstanceId' --region ap-southeast-1 --output text`
		state=`/usr/local/bin/aws ec2 describe-instances --instance-ids $inst_id --region ap-southeast-1 --query 'Reservations[].Instances[].State[].Name' --output text`
		if [ $state = 'running' ]
		then 
                inst_name=`/usr/local/bin/aws ec2 describe-tags --filters "Name=resource-id,Values=$inst_id" "Name=key,Values=Name" --query 'Tags[].Value' --region ap-southeast-1  --output text`
                block=`/usr/local/bin/aws ec2 describe-volumes --volume-ids $i --query 'Volumes[].Attachments[].Device'  --region ap-southeast-1  --output text`
                snapid=`/usr/local/bin/aws ec2 create-snapshot --volume-id $i --query 'SnapshotId' --description  "New Automated-SnapShot-$inst_name-$block-$DATE" --region ap-southeast-1 --output text`
			if [ $? == 0 ]
				then
                                echo $block | grep sda1
                                if [ $? == 0 ]
                                then
                                        /usr/local/bin/aws ec2 create-tags --resources $snapid --tags Key=Name,Value=$inst_name-root-disk --region ap-southeast-1
                                else
                                        /usr/local/bin/aws ec2 create-tags --resources $snapid --tags Key=Name,Value=$inst_name-mongo-disk --region ap-southeast-1
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
        bash /var/lib/jenkins/scripts/delete_30_days_old_snapshots.sh
