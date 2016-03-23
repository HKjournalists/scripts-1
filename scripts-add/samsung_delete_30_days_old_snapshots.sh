#!/bin/bash

	REGION=us-east-1
        PROFILE=tb-samsung
        DATE=$(date +%Y-%m-%d-%H:%M)
        echo "* * * * * * * * * * * * * * * * *$DATE* * * * * * * * * * * * * * * * * * * * *****"
	
	snap_ids=($(/usr/local/bin/aws ec2 describe-snapshots --query 'Snapshots[].SnapshotId' --owner self --output text --region $REGION  --profile $PROFILE))
 	
   	d=`date --date="30 days ago" +%s`	


	for i in ${snap_ids[@]};
		do
		creation_dt=`/usr/local/bin/aws ec2 describe-snapshots --snapshot-ids $i --query 'Snapshots[].StartTime' --output text --region $REGION  --profile $PROFILE`
		snap_date_tm_stmp=$(date -d "$creation_dt" +%s)
		if [ $d -ge $snap_date_tm_stmp ]
		then	
			/usr/local/bin/aws ec2 describe-snapshots --snapshot-ids $i --query 'Snapshots[].Description' --output text --region $REGION  --profile $PROFILE | grep Automated
			if [ $? == 0 ]
			then
			/usr/local/bin/aws ec2 describe-snapshots --snapshot-ids $i --query 'Snapshots[].Tags[?Key==`Name`].Value' --output text --region $REGION  --profile $PROFILE
			echo "===========30 days older snapshot-$i--$creation_dt....Deleting snapshot==============="
			/usr/local/bin/aws ec2 delete-snapshot --snapshot-id $i --output text --region $REGION  --profile $PROFILE
			echo $?
			fi
				
		else
			/usr/local/bin/aws ec2 describe-snapshots --snapshot-ids $i --query 'Snapshots[].Tags[?Key==`Name`].Value' --output text --region $REGION  --profile $PROFILE
		
		echo "latest one--$i---$creation_dt"
		fi
	done
	echo "************************************30 days snapshots deleted successfully***********************************"
