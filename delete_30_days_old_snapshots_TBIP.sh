#!/bin/bash
	
	snap_ids=($(/usr/local/bin/aws ec2 describe-snapshots --query 'Snapshots[].SnapshotId' --owner self --region us-east-1 --output text))
 	
   	d=`date --date="30 days ago" +%s`	


	for i in ${snap_ids[@]};
		do
		creation_dt=`/usr/local/bin/aws ec2 describe-snapshots --snapshot-ids $i --query 'Snapshots[].StartTime' --region us-east-1 --output text`
		snap_date_tm_stmp=$(date -d "$creation_dt" +%s)
		if [ $d -ge $snap_date_tm_stmp ]
		then	
			/usr/local/bin/aws ec2 describe-snapshots --snapshot-ids $i --query 'Snapshots[].Description' --region us-east-1 --output text | grep Automated
			if [ $? == 0 ]
			then
			/usr/local/bin/aws ec2 describe-snapshots --snapshot-ids $i --query 'Snapshots[].Tags[?Key==`Name`].Value' --region us-east-1 --output text
			echo "===========30 days older snapshot-$i--$creation_dt....Deleting snapshot==============="
			/usr/local/bin/aws ec2 delete-snapshot --snapshot-id $i --region us-east-1 
			echo $?
			fi
				
		else
			/usr/local/bin/aws ec2 describe-snapshots --snapshot-ids $i --query 'Snapshots[].Tags[?Key==`Name`].Value' --region us-east-1 --output text
		
		echo "latest one--$i---$creation_dt"
		fi
	done
	echo "************************************30 days snapshots deleted successfully***********************************"
