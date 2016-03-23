#!/bin/bash
	Date=`date +"%Y-%m-%d-%H-%M"`
	Job_Name=$1
	#Bucket_Name=$2
	cookbook_name=$2
	format=recipe["$cookbook_name"]
	cd /var/lib/jenkins/jobs/$Job_Name/workspace/grails-application/target
	echo `pwd`
	echo "copying to s3"
	#aws s3 cp ROOT.war s3://$Bucket_Name/latest.war --region $Region
	#aws s3 cp s3://$Bucket_Name/latest.war s3://$Bucket_Name/backup/ROOT.$Date.war --region $Region
        cp ROOT.war /home/ubuntu/chef-repo/cookbooks/$cookbook_name/files/default 
	cd /home/ubuntu/chef-repo/cookbooks/$cookbook_name/recipes
	echo "file copied successfully"
	echo "=================================UPLOADING RECIPE ON CHEF SERVER=========================================="
	knife cookbook upload $cookbook_name
	echo "=================================ADDING RECIPE INTO THE RUN LIST OF THE SERVER=========================================="
	knife node run_list add staging-beta-node $format
