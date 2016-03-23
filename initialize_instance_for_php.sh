#!/bin/bash
pvt_ip=`aws ec2 run-instances --image-id ami-9a562df2 --count 1 --instance-type t2.micro --key-name vpc-pvt --security-groups launch-wizard-2 --user-data file:///home/tarun/php_install.sh --query 'Instances[].PrivateIpAddress[]'`

pub_ip=`aws ec2 describe-instances --filters "Name=private-ip-address ,Values=$pvt_ip" --query 'Reservations[].Instances[].NetworkInterfaces[].Association[].PublicIp[]'`
sudo scp -i /home/tarun/Downloads/vpc-pvt.pem /home/tarun/php_autodeploy.sh ubuntu@$pub_ip://home/ubuntu 
echo "*************************************SCP SUCCESSFUL*********************************************"
echo "************************************************************************************************"
echo "now run ssh and execute the script php_autodeploy which you will find in your home folder "

