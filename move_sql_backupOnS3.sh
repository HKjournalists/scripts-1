##!/bin/bash 	
#	dt=`date -d "$d" +%Y-%m-%d`
#	cd /home/ubuntu/dbsql_backup_thoughtbuzz_word	
#	sql_file=`ls | grep $dt`
#        sudo /usr/local/bin/aws s3 cp $sql_file s3://com.thoughtbuzz.mysqldb.backup --region ap-southeast-1
#	if [ $? == 0 ]
#	then 
#	sudo rm /home/ubuntu/dbsql_backup_thoughtbuzz_word/*
#	else	
#	echo "IF case not worked properly (emptying the folder case)"
#	#echo "sqlDump_thoughtbuzz db_word not sent to s3 from jenkins" | /usr/sbin/sendmail -F Thoughtbuzz-Jenkins tarun.saxena@intelligrape.com
#	( echo "Subject: Sql_dump_thoughtbuzz_db sending failed" ; echo "Thoughtbuzz_db_dump failed and not sent to s3 ...Urgent !! ....Please Check and Resolve") | /usr/sbin/sendmail -F Thoughtbuzz-Jenkins tarun.saxena@tothenew.com
#	fi 
