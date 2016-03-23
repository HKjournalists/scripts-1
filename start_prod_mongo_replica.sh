#!/bin/bash
echo "starting up tbip-production-mongo-replica for testing purpose in Singapore Region ..Please wait.."
aws ec2 start-instances --instance-ids i-09f60ead --region ap-southeast-1
( echo "Subject: tbip-production-mongo-replica Started" ; echo "tbip-production-mongo-replica for testing purpose in Singapore Region has been started up" ) | /usr/sbin/sendmail -F Thoughtbuzz-Jenkins tarun.saxena@tothenew.com
