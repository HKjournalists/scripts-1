#!/bin/bash
	echo "AMIs created by you are:-"
	aws ec2 describe-images --owners self --query 'Images[].[Name,ImageId]'
	echo "want to delete only specific AMI with snapshot or all?"
        echo "press a.specific AMI"
	echo "press b.all AMIs"
        echo "enter choice(a or b)"
 	read ch
	if [ $ch == 'a' ]
		then 
		echo "enter AMI id"
		read ami_id
		snap_id=`aws ec2 describe-images --image-ids $ami_id --query 'Images[].BlockDeviceMappings[].Ebs[].SnapshotId'`
		echo "first deleting snapshot..Please wait"
		aws ec2 delete-snapshot --snapshot-id $snap_id
		echo "Snapshot deleted...deregistering AMI.."
		aws ec2 deregister-image --image-id $ami_id
		
	elif [ $ch=='b' ]
		then
		echo "want to delete all AMIs.are you sure (y/n)"
		read ch1
			if [ $ch1 == 'y' ]
			then	
				amis=($(aws ec2 describe-images --owners self --query 'Images[].ImageId'))
				for i in "${amis[@]}"
					do 		
				  	snap_id=`aws ec2 describe-images --image-ids $i --query 'Images[].BlockDeviceMappings[].Ebs[].SnapshotId'`
					aws ec2 delete-snapshot --snapshot-id $snap_id					       						      		       aws ec2 deregister-image --image-id $i														      done
			else
			echo "not deleted"	
			fi

	else		
	echo "wrong choice exiting"
	fi		
