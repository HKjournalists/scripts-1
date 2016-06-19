#!/bin/bash
URL="http://qa-wowzain.livfame.com:8087"
CHANNEL_NAME=$1
curl -X DELETE --header 'Accept:application/json; charset=utf-8' ${URL}/v2/servers/_defaultServer_/vhosts/_defaultVHost_/applications/${CHANNEL_NAME}
