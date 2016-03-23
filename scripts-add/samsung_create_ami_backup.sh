#!/bin/bash

REGION=us-east-1
PROFILE=tb-samsung

DATE=$(date +%Y-%m-%d-%H:%M)
DATE1=$(date +%Y-%m-%d)
echo "======================================================D A T E :- $DATE ================================================="
inst=($(/usr/local/bin/aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" "Name=tag:Environment,Values=UAT" --query 'Reservations[*].Instances[*].InstanceId' --output text --region $REGION  --profile $PROFILE))
        for i in "${inst[@]}"
        do
                name=`/usr/local/bin/aws ec2 describe-tags --filters "Name=resource-id,Values=$i" "Name=key,Values=Name" --query 'Tags[].Value'  --output text --region $REGION  --profile $PROFILE`

                img_id=`/usr/local/bin/aws ec2 create-image  --instance-id $i --no-reboot --name "AMI-$name-$DATE1" --description "New_Automated_AMI-$name-$DATE"  --output text --region $REGION  --profile $PROFILE`
               
			if [ $? == 0 ]
        			then
                		echo "success"
		 keys=($(/usr/local/bin/aws ec2 describe-tags --filters "Name=resource-id,Values=$i"  --query 'Tags[].[Key]' --output text --region $REGION  --profile $PROFILE))

		                for j in "${keys[@]}"
                		do

                        value=`/usr/local/bin/aws ec2 describe-tags --filters "Name=resource-id,Values=$i" "Name=key,Values=$j" --query 'Tags[].Value' --output text --region $REGION  --profile $PROFILE`
                        if [ $j == "Name" ]
			then 
                       /usr/local/bin/aws ec2 create-tags --resources $img_id --tags Key=$j,Value="$value-automated-$DATE" --output text --region $REGION  --profile $PROFILE
			else
			/usr/local/bin/aws ec2 create-tags --resources $img_id --tags Key=$j,Value="$value" --output text --region $REGION  --profile $PROFILE
			fi
			
                		done
			else
			echo "AMIs Creation Error !! ....Please Check and Resolve" | /usr/sbin/sendmail -F thoughtbuzz-jenkins tarun.saxena@tothenew.com
			fi

        done
	echo "***********************Job executed successfully*********************************"

	echo "=== = == = = = = = == = = = =Deleting old AMIs 30 days old======================="
	bash /var/lib/jenkins/scripts/samsung_delete_30_days_old_ami.sh 
	if [ $? == 0 ]
	then echo "ran successfully"
	else
	echo "ami deletion script not ran" | /usr/sbin/sendmail tarun.saxena@intelligrape.com
	fi
	#bash /var/lib/jenkins/scripts/tag_snapshot.sh
