#!/bin/bash
	DATE=$(date +%Y-%m-%d-%H:%M)
	echo "* * * * * * * * * * * * * * * * *$DATE* * * * * * * * * * * * * * * * * * * * *****"
        vol_id=($(/usr/local/bin/aws ec2 describe-volumes --query 'Volumes[].VolumeId' --region us-east-1 --output text))
        for i in "${vol_id[@]}"
        do
                inst_id=`/usr/local/bin/aws ec2 describe-volumes --volume-ids $i --query 'Volumes[].Attachments[].InstanceId' --region us-east-1 --output text`
                inst_name=`/usr/local/bin/aws ec2 describe-tags --filters "Name=resource-id,Values=$inst_id" "Name=key,Values=Name" --query 'Tags[].Value' --region us-east-1  --output text`
                block=`/usr/local/bin/aws ec2 describe-volumes --volume-ids $i --query 'Volumes[].Attachments[].Device'  --region us-east-1  --output text`
                snapid=`/usr/local/bin/aws ec2 create-snapshot --volume-id $i --query 'SnapshotId' --description  "New Automated-SnapShot-$inst_name-$block-$DATE" --region us-east-1 --output text`
                keys=($(/usr/local/bin/aws ec2 describe-tags --filters "Name=resource-id,Values=$inst_id" --query 'Tags[].[Key]' --region us-east-1 --output text))

                for j in "${keys[@]}"
                do

                        value=`/usr/local/bin/aws ec2 describe-tags --filters "Name=resource-id,Values=$inst_id" "Name=key,Values=$j" --query 'Tags[].Value' --region us-east-1 --output text`
                       echo $value
			 /usr/local/bin/aws ec2 create-tags --resources $snapid --tags Key=$j,Value=$value --region us-east-1
                done
        done
        echo "====================================Job executed successfully================================"
	
	echo "= = = = = = = = = = = = = = D E L E T I N G -- 30 D A Y S -- O L D -- S N A P S H O T= = = = = = = = = = = = = = = "
        bash /var/lib/jenkins/scripts/delete_30_days_old_snapshots_TBIP.sh
