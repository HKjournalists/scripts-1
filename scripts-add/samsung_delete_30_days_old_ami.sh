#!/bin/bash
	REGION=us-east-1
        PROFILE=tb-samsung
        DATE=$(date +%Y-%m-%d-%H:%M)
        echo "* * * * * * * * * * * * * * * * *$DATE* * * * * * * * * * * * * * * * * * * * *****"

		img_id=($(/usr/local/bin/aws ec2 describe-images  --owner self  --query 'Images[].ImageId' --output text --region $REGION  --profile $PROFILE))
        d=`date --date="30 days ago" +%s`
        for i in "${img_id[@]}"
        do
                ami_date=`/usr/local/bin/aws ec2 describe-images  --image-id  $i --query 'Images[].CreationDate' --output text --region $REGION  --profile $PROFILE`
                ami_date_tm_stmp=$(date -d "$ami_date" +%s)
                if [ $d -ge $ami_date_tm_stmp ]
                then
   		/usr/local/bin/aws ec2 describe-images --image-id $i --query 'Images[].Tags[?Key==`Name`].Value' --output text --region $REGION  --profile $PROFILE | grep automated
			if [ $? == 0 ]
			then	 
		                echo "automated ami more than 30 days ago...deregistering the ami"
                		/usr/local/bin/aws ec2 deregister-image --image-id $i --output text --region $REGION  --profile $PROFILE
			fi
                echo "==============================================================="
                else
                /usr/local/bin/aws ec2 describe-images  --image-id  $i --query 'Images[].Name' --output text --region $REGION  --profile $PROFILE
                echo "created within 30 days"
                echo "==============================================================="
                fi
        done

