#!/bin/bash
#to open 22 port of any security group 
echo "Want to change ports of security groups..enter y to continue"
read ch1
while [ $ch1 == 'y' ]
do
echo "list of all security groups is :"
aws ec2 describe-security-groups --query SecurityGroups[*].GroupId 
echo "enter a group id to show its permission:"
read grp_id 
aws ec2 describe-security-groups --group-ids $grp_id
echo "Do you want to add port 22 to this security group(y/n):"
read ch
if [ $ch == 'y' ]
then 
echo "opening  port 22 ..Please Wait.."
aws ec2 authorize-security-group-ingress --group-id $grp_id  --protocol tcp --port 22 --cidr 0.0.0.0/0
echo "port opened successfully"
echo "Here are the new permissions:"
aws ec2 describe-security-groups --group-ids $grp_id
echo "Imp Note:-Don't forget to run undo_change script to close this port after use " 
else
echo "Not Changed!!"
fi
echo "want to continue(y/n)"
read ch1
done
