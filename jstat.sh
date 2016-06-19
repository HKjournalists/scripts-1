#!/bin/bash
pid=`sudo pgrep -u fame-api java`
DATE=$(date +%Y-%m-%d-%H:%M)
echo "---------" >> /home/ubuntu/api.txt
echo $DATE >> /home/ubuntu/api.txt
sudo su - fame-api -c 'jstat -gc $pid 1000 1' >> /home/ubuntu/api.txt
echo "---------" >> /home/ubuntu/api.txt
