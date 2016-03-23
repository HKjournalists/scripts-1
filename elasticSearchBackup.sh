#!/bin/bash
BACKUP_DIR=/data/backup
OUTPUT_DIR=/home/elastic-search-backup/backup
BUCKET_NAME=com.blogmint.backup/elasticsearch-backup
cd $OUTPUT_DIR
DATE=$(date +%Y-%m-%d-%H-%M)
curl -XPUT "localhost:9200/_snapshot/backup/snapshot_$DATE?wait_for_completion=true"
tar -cvzf elasticsearce_bkup_$DATE.tar.gz $BACKUP_DIR
/usr/bin/aws s3 cp elasticsearce_bkup_$DATE.tar.gz s3://$BUCKET_NAME/
rm elasticsearce_bkup_$DATE.tar.gz
rm -rf $BACKUP_DIR/*
#rm -rf $BACKUP_DIR/*i
