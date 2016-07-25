#!/bin/bash
ENV_NAME=$1
MODULE=$2
TAG=`cat tag.txt`
count=1;
INSTANCE_ID=`ec2metadata --instance-id`
REGION=`ec2metadata --availability-zone |  rev | cut -c 2- | rev`
########################################
if [ "$#" -ne 2 ]; then
    echo "Illegal number of parameters"
        exit 1
else
##########################################
##########################################

######Making Logs directories############

if [ ! -d "/var/log/app/${MODULE}_logs" ]; then
mkdir -p /var/log/app/${MODULE}_logs
fi

if [ ! -d "/home/ubuntu/old_tags" ]; then
mkdir -p /home/ubuntu/old_tags
fi
##########################################
####Finding how many containers of that application are running, Max limit is 2....


#count=`sudo docker ps -a | grep -i "${MODULE}_"  | awk -F'->' '{print $1}'  |awk -F: '{print $NF}'`

##Finding the port on which the application is running####

unset DEAD_CONTAINER_PORT;
CONTAINER_COUNT=`sudo docker ps -a | grep -i "${MODULE}_"  | awk -F'->' '{print $1}'  |awk -F: '{print $NF}'| wc -l`
if [ ${CONTAINER_COUNT} -eq 2 ]
then
	echo "2 Running container of that application found..!!!"
	echo "Checking the status of those  two containers....Please wait..."
	PORT=($(sudo docker ps -a | grep -i "${MODULE}_"  | awk -F'->' '{print $1}'  |awk -F: '{print $NF}'))
	for i in "${PORT[@]}"
	do
		STATUS=`curl -s -o /dev/null -w "%{http_code}" localhost:${i}/heartbeat`
		if [ ${STATUS} -ne '200' ]
                	then
			DEAD_CONTAINER_PORT=${i}
			else
			continue
		fi
	done

		 if [[ -z "$DEAD_CONTAINER_PORT" ]];
                 then
			echo "!!!!TerminateHealthyDockerContainerException !!!!! Both the containers are active..Max Limit of running containers reached.. Deployment can't proceed !!! Please contact the DevOps Team"
		 exit 1
		 else
		 	echo "Terminating unhealthy container which has occupied port :- ${DEAD_CONTAINER_PORT}"
			OLD_CONTAINER_ID=`sudo docker ps -a | grep -i "${MODULE}_" | grep  "${DEAD_CONTAINER_PORT}->8080" | awk -F"    " '{print $1}'`
			OLD_IMAGE_ID=`sudo docker ps -a | grep -i "${MODULE}_" | grep  "${DEAD_CONTAINER_PORT}->8080" | awk -F"        " '{print $2}' | cut -d'"' -f1`
			echo "========Terminating unhealthy container========container ID is :- ${OLD_CONTAINER_ID}"
                          		sudo docker rm -f ${OLD_CONTAINER_ID}
					sudo docker rmi -f ${OLD_IMAGE_ID}



		fi
	fi

########################################################



ALLOC_PORT=`aws ec2 describe-instances --instance-id ${INSTANCE_ID} --query 'Reservations[].Instances[].Tags' --region ${REGION} --output text | grep -i "${MODULE}," | awk -F, '{print $NF}'`
echo "Allocated  port to the application is : ${ALLOC_PORT}"
NUM=0;

#checking the number is even or odd to check first or second application

echo "Checking the port on which the application is running...Please wait.."

PORT=`sudo docker ps -a | grep -i "${MODULE}_"  | awk -F'->' '{print $1}'  |awk -F: '{print $NF}'`
		if [[ -z "$PORT" ]];
		 then
			 echo "No port found...No container is running for this application" ;
			PORT=${ALLOC_PORT}
		else

					if [ $((PORT%2)) -eq 0 ];
					then
					    echo "Even, means first application";
				        NUM=1;
					else
				        echo "Odd, means second application";
				        NUM=2;
					fi
		fi;
