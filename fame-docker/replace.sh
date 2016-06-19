#!/bin/bash 
if [ "$#" -ne 3 ]; then
    echo "Illegal number of parameters"
	exit 1
else

ENV_NAME=$1
MODULE=$2
TEMPLATE=$3
BUCKET=blank
if [ $ENV_NAME = 'qa' ]
	then
	BUCKET=fameplus-qa-private

elif [ $ENV_NAME = 'production' ]
	then
	BUCKET=fameplus-production

elif [ $ENV_NAME = 'uat' ]
	then
	BUCKET=fameplus-uat-2

elif [ $ENV_NAME = 'load' ]
	then
	BUCKET=fameplus-load
fi

fi
echo "$ENV_NAME ======$BUCKET ======= $MODULE"
sed -i "s/test/${ENV_NAME}/" restartserver.sh
sed -i "s/bucket/${BUCKET}/g" Dockerfile
sed -i "s/module/${MODULE}/g" Dockerfile
sed -i "s/test/${ENV_NAME}/" startUp.sh



####Setting up Application configuration File#######

echo "######EC2METADATA#####" >>appConfig.txt
ec2metadata >> appConfig.txt
echo "" >> appConfig.txt
echo "######JOB PARAMETERS######" >> appConfig.txt
echo "Environment : ${ENV_NAME}" >> appConfig.txt
echo "Module Name : ${MODULE}" >> appConfig.txt
echo "Bucket Name : ${BUCKET}" >> appConfig.txt
echo "Application Type : ${TEMPLATE}" >> appConfig.txt

