#!/bin/bash
#revoking port 22
echo "want to revoke permission of 22 port of a security group (y/n)"
read ch1
while [ $ch1 == 'y' ]
do
echo "list of all security groups is :"
aws ec2 describe-security-groups --query SecurityGroups[*].GroupId
echo "enter a group id to show its permission:"
read grp_id
aws ec2 describe-security-groups --group-ids $grp_id
echo "Do you want to revoke permission for port 22 from this security group(y/n):"
read ch
if [ $ch == 'y' ]
then
echo "revoking port 22 ..Please Wait.."
aws ec2 revoke-security-group-ingress --group-id $grp_id --protocol tcp --port 22 --cidr 0.0.0.0/0
echo "port revoked successfully"
echo "Here are the new permissions:"
aws ec2 describe-security-groups --group-ids $grp_id
echo "Imp Note:If you want to open 22 port use change_port script to open " 
else
echo "Not Revoked!!"
fi
echo "want to continue(y/n)"
read ch1
done

