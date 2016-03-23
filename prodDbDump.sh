#!/bin/bash
set -e
DATE=$(date +%Y-%m-%d-%H-%M)
application_name=$1
dump_dir=/root/db_dump
RDS_reviewer=rds35t08822tqkt2thsj.mysql.rds.aliyuncs.com
RDS_infra=rds72ukvcthbo4zver4l.mysql.rds.aliyuncs.com

if [ $application_name == "reviewer" ]; 
then echo "reviewer application"

mysqldump -ureviewer -pigdefault  -h"${RDS_reviewer}" $application_name > ${dump_dir}/${application_name}_$DATE.sql
aws s3 cp ${dump_dir}/${application_name}_$DATE.sql s3://docker-grails-app/mysql_dump/  --acl public-read-write


elif [ $application_name == "ehour" ]; 
then echo "reviewer application"

mysqldump -uroot -prootroot  -h"${RDS_reviewer}" eHour > ${dump_dir}/${application_name}_$DATE.sql
aws s3 cp ${dump_dir}/${application_name}_$DATE.sql s3://docker-grails-app/mysql_dump/  --acl public-read-write

elif [ $application_name == "hrms" ];
then echo "hrms application"

mysqldump -uhrms -pigdefault  -h"${RDS_reviewer}" $application_name > ${dump_dir}/${application_name}_$DATE.sql
aws s3 cp ${dump_dir}/${application_name}_$DATE.sql s3://docker-grails-app/mysql_dump/  --acl public-read-write


elif [ $application_name == "cafeteria" ];
then echo "cafeteria application"

mysqldump -ucafeteria -pigdefault  -h"${RDS_infra}" ims > ${dump_dir}/${application_name}_$DATE.sql
aws s3 cp ${dump_dir}/${application_name}_$DATE.sql s3://docker-grails-app/mysql_dump/  --acl public-read-write
elif [ $application_name == "rms_prod" ];
then echo "rms application"

mysqldump -urms -pigdefault  -h"${RDS_infra}" $application_name > ${dump_dir}/${application_name}_$DATE.sql
aws s3 cp ${dump_dir}/${application_name}_$DATE.sql s3://docker-grails-app/mysql_dump/  --acl public-read-write

else 
echo "$application_name applications"

mysqldump -u"${application_name}" -pigdefault  -h"${RDS_infra}" $application_name > ${dump_dir}/${application_name}_$DATE.sql
aws s3 cp ${dump_dir}/${application_name}_$DATE.sql s3://docker-grails-app/mysql_dump/  --acl public-read-write

fi
link="https://s3.amazonaws.com/docker-grails-app/mysql_dump/${application_name}_$DATE.sql"
echo "wget link is :- $link "
