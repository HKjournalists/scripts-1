#!/bin/bash
set -e
source /var/lib/jenkins/scripts/deployment/tbip-render-staging/aws.config
source /var/lib/jenkins/scripts/deployment/tbip-render-staging/tbip-staging.config
source /var/lib/jenkins/scripts/deployment/tbip-render-staging/deployment-functions.sh


_deploy_time=`date +%Y%m%d-%H%M`
_war_cleanup_date=`date --date="$WAR_PERIOD" +%Y%m`
_deploy_parameter=$1
_deploy_branch=$2

_file_name=`ls -tr /var/lib/jenkins/jobs/tbip-staging-render-autoscaling-zerodowntime/workspace/grails-application/target/*.war | tail -1`
echo $_file_name

cp $_file_name $WAR_PATH

warBackup $_deploy_time $_war_cleanup_date

startDeployment $ASG $LB_NAME

printInstancesInfo  $ASG $LB_NAME $REGION
