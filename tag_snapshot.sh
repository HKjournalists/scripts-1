#!/bin/bash

        #capturing snapshot_ids
        snap_id=($(/usr/local/bin/aws ec2 describe-snapshots --owner self --query 'Snapshots[].SnapshotId[]' --region ap-southeast-1 --output text))
                for i in "${snap_id[@]}"
                do
			/usr/local/bin/aws ec2 describe-snapshots --snapshot-ids $i --region ap-southeast-1 | grep "Created by CreateImage"  
			if [ $? == 0 ]
			then
			echo "snapshot by image creation"
                        vol_id=`/usr/local/bin/aws ec2 describe-snapshots --snapshot-ids $i --query 'Snapshots[].VolumeId' --region ap-southeast-1 --output text`
                        keys=($(/usr/local/bin/aws ec2 describe-tags --filters "Name=resource-id,Values=$vol_id" --query 'Tags[].[Key]' --region ap-southeast-1 --output text))

                        for j in "${keys[@]}"
                        do

                        value=`/usr/local/bin/aws ec2 describe-tags --filters "Name=resource-id,Values=$vol_id" "Name=key,Values=$j" --query 'Tags[].Value' --region ap-southeast-1 --output text`
                        echo $value
                        echo "creating tag on $i ,$vol_id, $j , $value "
                       /usr/local/bin/aws ec2 create-tags --resources $i --tags Key=$j,Value=$value --region ap-southeast-1
                        echo $?
                        done
			fi
                done

