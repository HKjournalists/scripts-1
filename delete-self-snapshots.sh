#!/bin/bash
	echo "AMIs created by you are:-"
        aws ec2 describe-images --owners self --query 'Images[].[Name,ImageId]'

	echo "want to delete all AMIs.are you sure (y/n)"
              
	read ch1
	if [ $ch1 == 'y' ]
                        then
                                amis=($(aws ec2 describe-images --owners self --query 'Images[].ImageId'))
                                for i in "${amis[@]}"
                                        do
                                        snap_id=`aws ec2 describe-images --image-ids $i --query 'Images[].BlockDeviceMappings[].Ebs[].SnapshotId'` > /dev/null 2>&1
      					aws ec2 deregister-image --image-id $i > /dev/null 2>&1                                                        
					echo "deregistering image..."
					aws ec2 delete-snapshot --snapshot-id $snap_id > /dev/null 2>&1
					echo "deleting snapshots.."
				done
			else
                        
			echo "AMIs not deleted..AMIs are safe"      
       
	 fi

