#!/bin/bash
set -e

echo "=======================================================AWS Cloudwatch Monitoring Script================================="
echo "========================================================================================================================"


echo "=============================================P R E Q U I S I T E S======================================================"
echo "========================================================================================================================"
echo "1.Run this script from root user or a user with sudo privileges"
echo "2.Make sure you have all the required SNS topics present in the Instance's Region, the script will show you the list of SNS topics available in the region"
echo "3.Make sure you have required Cloudwatch access to configure alarms in the region"
echo "========================================================================================================================"

pause(){
 read -n1 -rsp $'Press any key to continue or Ctrl+C to exit...\n'
}

pause

REGION=`ec2metadata --availability-zone |  rev | cut -c 2- | rev`

AWS_PATH=`which aws`
INST_ID=`ec2metadata --instance-id`

echo "LIST OF SNS TOPICS PRESENT IN  THE REGION : $REGION"
$AWS_PATH sns list-topics --region $REGION --query 'Topics[].TopicArn' --output json
echo "============================================"
echo "Enter the ARN for disk alerts"
read DISK_ARN
echo "============================================"
echo "Enter the ARN for memory"
read MEMORY_ARN
echo "============================================"
echo "Enter the ARN for CPU"
read CPU_ARN
echo "============================================"
echo "Enter the ARN for Network"
read NETWORK_ARN
echo "============================================"
echo "Enter the ARN for Status"
read STATUS_ARN
echo "============================================"
echo "+++++++++++++++++++++++++++++++++++Enter the thresholds for alerts+++++++++++++++++++++++++++++++++++"

read -p "Enter Disk alert threshold(default 80): " DISK_UTILIZATION_THRESHOLD
DISK_UTILIZATION_THRESHOLD=${DISK_UTILIZATION_THRESHOLD:-80}

read -p "Enter Memory alert threshold(default 80): " MEMORY_UTILIZATION_THRESHOLD
MEMORY_UTILIZATION_THRESHOLD=${MEMORY_UTILIZATION_THRESHOLD:-80}

read -p "Enter CPU alert threshold(default 80): " CPU_UTILIZATION_THRESHOLD
CPU_UTILIZATION_THRESHOLD=${CPU_UTILIZATION_THRESHOLD:-80}

read -p "Enter Network in threshold(default 40000000 bytes): " NETWORK_IN_THRESHOLD
NETWORK_IN_THRESHOLD=${NETWORK_IN_THRESHOLD:-40000000}


read -p "Enter Network out threshold(default 50000000 bytes): " NETWORK_OUT_THRESHOLD
NETWORK_OUT_THRESHOLD=${NETWORK_OUT_THRESHOLD:-50000000}



echo "Enter the name of the instance(It will be set your instance's hostname's entry)"
read INSTANCE_NAME
echo $INSTANCE_NAME > /etc/hostname
sudo hostname $INSTANCE_NAME

echo "127.0.0.1  $INSTANCE_NAME" >> /etc/hosts
echo "**************************************Making scripts and Configuring Alarms ************************************************"
echo "****************************************************************************************************************************"

#deleting alarms
#$AWS_PATH cloudwatch delete-alarms --alarm-name CPU_UTILIZATION_Alarm-${INSTANCE_NAME} --region $REGION
#$AWS_PATH cloudwatch delete-alarms --alarm-name DISK_UTILIZATION_Alarm-${INSTANCE_NAME} --region $REGION
#$AWS_PATH cloudwatch delete-alarms --alarm-name MEMORY_UTILZATION_Alarm-${INSTANCE_NAME} --region $REGION
#$AWS_PATH cloudwatch delete-alarms --alarm-name HIGH_NETWROK_IN_Alarm-${INSTANCE_NAME} --region $REGION
#$AWS_PATH cloudwatch delete-alarms --alarm-name HIGH_Network_OUT_Alarm-${INSTANCE_NAME} --region $REGION
#$AWS_PATH cloudwatch delete-alarms --alarm-name STATUS_CHECK_FAILED_Alarm-${INSTANCE_NAME} --region $REGION

