#!/bin/bash
a=($(ls -l -I "lost+found" /var/log/app/  | awk -F" " '{print $NF}'))
for i in ${a[@]}; 
do echo "alias ${i}_logs='tail -F /var/log/app/${i}/app.log'" >> ~/.bashrc
 done;
