#!/bin/bash
URL="http://qa-wowzain.livfame.com:8087"

function createChannel {
CHANNEL_NAME=$1
sed -i "s/CHANNEL_NAME/${CHANNEL_NAME}/g" body.json
curl -X POST --header 'Accept:application/json; charset=utf-8' --header 'Content-type:application/json; charset=utf-8' ${URL}/v2/servers/_defaultServer_/vhosts/_defaultVHost_/applications/${CHANNEL_NAME} --data @body.json
}

function deleteChannel {
CHANNEL_NAME=$1

curl -X DELETE --header 'Accept:application/json; charset=utf-8' ${URL}/v2/servers/_defaultServer_/vhosts/_defaultVHost_/applications/${CHANNEL_NAME}
}


echo -e "Choices \n 1.Create a channel \n 2.Delete a channel"
read choice
	if [ $choice == 1 ]
	then 
	echo "creating channel..Enter name"
	read channel
	createChannel $channel

	else
	echo "deleting channel..Enter name"
	read channel
	deleteChannel $channel
	fi 
