#!/bin/bash
if [ -f /var/run/WowzaStreamingEngine.pid ]
then	
	echo "file exists"
else
 	echo "file doesn't exist"
fi
