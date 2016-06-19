#!/bin/bash

# Need root to run this script
if [ "$(id -u)" != "0" ]
then
        echo "Please run this install script as root."
        echo "Usage: sudo bash logentries_install.sh"
        exit 1
fi

# Check Ubuntu version
if hash lsb_release 2>/dev/null; then
        CODENAME=$(lsb_release -c | sed 's/Codename://' | tr -d '[:space:]')
fi

if [ "$CODENAME" == "UNKNOWN" ]; then
        printf "Unknown distribution, please check if you have ubuntu version installed.\n"
        exit 1
fi

instance=$(ec2metadata |grep -o " i-.*"|sed 's/[ \t]*//g')
availability=$(ec2metadata |grep "availability-zone: "|sed 's/availability-zone: //g')

#eval `aws ec2 describe-instances --region ${availability%%[a,b,c,d,e,f,g]} --instance-ids $instance --query 'Reservations[*].Instances[*].Tags[]' --output text|sed 's/[\t]/=/g'|sed 's/aws:autoscaling:groupName/autoscaling/g'|sed 's/[ \t]*//g'`

i=`aws ec2 describe-instances --region ${availability%%[a,b,c,d,e,f,g]} --instance-ids $instance --query 'Reservations[*].Instances[*].Tags[]' --output text|sed 's/[\t]/=/g'`

for n in $i ; do

env=$(echo $n | awk -F= '{print $1F}')
if [ "$env" == "env" ]
then
Env=$(echo $n | awk -F= '{print $2F}')
fi

if [ "$env" == "Name" ]
then
Name=$(echo $n | awk -F= '{print $2F}')
fi
done


aws s3 cp s3://fameplus-production/configs/logshiper.py /usr/local/sbin/logshiper.py --region ${availability%%[a,b,c,d,e,f,g]}
chmod 755 /usr/local/sbin/logshiper.py

aws s3 cp s3://fameplus-production/configs/logshiper.conf /etc/init/logshiper.conf --region ${availability%%[a,b,c,d,e,f,g]}
initctl reload-configuration

rm /etc/logio.conf

#for n in /home/fame-*; do 
#if [ -z $autoscaling ]; then
#	app=${n##/home/fame-}
#else
#	app=${n##/home/fame-}-${instance:5:5}	
#fi

i=`aws ec2 describe-instances --region ${availability%%[a,b,c,d,e,f,g]} --instance-ids $instance --query 'Reservations[*].Instances[*].Tags[]' --output text|sed 's/[\t]/=/g'`

for n in $i ; do
	
app=$(echo $n | awk -F= '{print $2F}' | awk -F, '{print $1F}')



if [ -d "/var/log/app/${app}_logs" ]; then

for j in /var/log/app/${app}_logs/*.log
do
k=`echo $j | awk -F/ '{print $NF}'`
cat << EOL >> /etc/logio.conf
[${Env}-${app}-${k}]
level = debug
node = ${Name}
host = 172.31.16.100
port = 28777
logfile = /var/log/app/${app}_logs/${k}

EOL

done


#elif [ -f "${n}/logs/jetty.log/spring.log" ]; then
#cat << EOL >> /etc/logio.conf
#[${Env,,}-${app}-ms]
#level = debug
#node = ${Name,,}
#host = 172.31.16.100
#port = 28777
#logfile = ${n}/logs/jetty.log/spring.log
#
#EOL
#
#elif [ -f "${n}/logs/jetty-beam-ms.log" ]; then
#cat << EOL >> /etc/logio.conf
#[${Env,,}-${app}-ms]
#level = debug
#node = ${Name,,}
#host = 172.31.16.100
#port = 28777
#logfile = ${n}/logs/jetty-beam-ms.log
#
#EOL
#
#elif [ -f "${n}/logs/jetty.log" ]; then
#cat << EOL >> /etc/logio.conf
#[${Env,,}-${app}-ms]
#level = debug
#node = ${Name,,}
#host = 172.31.16.100
#port = 28777
#logfile = ${n}/logs/jetty.log
#
#EOL
#else
#
#cat << EOL >> /etc/logio.conf
#[Env-AppName]
#level = debug
#node = ${Name,,}
#host = 172.31.16.100
#port = 28777
#logfile = /logs/jetty.log
#
#EOL
#

fi

done
service logshiper restart
tail /var/log/logshiper.log
echo -e "Please check and modify /etc/logio.conf.\ndo restart after any modification sudo service logshiper restart."
