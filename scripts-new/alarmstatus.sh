#!/bin/bash
echo "===========================total running instances are:========================================="
 aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" --query 'Reservations[*].Instances[*].[InstanceId,Tags[].Value]' --output text

tot_instance=($(aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" --query 'Reservations[*].Instances[*].InstanceId[]' --output text))
echo "================================================================================================"
echo "Checking alarm on instances....Please wait.."

arn=`aws sns list-subscriptions --query 'Subscriptions[].TopicArn[]' --output text | awk -F " " '{print $1}'`


if [ `aws cloudwatch describe-alarms --output text | wc -l` == 0 ]

then 
echo "No Alarms configured" 

echo "Creating alarms for all.."


for i in "${tot_instance[@]}"
do
aws cloudwatch put-metric-alarm  --alarm-name cpu_$i --alarm-description "Alarm when CPU exceeds 30 percent_for instance" --metric-name CPUUtilization --namespace AWS/EC2 --statistic Average --period 300 --threshold 30 --comparison-operator GreaterThanThreshold  --dimensions  Name=InstanceId,Value=$i --evaluation-periods 2 --alarm-actions $arn --unit Percent

done
echo "alarms created successfully"

else

 echo "There are some alarms....Checking alarms on instances";

alarm_instance_cpu=($(aws cloudwatch describe-alarms --query 'MetricAlarms[*].Dimensions[].Value[]' --output text))

echo "=========================================================================================================="

echo "total running instances are:-"
for i in "${tot_instance[@]}" 
do echo $i
done
echo "Instances on which CPU alarm is available are:-"
for i in "${alarm_instance_cpu[@]}"
do echo $i
done

diff(){
  awk 'BEGIN{RS=ORS=" "}
       {NR==FNR?a[$0]++:a[$0]--}
       END{for(k in a)if(a[k])print k}' <(echo -n "${!1}") <(echo -n "${!2}")
}
echo "=========================================Instances not having alarms are:====================================="
Array3=($(diff tot_instance[@] alarm_instance_cpu[@]))
echo ${Array3[@]}
echo "==============================================================================================================="
echo "creating alarm on remaining instances...."
for i in "${Array3[@]}"
do
aws cloudwatch put-metric-alarm  --alarm-name cpu_$i --alarm-description "Alarm when CPU exceeds 30 percent" --metric-name CPUUtilization --namespace AWS/EC2 --statistic Average --period 300 --threshold 30 --comparison-operator GreaterThanThreshold  --dimensions  Name=InstanceId,Value=$i --evaluation-periods 2 --alarm-actions $arn --unit Percent
done
echo "alarm created successfully on remaining ones"
fi;

