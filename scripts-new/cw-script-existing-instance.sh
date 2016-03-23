#!/bin/bash
wget https://s3.amazonaws.com/aws-cloudwatch/downloads/latest/awslogs-agent-setup.py
chmod +x ./awslogs-agent-setup.py
wget https://s3.amazonaws.com/aws_us/cw_conf
sudo ./awslogs-agent-setup.py -n -r us-east-1 -c cw_conf
cd /var/awslogs/etc/
sudo chown ubuntu:ubuntu *
ip=`ec2metadata --public-ipv4`
sudo sed -i 's/server/server_'$ip'/' awslogs.conf
