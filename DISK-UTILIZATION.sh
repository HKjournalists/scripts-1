#!/bin/bash
AWS_CLI=/usr/bin/aws
INST_ID=`ec2metadata --instance-id`
REGION=ap-southeast-1
DEVICE1=xvda1
#DEVICE2=xvdb
ALERT1=DISK_UTILIZATION-production-<Name>
#ALERT1=DISK_UTILIZATION-production-<Name>
##############--FOR ROOT DISK--################### 
PERCENT_USAGE=`df -h | grep $DEVICE1 |awk '{print $5}' |awk -F% '{print $1}'`
$AWS_CLI cloudwatch put-metric-data --metric-name $ALERT1 --unit Percent --value $PERCENT_USAGE --dimensions InstanceId=$INST_ID --namespace System/Linux --region $REGION
##############--FOR OTHER DISK--################### 
#PERCENT_USAGE1=`df -h | grep $DEVICE2 |awk '{print $5}' |awk -F% '{print $1}'`
#$AWS_CLI cloudwatch put-metric-data --metric-name $ALERT2 --unit Percent --value $PERCENT_USAGE --dimensions InstanceId=$INST_ID --namespace System/Linux --region $REGION