#  if [ $? == 0 ] ;
#      then echo "PREVIOUS ALARMS DELETED..."
#	fi;

echo "Detecting number of disks attached to the instance..."
Disks=($(df -h | grep "xvd" | cut -d / -f3 |awk '{print $1}'))
for i in "${Disks[@]}"
do
        echo $i >> /tmp/disks
done



mkdir /home/ubuntu/monitoringScripts
mkdir /home/ubuntu/monitoringScriptlogs
#Disk Utilization Block
cat >>/home/ubuntu/monitoringScripts/DISK-UTILIZATION.sh<<"EOF"
#!/bin/bash
INSTANCE_NAME=`cat /etc/hostname`
INST_ID=`ec2metadata --instance-id`
AWS_PATH=`which aws`
REGION=`ec2metadata --availability-zone |  rev | cut -c 2- | rev`
for i in `cat /tmp/disks `
do
        echo "Setting up disk alarm for the disk ============ $i"
        
PERCENT_USAGE=`df -h | grep ${i} |awk '{print $5}' |awk -F% '{print $1}'`
$AWS_PATH cloudwatch put-metric-data --metric-name "DISK-UTILIZATION-${INSTANCE_NAME}-${i}" --unit Percent --value ${PERCENT_USAGE} --dimensions InstanceId=$INST_ID --namespace System/Linux --region $REGION
  
done

EOF


#Memory utilization block

cat >>/home/ubuntu/monitoringScripts/MEMORY-UTILIZATION.sh<<"EOF"
#!/bin/bash
REGION=`ec2metadata --availability-zone |  rev | cut -c 2- | rev`
AWS_PATH=`which aws`
INSTANCE_NAME=`cat /etc/hostname`
INST_ID=`ec2metadata --instance-id`
USED=`free -m | grep "buffers/cache:" | awk  '{print $3}'`
TOTAL=`free -m | grep Mem | awk  '{print $2}'`
PERCENT_USAGE=`echo "scale=2; $USED/$TOTAL*100" | bc|awk -F. '{print $1}'`

$AWS_PATH cloudwatch put-metric-data --metric-name "MEMORY-UTILIZATION-${INSTANCE_NAME}" --unit Percent --value $PERCENT_USAGE --dimensions InstanceId=$INST_ID --namespace System/Linux --region $REGION
EOF


####################disk alarm
echo "Configuring Disks alarms..."
for i in `cat /tmp/disks`
do

$AWS_PATH cloudwatch put-metric-alarm --alarm-name DISK_UTILIZATION_Alarm-${INSTANCE_NAME}-${i} --alarm-description "Alarm when disk util exceeds 80 percent" --metric-name DISK-UTILIZATION-${INSTANCE_NAME}-${i} --namespace System/Linux --statistic Average --period 300 --threshold ${DISK_UTILIZATION_THRESHOLD} --comparison-operator GreaterThanThreshold  --dimensions  Name=InstanceId,Value=$INST_ID --evaluation-periods 1 --alarm-actions ${DISK_ARN} --unit Percent --region $REGION

echo "DISK_UTILIZATION_Alarm-${INSTANCE_NAME}-${i}" >> /tmp/alarms
done

###################memory alarm
echo "Configuring Memory alarm.."
$AWS_PATH cloudwatch put-metric-alarm --alarm-name MEMORY_UTILZATION_Alarm-${INSTANCE_NAME} --alarm-description "Alarm when memory util exceeds 80 percent" --metric-name MEMORY-UTILIZATION-${INSTANCE_NAME} --namespace System/Linux --statistic Average --period 300 --threshold ${MEMORY_UTILIZATION_THRESHOLD} --comparison-operator GreaterThanThreshold  --dimensions  Name=InstanceId,Value=$INST_ID --evaluation-periods 1 --alarm-actions ${MEMORY_ARN} --unit Percent --region $REGION
echo "MEMORY_UTILZATION_Alarm-${INSTANCE_NAME}" >> /tmp/alarms
	
