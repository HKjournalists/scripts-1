#!/bin/bash
DUMP_DIR=/home/mongo-backup/mysqlDump-dir
DATE=$(date +%Y-%m-%d-%H-%M)
DB_NAME=blogmint123
BUCKET_NAME=com.blogmint.backup/mysqlbackup
REGION=ap-southeast-1
DB_HOST=rds9hug4sh2zqd8iy8to.mysql.rds.aliyuncs.com
        rm -rf $DUMP_DIR/*
        echo "taking dump of mysql"
        cd $DUMP_DIR
        mysqldump -ublogmint -pbl0Gm1nt_9 -h$DB_HOST blogmint123 > mysqldump-$DATE.sql
        tar -cvzf mysqldump-$DATE.tar.gz mysqldump-$DATE.sql
        aws s3 cp mysqldump-$DATE.tar.gz s3://$BUCKET_NAME/ --region $REGION
        if [ $? == 0 ]
        then
        echo "Dump Sent to S3"
        rm -rf $DUMP_DIR/*
        else
        echo "error in dump sending, Please check and resolve"
        fi
