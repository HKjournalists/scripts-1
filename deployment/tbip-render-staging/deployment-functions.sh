source /var/lib/jenkins/scripts/deployment/tbip-render-staging/aws-functions.sh
source /var/lib/jenkins/scripts/deployment/tbip-render-staging/tbip-staging.config

function backupCurrent(){
        _war_path=$1
        _site=$2
        _deploy_time=$3
        _bucket_backup_folder=$4
        _bucket=$5

        _dest="s3://$_bucket_backup_folder/$_site.$_deploy_time.war"
        _dest_latest="s3://$_bucket/latest.war"
        _dest_previous="s3://$_bucket/previous.war"

        echo "[S3] Backing up existing War file as $_dest_previous"
        echo "aws s3 cp $_dest_latest $_dest_previous"
        aws s3 cp $_dest_latest $_dest_previous --region us-east-1

        echo "[S3] Backing up generated War file as $_dest"
        echo "aws s3 cp $_war_path $_dest"
        aws s3 cp $_war_path $_dest --region us-east-1

        echo "[S3] Backing up generated War file as $_dest_latest"
        echo "aws s3 cp $_dest $_dest_latest"
        aws s3 cp $_dest $_dest_latest --region us-east-1

}

function deleteOldWar(){
        _site=$1
        _war_cleanup_time=$2
        _bucket_backup_folder=$3

        echo "[SHELL]  aws s3 ls s3://$_bucket_backup_folder/$_site.$_war_cleanup_date | awk '{print $4}'"
        _old_war_array=$(aws s3 ls "s3://$_bucket_backup_folder/$_site.$_war_cleanup_date" | awk '{print $4}')

        for _old_war in $_old_war_array;do
                echo "[S3] Deleting OLD WAR file"
                echo "aws s3 rm s3://$_bucket_backup_folder/$_old_war"
                #aws s3 rm s3://$_bucket_backup_folder/$_old_war
        done
                                                                                                                      
}


function warBackup(){
        _deploy_time=$1
        _war_cleanup_time=$2

        echo "[FUNCTION] backupCurrent $WAR_PATH $SITE $_deploy_time $BUCKET_BACKUP_FOLDER $BUCKET"
        backupCurrent $WAR_PATH $SITE $_deploy_time $BUCKET_BACKUP_FOLDER $BUCKET

        #if [ $_war_cleanup_time ];then
        #        echo "[FUNCTION] deleteOldWar  $SITE $_war_cleanup_time $BUCKET_BACKUP_FOLDER"
        #        deleteOldWar $SITE $_war_cleanup_time $BUCKET_BACKUP_FOLDER
        #fi
}

function startDeployment(){
        _group_name=$1
        _load_balancer=$2
        _mult_factor=2

        _min_size=$(getAutoscalingGroupMinSize $_group_name)
        _max_size=$(getAutoscalingGroupMaxSize $_group_name)

        echo "[AWS] Configured min size $_min_size"
        echo "[AWS] Configured max size $_max_size"

        _updated_min_size=$(( _min_size*_mult_factor ))
        _updated_max_size=$(( _max_size*_mult_factor ))

        updateAutoscalingTerminationPolicy $_group_name "OldestInstance"

        updateAutoscalingGroupSizes $_group_name $_updated_min_size $_updated_max_size

        waitForNewInstances $_load_balancer $_group_name $_updated_min_size

        updateAutoscalingGroupSizes $_group_name $_min_size $_max_size

        waitForOldInstancesToDie $_load_balancer $_group_name $_min_size

        echo "[AWS] Instances READY"
}

function printInstancesInfo(){
        _group_name=$1
        _load_balancer=$2
        _region=$3

        _instance_ids=$(getInstanceIDS $_load_balancer $_region | sed ':a;N;$!ba;s/\n/ /g' )
        _servers_ids=($_instance_ids)
        echo "==============================================================================="
        echo "==============================================================================="
        for SERVER in "${_servers_ids[@]}"
                do
                _host=$(getPublicDNS $SERVER)
                if [ $_host ];then
                echo "ssh -i /path/to/pem/file ubuntu@$_host"
                fi
        done
        echo "==============================================================================="
        echo "==============================================================================="
}

