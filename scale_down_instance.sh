#!/bin/bash
	echo "= + = + = + = + = + = ADDING ONE MORE INSTANCE = = + = + = + = + = + ="
	aws autoscaling update-auto-scaling-group --auto-scaling-group-name tbip-staging-render-autoscaling-group --desired-capacity 1 --region us-east-1

