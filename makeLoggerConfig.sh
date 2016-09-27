#!/usr/bin/env bash
#expecting one argument as environment
#To be run as root
ENV=$1
#INST_ID=$(ec2metadata --instance-id)
#INST_NAME=$(aws ec2 describe-instances --instance-ids i-cea3a440  --region ap-southeast-1 --query 'Reservations[].Instances[].Tags[?Key==`Name`].Value' --output text)
INST_NAME="app-public-1"
REGION=`ec2metadata --availability-zone |  rev | cut -c 2- | rev`
if [ $ENV = 'qa' ]; then
  LOGGER_IP="172.31.16.100"
elif [ $ENV = 'uat' ]; then
  LOGGER_IP="172.31.16.100"
elif [ $ENV = 'production' ]; then
  LOGGER_IP="172.31.7.255"
fi

rm /etc/logio.conf

for n in /var/log/app/*;
  do m=`echo $n | awk -F/ '{print $NF}'`;
  o=`echo $m | awk -F_ '{print $1}'`;
  p=${p}-${o};
  echo $p ;
done;

for n in /var/log/app/*;
  do m=`echo $n | awk -F/ '{print $NF}'`;
  echo $m ;
echo -e "[${ENV}-${m}] \n level = debug \n node = ${p} \n host = ${LOGGER_IP} \n port = 28777 \n logfile = /var/log/app/${m}/app.log" >> /etc/logio.conf


  #
  # cat << EOL >>/etc/logio.conf
  # [${ENV}-${m}]
  # level = debug
  # node = ${INST_NAME}
  # host = ${LOGGER_IP}
  # port = 28777
  # logfile = /var/log/app/${m}/app.log
  # EOL
done