####Checking if current application is running or not################
   echo "checking if current app is running or not...please wait "
		sleep 2
	       STATUS=`curl -s -o /dev/null -w "%{http_code}" localhost:${PORT}/heartbeat`
 	        if [ ${STATUS} -ne '200' ]
       		then
	                 echo "App is not running"
	                 echo "Checking if  any dead container of that application exists or not...Please wait."
			 sleep 2
		              	CONTAINER_ID=`sudo docker ps -a| grep -i "${MODULE}_" | grep  ${PORT} | awk -F"    " '{print $1}'`
	                 if [[ ! -z "${CONTAINER_ID}" ]];
		         then
                         		 echo "Found a dead container....${CONTAINER_ID}..deleting it"
					 PREV_TAG=`docker ps -a | grep -i "${MODULE}_" | grep ${PORT} | awk -F"    " '{print $3}' | awk -F: '{print $2}'`
					 OLD_IMAGE_ID=`sudo docker ps -a | grep -i "${MODULE}_" | grep ${PORT} | awk -F"        " '{print $2}' | cut -d'"' -f1`
					 echo ${PREV_TAG} >> /home/ubuntu/old_tags/${MODULE}
		                          sudo docker rm -f ${CONTAINER_ID}
		                          sudo docker rmi -f ${OLD_IMAGE_ID}
                         fi
                   ##########logic for new container
                   	  echo starting new one ...please wait..
			  sleep 2
                          if [ $NUM == 1 ]
                          then
                              PORT=`expr $PORT + 1`;
                              NUM=`expr $NUM + 1`
                              elif [ $NUM == 2 ]
                              then
                              PORT=`expr $PORT - 1`;
                              NUM=`expr $NUM - 1`;
                          fi
                          sudo docker pull ttndfame/${ENV_NAME}_${MODULE}:${TAG}
                          sudo docker run -itd --name ${MODULE}_${TAG}_${PORT} -e ENV_NAME="${ENV_NAME}" -e MODULE="${MODULE}" -p ${PORT}:8080 -v /var/log/app/${MODULE}_logs:/opt/jetty/logs/ ttndfame/${ENV_NAME}_${MODULE}:${TAG}
                          if [ $? == 0 ]
                          then echo "Started new container..Waiting to come up!!"


			  else
		 		echo "!!!!!!!!!!!Deployment Failed!!!!!!"
				exit 1
			fi

                          while true
                          do
                                  STATUS=`curl -s -o /dev/null -w "%{http_code}" localhost:${PORT}/heartbeat`
                                   if [ ${STATUS} == '200' ]
                                    then
				  #    echo $PORT,$NUM > /home/ubuntu/apps/${MODULE}
                                      echo -e " ==========================================\n ||       Application is now up!!        || \n =========================================="
				      echo "Exiting.."
                                      exit 0
                                   fi
				echo "waiting for container to come up..please wait"          ##otherwise waiting for the new container to come up and killing it after it hasn't come up after sometime
                                count=`expr $count + 1`
                                if [ $count -ge 1 ] && [ $count -le 36 ]
                                then
                                sleep 5
                                elif [ $count -ge 37 ] && [ $count -le 75 ]
                                then
                                echo "Increasing sleep time  from 5 seconds to 10 seconds..."
                                sleep 10
                                else
                                echo "!!! Deployment Failed !!!! Killing the container which was coming up....Please wait"           ## finding the details of the current container...
                                        CURRENT_CONTAINER_ID=`sudo docker ps -a | grep -i "${MODULE}_" | grep "${PORT}->8080" | awk -F"    " '{print $1}'`
                                        CURRENT_IMAGE_ID=`sudo docker ps -a | grep -i "${MODULE}_" | grep  "${PORT}->8080" | awk -F"        " '{print $2}' | cut -d'"' -f1`
                                        echo "========Terminating Abandoned container========container ID is :- ${CURRENT_CONTAINER_ID}"
                                        sudo docker rm -f ${CURRENT_CONTAINER_ID}
                                        sudo docker rmi -f ${CURRENT_IMAGE_ID}
					exit 1
				fi
			done
                   ##################################
   	       else
          		   echo "Existing active container running, Starting container with latest code..please wait.."
          	       	  if [ $NUM == 1 ]
          	          then
                       		   PORT=`expr $PORT + 1`;
                          	   NUM=`expr $NUM + 1`
          	           elif [ $NUM == 2 ]
          	       	   then
                          	   PORT=`expr $PORT - 1`;
                         	   NUM=`expr $NUM - 1`;
          	          fi
          		      sudo docker pull ttndfame/${ENV_NAME}_${MODULE}:${TAG}
          		      sudo docker run -itd --name ${MODULE}_${TAG}_${PORT} -e ENV_NAME="${ENV_NAME}" -e MODULE="${MODULE}" -p ${PORT}:8080 -v /var/log/app/${MODULE}_logs:/opt/jetty/logs/ ttndfame/${ENV_NAME}_${MODULE}:${TAG}
                 		if [ $? == 0 ]
                 		then echo "Started new container, waiting to come up"
				 else
                                echo "!!!!!!!!!!!Deployment Failed!!!!!!!!"
                                exit 1
        	                fi

                 		while true
                		do
            			     	STATUS=`curl -s -o /dev/null -w "%{http_code}" localhost:${PORT}/heartbeat`                   ##if new container is now up then kill the previously running container
                 		 if [ ${STATUS} == '200' ]
                 		 then
                         		 OLD_CONTAINER_ID=`sudo docker ps -a | grep -i "${MODULE}_" | grep -v "${PORT}->8080" | awk -F"    " '{print $1}'`
					OLD_IMAGE_ID=`sudo docker ps -a | grep -i "${MODULE}_" | grep -v "${PORT}->8080" | awk -F"        " '{print $2}' | cut -d'"' -f1`
					PREV_TAG=`sudo docker ps -a  | grep -i "${MODULE}_" | grep -v "${PORT}->8080" | awk -F"    " '{print $3}' | awk -F: '{print $2}'`
					 echo ${PREV_TAG} >> /home/ubuntu/old_tags/${MODULE}

                          		echo "========Terminating old contaier========container ID is :- ${OLD_CONTAINER_ID}"
                          		sudo docker rm -f ${OLD_CONTAINER_ID}
					sudo docker rmi -f ${OLD_IMAGE_ID}
					echo -e " ==========================================\n ||       Application is now up!!        || \n =========================================="
				#	echo $PORT,$NUM > /home/ubuntu/apps/${MODULE}
					echo "Exiting...!!"
					exit 0


                 		 fi
                 		 echo "waiting for container to come up..please wait"          ##otherwise waiting for the new container to come up and killing it after it hasn't come up after sometime
                		count=`expr $count + 1`
                 		if [ $count -ge 1 ] && [ $count -le 36 ]
				then
                 		sleep 5
                 		elif [ $count -ge 37 ] && [ $count -le 75 ]
				then
				echo "Increasing sleep time  from 5 seconds to 10 seconds..."
				sleep 10
                 		else
				echo "!!! Deployment Failed !!!! Killing the container which was coming up....Please wait"           ## finding the details of the current container...
               				CURRENT_CONTAINER_ID=`sudo docker ps -a | grep -i "${MODULE}_" | grep "${PORT}->8080" | awk -F"    " '{print $1}'`
                                        CURRENT_IMAGE_ID=`sudo docker ps -a | grep -i "${MODULE}_" | grep  "${PORT}->8080" | awk -F"        " '{print $2}' | cut -d'"' -f1`
                                        echo "========Terminating Abandoned container========container ID is :- ${CURRENT_CONTAINER_ID}"
                                        sudo docker rm -f ${CURRENT_CONTAINER_ID}
                                        sudo docker rmi -f ${CURRENT_IMAGE_ID}
					exit 1
                 		fi
				done
fi
fi
