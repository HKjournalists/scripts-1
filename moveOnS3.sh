#!/bin/bash
	Date=`date +"%Y-%m-%d-%H-%M"`
	Job_Name=$1
	Bucket_Name=$2
	cd /var/lib/jenkins/jobs/$Job_Name/workspace/grails-application/target
	echo `pwd`
	echo "copying to s3"


	aws s3 cp s3://$Bucket_Name/latest.war s3://$Bucket_Name/previous.war --region ap-southeast-1

	aws s3 cp ROOT.war s3://$Bucket_Name/latest.war --region ap-southeast-1
	aws s3 cp s3://$Bucket_Name/latest.war s3://$Bucket_Name/backup/ROOT.$Date.war --region ap-southeast-1
	echo "file copied successfully"

