#!/bin/bash
DUMP_DIR=/home/mongo-backup/mongoDump-dir
DATE=$(date +%Y-%m-%d-%H-%M)
DB_NAME=blogmint_mongo
BUCKET_NAME=com.blogmint.backup/mongobackup
REGION=ap-southeast-1
        rm -rf $DUMP_DIR/*
        echo "taking dump of mongo"
        mongodump --db $DB_NAME -o $DUMP_DIR
        cd $DUMP_DIR
        tar -cvzf mongodump-$DATE.tar.gz $DB_NAME
        aws s3 cp mongodump-$DATE.tar.gz s3://$BUCKET_NAME/ --region $REGION
        if [ $? == 0 ]
        then
        echo "Dump Sent to S3"
        rm -rf $DUMP_DIR/*
        else
        echo "error in dump sending, Please check and resolve"
        fi
