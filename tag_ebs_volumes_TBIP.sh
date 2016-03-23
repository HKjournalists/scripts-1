#!/bin/bash
	vol_ids=($(aws ec2 describe-volumes --query 'Volumes[].Attachments[].VolumeId'  --region ap-southeast-1 --output text))
	for i in "${vol_ids[@]}"
	do
	inst_id=`aws ec2 describe-volumes --volume-ids $i --query 'Volumes[].Attachments[].InstanceId' --region ap-southeast-1 --output text`
        inst_name=`aws ec2 describe-tags --filters "Name=resource-id,Values=$inst_id" "Name=key,Values=Name" --query 'Tags[].Value' --region ap-southeast-1 --output text`	

	keys=($(aws ec2 describe-tags --filters "Name=resource-id,Values=$inst_id" --query 'Tags[].[Key]' --region ap-southeast-1 --output text))

                for j in "${keys[@]}"
                do

                        value=`aws ec2 describe-tags --filters "Name=resource-id,Values=$inst_id" "Name=key,Values=$j" --query 'Tags[].Value' --region ap-southeast-1 --output text`
                       
                        aws ec2 create-tags --resources $i --tags Key=$j,Value=$value --region ap-southeast-1
			echo $?
			echo "tag created for $i $j $value"
                done
	done