##################CPU alarm
echo "Configuring CPU alarm.."
$AWS_PATH cloudwatch put-metric-alarm --alarm-name CPU_UTILIZATION_Alarm-${INSTANCE_NAME} --alarm-description "Alarm when CPU exceeds 80 percent" --metric-name CPUUtilization --namespace AWS/EC2 --statistic Average --period 300 --threshold ${CPU_UTILIZATION_THRESHOLD} --comparison-operator GreaterThanThreshold  --dimensions  Name=InstanceId,Value=$INST_ID --evaluation-periods 1 --alarm-actions ${CPU_ARN} --unit Percent --region $REGION
echo "CPU_UTILIZATION_Alarm-${INSTANCE_NAME}" >> /tmp/alarms
##################Status alarm
echo "Configuring status check alarms.."
$AWS_PATH cloudwatch put-metric-alarm --alarm-name STATUS_CHECK_FAILED_Alarm-${INSTANCE_NAME} --metric-name StatusCheckFailed --namespace AWS/EC2 --statistic Maximum --dimensions Name=InstanceId,Value=$INST_ID --unit Count --period 60 --evaluation-periods 1 --threshold 1 --comparison-operator GreaterThanOrEqualToThreshold --alarm-actions ${STATUS_ARN} --region $REGION
echo "STATUS_CHECK_FAILED_Alarm-${INSTANCE_NAME}" >> /tmp/alarms
###################network in alarm
echo "Configuring Network in alarm.."
$AWS_PATH cloudwatch put-metric-alarm --alarm-name HIGH_NETWROK_IN_Alarm-${INSTANCE_NAME} --alarm-description "Network in alarm" --metric-name NetworkIn --namespace  AWS/EC2 --statistic Average --period 300 --threshold ${NETWORK_IN_THRESHOLD} --comparison-operator GreaterThanThreshold  --dimensions  Name=InstanceId,Value=$INST_ID --evaluation-periods 2  --alarm-actions ${NETWORK_ARN} --unit Bytes --region $REGION
echo "HIGH_NETWROK_IN_Alarm-${INSTANCE_NAME}" >> /tmp/alarms
#####################network out alarm
echo "Configuring Network Out alarm.."
$AWS_PATH cloudwatch put-metric-alarm --alarm-name HIGH_Network_OUT_Alarm-${INSTANCE_NAME} --alarm-description "Network Out alarm" --metric-name NetworkOut --namespace  AWS/EC2 --statistic Average --period 300 --threshold ${NETWORK_OUT_THRESHOLD} --comparison-operator GreaterThanThreshold  --dimensions  Name=InstanceId,Value=$INST_ID --evaluation-periods 2  --alarm-actions ${NETWORK_ARN} --unit Bytes --region $REGION
echo "HIGH_Network_OUT_Alarm-${INSTANCE_NAME}" >> /tmp/alarms

echo "Making Cron job entries.."
sudo chmod +x /home/ubuntu/monitoringScripts/*
crontab -l | { cat;echo "SHELL=/bin/sh" ; } | crontab -
crontab -l | { cat;echo "PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin" ; } | crontab -
crontab -l | { cat;echo "*/1 * * * * bash /home/ubuntu/monitoringScripts/DISK-UTILIZATION.sh >> /home/ubuntu/monitoringScriptlogs/disk.log 2>&1" ; } | crontab -
crontab -l | { cat;echo "*/1 * * * * bash /home/ubuntu/monitoringScripts/MEMORY-UTILIZATION.sh >> /home/ubuntu/monitoringScriptlogs/mem.log 2>&1" ; } | crontab -


bash  /home/ubuntu/monitoringScripts/DISK-UTILIZATION.sh >> /home/ubuntu/monitoringScriptlogs/disk.log
bash /home/ubuntu/monitoringScripts/MEMORY-UTILIZATION.sh >> /home/ubuntu/monitoringScriptlogs/mem.log
echo "===============================A L A R M S ==  C O N F I G U R E D == S U C C E S S F U L L Y=============================== "
echo "====================================Following Alarms have been set for the instance========================================="
cat /tmp/alarms
echo "============================================================================================================================="
rm /tmp/alarms
