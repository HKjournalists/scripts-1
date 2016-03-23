
function getAutoscalingGroupMinSize(){

  _group_name=$1
  _min_size=$(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names $_group_name | grep -y "\"minsize" | awk '{print $2}' | cut -d "," -f 1)
   echo $_min_size
}

function getAutoscalingGroupMaxSize(){
  _group_name=$1
  _max_size=$(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names $_group_name | grep -y "\"maxsize" | awk '{print $2}' | cut -d "," -f 1)
  echo $_max_size
}


function updateAutoscalingTerminationPolicy(){
        _group_name=$1
        _new_policy=$2
        aws autoscaling update-auto-scaling-group --auto-scaling-group-name $_group_name --termination-policies $_new_policy
        echo "[AWS] Changed termination policy to $_new_policy"
}


function updateAutoscalingGroupSizes() {
        _group_name=$1
        _updated_min_size=$2
        _updated_max_size=$3
        aws autoscaling update-auto-scaling-group --auto-scaling-group-name $_group_name --min-size $_updated_min_size --max-size $_updated_max_size --desired-capacity $_updated_min_size
        echo "[AWS] Updated min size  to $_updated_min_size, max size $_updated_max_size"

}

function getInserviceLoadbalancerInstances(){
        _load_balancer=$1
        _instances=$(aws elb describe-instance-health --load-balancer-name $_load_balancer | grep -y inservice | wc -l)
        echo $_instances
}


function waitForNewInstances(){
        _load_balancer=$1
        _group_name=$2
        _updated_min_size=$3

        echo "[AWS] Waiting for servers to come in action"
        sleep 200
        flag=0
        echo "[AWS] Attempts $flag"

        while true; do
            flag=$(( flag + 1 ))
            _instances=$(getInserviceLoadbalancerInstances $_load_balancer)
            echo "[AWS] Instances in Service $_instances"
            echo "[AWS] Attempts $flag"

            if [ $_instances -eq $_updated_min_size ]; then
                updateAutoscalingTerminationPolicy $_group_name "OldestInstance"
                break
            fi
        sleep 10
        done
}


function waitForOldInstancesToDie(){
        _load_balancer=$1
        _group_name=$2
        _min_size=$3

        echo "[AWS] Waiting for old servers to die"
        flag=0
        while true; do
            flag=$(( flag + 1 ))
            _instances=$(getInserviceLoadbalancerInstances $_load_balancer)
            echo "[AWS] Instances in Service $_instances"
            echo "[AWS] Attempts $flag"

            if [ $_instances -eq $_min_size ] || [ "$flag" -gt 10 ]; then
                updateAutoscalingTerminationPolicy $_group_name "ClosestToNextInstanceHour"
                break
            fi
        sleep 10
        done
}

function getInstanceIDS(){
        local _elb=$1
        local _region=$2
        local _instance_ids=$( aws elb describe-load-balancers --load-balancer-names $_elb --output text | awk '/INSTANCES/{print $2}' )
        echo $_instance_ids
}


function getPublicDNS(){
        _instance_ip="$(aws ec2 describe-instances --instance-ids $1 --output text | awk '/INSTANCES/{print $15}')"
        echo $_instance_ip  
}



