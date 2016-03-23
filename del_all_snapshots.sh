#!/bin/bash
	echo "All your snapshot_Ids are:"
	aws ec2 describe-snapshots  --owner self --query 'Snapshots[].SnapshotId'
	snaps=($(aws ec2 describe-snapshots  --owner self --query 'Snapshots[].SnapshotId'))
	echo "deleting snapshots.."
	for i in "${snaps[@]}"
        do
	aws ec2 delete-snapshot --snapshot-id $i > /dev/null 2>&1
        done
	echo "All the snapshots deleted successfully"
		
