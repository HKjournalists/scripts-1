#!/bin/bash
set -e 
if [ "$#" -ne 1 ]; then
    echo "Illegal number of parameters"
        exit 1
else

REGION=$1
AWS_PATH=`which aws`

for i in `${AWS_PATH} cloudwatch describe-alarms --state-value INSUFFICIENT_DATA --query 'MetricAlarms[].AlarmName' --output text --region ${REGION}` 
do 
	echo ====Deleting Alarm: ${i}==========; 
	${AWS_PATH} cloudwatch delete-alarms --alarm-names "${i}" --region ${REGION}
	if [ $? == 0 ]
	then
	echo ====Deleted Successfully==========
	else
	"Ooops !! Some error occuered!! Exiting.."
	exit 1
	fi
done
fi
