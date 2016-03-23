#!/bin/bash
echo "shutting Down tbip-production-mongo-replica for testing purpose in Singapore Region ..Please wait.."
aws ec2 stop-instances --instance-ids i-09f60ead --region ap-southeast-1
( echo "Subject: tbip-production-mongo-replica Stopped" ; echo "tbip-production-mongo-replica for testing purpose in Singapore Region has been stopped" ) | /usr/sbin/sendmail -F Thoughtbuzz-Jenkins tarun.saxena@tothenew.com
