#!/usr/bin/env bash
REGION="ap-southeast-1"
DB_UNAME="fame"
DB_PASSWD="famedefault"
DB_HOST="db.livfame.com"
DB_NAME="famePlus_prod"
DATE=$(date +%F)
AWS=`which aws`
export MYSQL_PWD=$DB_PASSWD
export STATUS=0
# Send Mail
function sendAlert() {
        alert="$1"
        echo -e "Subject: ALERT !! Wowza Autoscaling Event ${alert}\n Wowza Autoscaling Alert :-  ${alert}, Please take an action, Immediately !! ." \
        | /usr/sbin/sendmail -F Wowza_Autoscaling_Alert tarun.saxena@tothenew.com,anup.yadav@tothenew.com
      }
      # mohit.gupta@tothenew.com,nitin.bhadauria@tothenew.com,fameplus@intelligrape.pagerduty.com

function calculateAvailableChannels() {
              export AVAILABLE_CHANNELS=$(mysql -u$DB_UNAME -h$DB_HOST $DB_NAME -e 'select count(*) from wowza_channel where is_active=true;' | tail -n1)
      }


function calculateLiveBeams() {
        export LIVE_BEAM=$(mysql -u$DB_UNAME -h$DB_HOST $DB_NAME -e 'select count(w.name) from event e inner join wowza_channel w on e.live_now_wowza_channel_id = w.id where e.status = "ON_AIR";' | tail -n1)
      }

# function isWowzaRunning() {
#          instance-id="$1"
#          instance_name=`aws ec2 describe-tags --filters "Name=resource-id,Values=${instance-id}" "Name=key,Values=Name" --query 'Tags[].Value' --region $REGION --output text
#          if [ `$AWS ec2 describe-instances --instance-id ${instance-id} --region $REGION --query 'Reservations[].Instances[].State[].Name' --output text` == "running" ] ;
#          then
#              echo "instance is running" ;
#              export STATUS=1
#          else
#              echo "instance is stopped"
#          fi
#       }

function countWowzaServerRunningAWS() {
          for i in {i-99323517,i-563235d8,i-5b3235d5,i-ee323560,i-ef323561} ;
                do echo "checking if instance $i is running or not" ;
                export COUNT=0
                if [ `$AWS ec2 describe-instances --instance-id $i --region $REGION --query 'Reservations[].Instances[].State[].Name' --output text` == "running" ] ;
                then
                    echo "instance is running" ;
                    COUNT = `expr $count + 1`
                else
                    echo "instance is stopped" ;
                fi
          done  ;
          echo $COUNT
          if [[ $COUNT == 0 ]]; then
            sendAlert "No Wowza Server Running"
          fi
          }

calculateLiveBeams
calculateAvailableChannels
countWowzaServerRunningAWS
#condition of single wowza server running
if [ $LIVE_BEAM -lt 4 ] && [ $COUNT == 1 ] && [ $AVAILABLE_CHANNELS == 7 ]; then
      echo "ALL OK"
else
       sendAlert "Live Beam Count: $LIVE_BEAM,  Wowza Server Running: $COUNT, Available Channels in DB: $AVAILABLE_CHANNELS"
fi


#condition of 2 wowza server running
if [ $LIVE_BEAM -ge 4 ] && [ $LIVE_BEAM -lt 11 ] && [ $COUNT == 2 ] && [ $AVAILABLE_CHANNELS == 14 ]; then
      echo "All OK"
else
      sendAlert "Live Beam Count: $LIVE_BEAM,  Wowza Server Running: $COUNT, Available Channels in DB: $AVAILABLE_CHANNELS"
fi

#condition of 3 wowza server running
if [ $LIVE_BEAM -ge 11 ] && [ $LIVE_BEAM -lt 18 ] && [ $COUNT == 3 ] && [ $AVAILABLE_CHANNELS == 21 ]; then
      echo "All OK"
else
      sendAlert "Live Beam Count: $LIVE_BEAM,  Wowza Server Running: $COUNT, Available Channels in DB: $AVAILABLE_CHANNELS"
fi

#condition of 4 wowza server running
if [ $LIVE_BEAM -ge 18 ] && [ $LIVE_BEAM -lt 25 ] && [ $COUNT == 4 ] && [ $AVAILABLE_CHANNELS == 28 ]; then
      echo "All OK"
else
      sendAlert "Live Beam Count: $LIVE_BEAM,  Wowza Server Running: $COUNT, Available Channels in DB: $AVAILABLE_CHANNELS"
fi

#condition of 5 wowza server running
if [ $LIVE_BEAM -ge 25 ] && [ $LIVE_BEAM -lt 32 ] && [ $COUNT == 5 ] && [ $AVAILABLE_CHANNELS == 35 ]; then
      echo "All OK"
else
      sendAlert "Live Beam Count: $LIVE_BEAM,  Wowza Server Running: $COUNT, Available Channels in DB: $AVAILABLE_CHANNELS"
fi





  #statements

  #statements
