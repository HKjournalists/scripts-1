#!/bin/bash

DATE=$(date +%Y-%m-%d-%H-%M)
dump_dir=/root/db_dump
totalApps=`cat a.txt | wc -l`
bucketName="s3://docker-grails-app/mysql_dump/"
mkdir -p $dump_dir/$DATE
new_dir="$dump_dir/$DATE"


for ((i=1;i<=${totalApps};i++))
do
	 m=`head -n ${i} ~/a.txt | tail -1` ;
 	 rds=`echo $m| awk -F" " '{print $1}'`; 
 	 db=`echo $m| awk -F" " '{print $2}'`; 
 	 uname=`echo $m| awk -F" " '{print $3}'`; 
 	 pswd=`echo $m| awk -F" " '{print $4}'`; 
	 echo "taking backup of application $db"
	 sleep 1
         mysqldump -u${uname} -p${pswd}  -h"${rds}" ${db} > ${new_dir}/${db}.sql
done
         sudo tar cvzf $new_dir/infraAppsDump-${DATE}.tar.gz $new_dir/
 	 aws s3 cp ${new_dir}/infraAppsDump-${DATE}.tar.gz s3://docker-grails-app/mysql_dump/  
