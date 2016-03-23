#!/bin/bash

DATE=$(date +%Y-%m-%d-%H-%M)
dump_dir=/root/db_dump
totalApps=`cat /root/db.txt | wc -l`
file="/root/db.txt"
#####The File db.txt contains entries in the format 
### rdsURL dbName username password
### rds72ukvcthbo4zver4l.mysql.rds.aliyuncs.com bootcamp bootcamp igdefault

bucketName="docker-grails-app/mysql_dump/"
mkdir -p $dump_dir/$DATE
new_dir="$dump_dir/$DATE"


for ((i=1;i<=${totalApps};i++))
do
         m=`head -n ${i} $file | tail -1` ;
         rds=`echo $m| awk -F" " '{print $1}'`;
         db=`echo $m| awk -F" " '{print $2}'`;
         uname=`echo $m| awk -F" " '{print $3}'`;
         pswd=`echo $m| awk -F" " '{print $4}'`;
         echo "===************************=====taking backup of application $db=====****************************====="
         sleep 1
         mysqldump -u${uname} -p${pswd}  -h"${rds}" ${db} > ${new_dir}/${db}.sql
done
        sleep 5
        cd $dump_dir
         sudo tar cvzf infraAppsDump-${DATE}.tar.gz ${DATE}/

         aws s3 cp infraAppsDump-${DATE}.tar.gz s3://${bucketName}
        if [ $? == 0 ]
        then
        cd ${dump_dir}
        rm -rf *
        fi
