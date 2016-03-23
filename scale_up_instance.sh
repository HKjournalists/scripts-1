#!/bin/bash
ASG_NAME=tbip-staging-render-autoscaling-group
REGION=us-east-1
	echo "= + = + = + = + = + = ADDING ONE MORE INSTANCE = = + = + = + = + = + ="
	aws autoscaling update-auto-scaling-group --auto-scaling-group-name $ASG_NAME --desired-capacity 2 --region $REGION

