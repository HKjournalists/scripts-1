#!/bin/bash
sudo apt-get update  
sudo apt-get install linux-image-generic-lts-trusty -y
curl -sSL https://get.docker.com/ | sh      
sudo usermod -aG docker ubuntu 
echo -ne '\n' | sudo apt-add-repository ppa:bhadauria-nitin/nginxx-lua
sudo apt-get update
sudo apt-get install nginx=1.4.6-1ubuntu3.4-luajit -y
cd /etc/nginx/
sudo apt-get install awscli -y
sudo aws s3 cp s3://fameplus-qa-private/qa-docker/nginx/ssl.tar.gz . --region us-east-1
sudo tar xvzf ssl.tar.gz 
cd /etc/nginx/sites-enabled/
sudo aws s3 cp s3://fameplus-qa-private/qa-docker/nginx/conf/qa-admin.livfame.com . --region us-east-1
cd /home/ubuntu
sudo aws s3 cp s3://fameplus-qa-private/qa-docker/dockerDeploy.sh . --region us-east-1
sudo aws s3 cp s3://fameplus-qa-private/qa-docker/makeAliases.sh . --region us-east-1
sudo aws s3 cp s3://fameplus-qa-private/qa-docker/logshiper.sh . --region us-east-1
sudo chmod +x *.sh
sudo mkdir apps
sudo mkdir old_tags
sudo mkdir -p /var/log/app
