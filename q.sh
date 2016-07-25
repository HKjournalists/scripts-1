#!/bin/bash
if [[ -z "$module" ]];
      then
	sed -i "/s/module/${module}/" /root/a.txt
fi

if [[ -z "$Xms" ]];
      then
	sed -i "s/Xms512m/${Xms}/g" /root/a.txt
fi

if [[ -z "$Xmx" ]];
      then
	sed -i "s/Xms512m/${Xmx}/g" /root/a.txt
fi

