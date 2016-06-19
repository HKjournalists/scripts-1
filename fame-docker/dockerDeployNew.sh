#!/bin/bash
ENV_NAME=$1
MODULE=$2
aws s3 cp s3://fameplus-qa-private/tag.txt . --region us-east-1
TAG=`cat tag.txt`
mkdir /home/ubuntu/${MODULE}_logs


function findRunningPorts {
  PORT=`cat /home/ubuntu/apps/${MODULE}| cut -d, -f1`
  NUM=`cat /home/ubuntu/apps/${MODULE}| cut -d, -f2`
}


function bluegreen {
if [ $NUM == 1 ]
          then
                PORT=`expr $PORT + 1`;
                NUM=`expr $NUM + 1`
          elif [ $NUM == 2 ]
          then
                PORT=`expr $PORT - 1`;
                NUM=`expr $NUM - 1`;
          fi
          sudo docker pull tarunsaxena/${ENV_NAME}_${MODULE}:${TAG}
          sudo docker run -itd --name ${MODULE}_${TAG}_${PORT} -p ${PORT}:8080 -v /home/ubuntu/${MODULE}_logs:/var/log/application/ tarunsaxena/${ENV_NAME}_${MODULE}:${TAG}
           if [ $? == 0 ]
           then echo $PORT,$NUM > /home/ubuntu/apps/${MODULE}
           fi
           while true
            do
          STATUS=`curl -s -o /dev/null -w "%{http_code}" localhost:{PORT}/heartbeat`
           if [ ${STATUS} == '200' ]
           then
                OLD_CONTAINER_ID=`sudo docker ps | grep -i ${MODULE} | grep -v ${PORT} | awk -F"    " '{print $1}'`
                echo "========Terminating old contaier========container ID is :- ${OLD_CONTAINER_ID}"   
                sudo docker rm -f ${OLD_CONTAINER_ID}
                   if [ $? == 0 ]
                          then exit 0
                   fi

           fi
           echo "waiting for container to come up"
          sleep 5
            done
}


function removeExistingContainer {

    CONTAINER_ID=`sudo docker ps | grep -i ${MODULE} | grep  ${PORT} | awk -F"    " '{print $1}'`
    if [[ ! -z "${CONTAINER_ID}" ]]; then
    echo "Found a dead container...deleting it"
    sudo docker rm -f ${CONTAINER_ID}
    fi
}


function startingNewContainer {
  echo starting new one ...
                if [ $NUM == 1 ]
                then
                PORT=`expr $PORT + 1`;
                NUM=`expr $NUM + 1`
                elif [ $NUM == 2 ]
                then
                PORT=`expr $PORT - 1`;
                NUM=`expr $NUM - 1`;
          	 fi
    sudo docker pull tarunsaxena/${ENV_NAME}_${MODULE}:${TAG}
    sudo docker run -itd --name ${MODULE}_${TAG}_${PORT} -p ${PORT}:8080 -v /home/ubuntu/${MODULE}_logs:/var/log/application/ tarunsaxena/${ENV_NAME}_${MODULE}:${TAG}
          if [ $? == 0 ]
           then echo $PORT,$NUM > /home/ubuntu/apps/${MODULE}
          fi
          containerHealthCheck
}

function containerHealthCheck {
            while true
            do
              STATUS=`curl -s -o /dev/null -w "%{http_code}" localhost:{PORT}/heartbeat`
              if [ ${STATUS} == '200' ]
              then
                  echo "Application is now Up...Exiting"
                  exit 0
              fi
              echo "waiting for container to come up"
              sleep 5
	    done
}

###########


if [ "$#" -ne 2 ]; then
    echo "Illegal number of parameters"
        exit 1
else
            findRunningPorts
            echo "checking if current app is running or not "
                  STATUS=`curl -s -o /dev/null -w "%{http_code}" localhost:{PORT}/heartbeat`
                   if [ ${STATUS} -ne '200' ]
             then
                        echo "App is not running"
                        echo "Checking if  any dead container of that application exists or not.."

                         CONTAINER_ID=`sudo docker ps | grep -i ${MODULE} | grep  ${PORT} | awk -F"    " '{print $1}'`
                         if [[ ! -z "${CONTAINER_ID}" ]]; then
                                    echo "Found a dead container...deleting it"
                                    removeExistingContainer
                        startingNewContainer
                         fi
                   else
                         echo "Existing active container running, Starting container with latest code"
                   bluegreen
                  fi
fi

############

