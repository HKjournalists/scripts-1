#!/bin/bash
AWS_CLI=/usr/bin/aws
INST_ID=`ec2metadata --instance-id`
USED=`free -m | grep Mem | awk  '{print $3}'`
TOTAL=`free -m | grep Mem | awk  '{print $2}'`
PERCENT_USAGE=`echo "scale=2; $USED/$TOTAL*100" | bc|awk -F. '{print $1}'`
REGION=ap-southeast-1
ALERT1=MemoryUtilization-production-instance-<name>

/usr/local/bin/aws cloudwatch put-metric-data --metric-name "$ALERT1" --unit Percent --value $PERCENT_USAGE --dimensions InstanceId=$INST_ID --namespace System/Linux --region $REGION
