#!/bin/bash
DUMP_DIR=/home/ubuntu/mysqlDump-dir
DATE=$(date +%Y-%m-%d-%H-%M)
DB_NAME1=jiradb
DB_NAME2=confluence
BUCKET_NAME=docker-grails-app/mysql_dump/infradb/
REGION=us-east-1
DB_HOST=localhost
DB_USER=iguser
DB_PASSWD=igdefault
        rm -rf $DUMP_DIR/*
        echo "taking dump of mysql"
        cd $DUMP_DIR
        mysqldump -u${DB_USER} -p${DB_PASSWD} -h$DB_HOST ${DB_NAME1} > mysqldump-${DB_NAME1}-$DATE.sql
        mysqldump -u${DB_USER} -p${DB_PASSWD} -h$DB_HOST ${DB_NAME2} > mysqldump-${DB_NAME2}-$DATE.sql
        tar -cvzf mysqldump-$DATE.tar.gz *.sql
        aws s3 cp mysqldump-$DATE.tar.gz s3://$BUCKET_NAME --region $REGION
        if [ $? == 0 ]
        then
        echo "Dump Sent to S3"
        rm -rf $DUMP_DIR/*
        else
        echo "error in dump sending of infra jira and confluence , Please check and resolve" | sendmail tarun.saxena@tothenew.com
        fi

