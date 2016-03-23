#!/bin/bash
echo "********************************************DETAILS OF YOUR AWS ACCOUNT*******************************************"
region=($(aws ec2 describe-regions --query 'Regions[].RegionName[]' --output text))
for r in "${region[@]}"
do

echo "*********************************************running instances in region $r**************************************** "
aws ec2 describe-instances --region $r --filters "Name=instance-state-name,Values=running" --query 'Reservations[*].Instances[*].[Tags[].Value,InstanceType]' --output text

echo "*********************************************stopped instances in region $r**************************************** "

aws ec2 describe-instances --region $r --filters "Name=instance-state-name,Values=stopped" --query 'Reservations[*].Instances[*].[Tags[].Value,InstanceType]' --output text

echo "*********************************************terminated instances in region $r**************************************** "

aws ec2 describe-instances --region $r --filters "Name=instance-state-name,Values=terminated" --query 'Reservations[*].Instances[*].[Tags[].Value,InstanceType]' --output text

echo "******************************************R E G I O N ------  C H A N G I N G ******************************************"

done

