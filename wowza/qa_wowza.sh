#!/bin/bash

function createChannel {
URL=$1

for i in  "${@:2}"
        do
        CHANNEL_NAME=$i
	sed -i "s/CHANNEL_NAME/${CHANNEL_NAME}/g" qa_body.json
	curl -X POST --header 'Accept:application/json; charset=utf-8' --header 'Content-type:application/json; charset=utf-8' ${URL}/v2/servers/_defaultServer_/vhosts/_defaultVHost_/applications/${CHANNEL_NAME} --data @qa_body.json
	sed -i "s/${CHANNEL_NAME}/CHANNEL_NAME/g" qa_body.json
	done
}

function deleteChannel {
#CHANNEL_NAME=$1
URL=$1
for i in  "${@:2}"
	do 
	CHANNEL_NAME=$i
	curl -X DELETE --header 'Accept:application/json; charset=utf-8' ${URL}/v2/servers/_defaultServer_/vhosts/_defaultVHost_/applications/${CHANNEL_NAME}
	done
}
#
#
#echo -e "Choices \n 1.Create a channel \n 2.Delete a channel"
#read choice
#	if [ $choice == 1 ]
#	then 
#	echo "creating channel..Enter name of the channels"
#	read channel
#	createChannel $channel
#
#	else
#	echo "deleting channel..Enter name"
#	read channel
#	deleteChannel $channel
#	fi 
