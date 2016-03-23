#!/bin/bash

	echo "Enter Access key"
	read access_key
	echo "Enter Secret key"
	read secret_key
	echo "Enter Region"
	read region
	echo "Configuring AWS CLI...Please Wait.."
	aws configure --profile alarm_check_user << eof
$access_key
$secret_key
$region
json
	
eof
echo -ne '\n' 
	DATE=$(date +%Y-%m-%d-%H:%M)
	echo "Getting information of running instances...."
	inst_ids=($(aws ec2 describe-instances --profile alarm_check_user --filters "Name=instance-state-name,Values=running"  --query 'Reservations[].Instances[].InstanceId[]'  --output text))
	#inst_ids=($(aws ec2 describe-instances --profile alarm_check_user --query 'Reservations[].Instances[].InstanceId[]'  --output text))
	echo "SERVER-NAME" > [$region]alarms_$DATE.csv  #Alarm1,Alarm2,Alarm3,Alarm4,Alarm5,Alarm6,Alarm7,Alarm8,Alarm9,Alarm10" > alarms_$DATE.csv
	echo "Getting Alarms Information in your account... Please Wait.."
	for i in "${inst_ids[@]}"
		do 
			count_ins=`expr $count_ins + 1` 
			unset d
			unset c
			unset m
			unset n
			unset s	
		        unset t
		        count_disk=0
        		count_mem=0
        		count_status=0
        		count_network=0
        		count_thread=0
        		count_cpu=0

			no_of_disk=`aws ec2 describe-instances --instance-ids $i --profile alarm_check_user --query 'Reservations[].Instances[].BlockDeviceMappings[].DeviceName' --output text | wc | awk '{print $2}'`
			name=($(aws ec2 describe-instances --profile alarm_check_user --instance-ids $i --query 'Reservations[].Instances[].Tags[?Key==`Name`].Value' --output text))
			alarms=($(aws cloudwatch describe-alarms --query 'MetricAlarms[]' --profile alarm_check_user --output json | grep -B 10 $i | grep AlarmName | awk -F : '{print $2}' | sed -e 's/"//g'))
			for a in "${alarms[@]}" 
				do 
					alarm_name=`echo $a | awk -F, '{print $1}'`
					metric_name=`aws cloudwatch describe-alarms --alarm-names $alarm_name --profile alarm_check_user --query 'MetricAlarms[].MetricName' --output text`
					echo $metric_name-$a | grep -iq disk
					if [ $? == 0 ] 
					then 
						d=$d,$alarm_name ;
						count_disk=`expr $count_disk + 1` 
					fi
					echo $metric_name-$a | grep -iq mem
                                        if [ $? == 0 ] 
					then 
                                                m=$m$alarm_name,;
						count_mem=`expr $count_mem + 1`
                                        fi 
					echo $metric_name-$a | grep -iq cpu
                                        if [ $? == 0 ]
					then
                                                c=$c$alarm_name, ;
						count_cpu=`expr $count_cpu + 1`				
                                        fi
					echo $metric_name-$a | grep -iq network
                                        if [ $? == 0 ] 
					then
                                                n=$n,$alarm_name ;
						count_network=`expr $count_network + 1`
                                        fi
					echo $metric_name-$a | grep -iq status
                                        if [ $? == 0 ]  
					then
                                                s=$s$alarm_name, ;
						count_status=`expr $count_status + 1`
                                        fi
					echo $metric_name-$a | egrep -iq 'thread|connection|apache|nginx'
                                        if [ $? == 0 ]
                                        then
                                                t=$t$alarm_name, ;
						count_thread=`expr $count_thread + 1`
                                        fi
				done
			no_nil_d=`expr $no_of_disk - $count_disk`
			i=0;
			while [ $i -lt $no_nil_d ]	
				do
					d=$d,NIL
					i=`expr $i + 1`
				done
			 if [[ -z "$m" ]] ; 
				then 
					m=NIL 
			fi	
			if [[ -z "$c" ]] ; 
                               then 
                                      c=NIL
                        fi
			no_nil_nw=`expr 2 - $count_network`
			j=0;	
			while [ $j -lt $no_nil_nw ]
                               do
                                      n=$n,NIL
				      j=`expr $j + 1`	
                                done	
			if [[ -z "$s" ]] ;
                                then
                                       s=NIL
                        fi
			if [[ -z "$t" ]] ;
                                then
                                       t=NIL
                        fi

			echo "" >> [$region]alarms_$DATE.csv
			echo "$count_ins)$name(Disk=$no_of_disk)" >> [$region]alarms_$DATE.csv
			echo ",[DISK-ALARMS]-->$d" >> [$region]alarms_$DATE.csv
			echo ",[MEMORY-ALARMS]-->,$m" >> [$region]alarms_$DATE.csv
			echo ",[CPU-ALARMS]-->,$c" >> [$region]alarms_$DATE.csv
			echo ",[NETWORK-ALARMS]-->$n" >> [$region]alarms_$DATE.csv
			echo ",[STATUS-ALARMS]-->,$s" >> [$region]alarms_$DATE.csv
			echo ",[NGINX/APACHE2-THREADS/CONNECTION-ALARMS]-->,$t" >> [$region]alarms_$DATE.csv
		done
	echo "Alarms Information is successfully saved in the file [$region]alarms_$DATE.csv"
