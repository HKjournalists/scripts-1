#!/bin/bash
cd /root/jars
ENV=test
nohup java -Dserver.port=8080 -XX:MaxPermSize=512m -Xms1024m -Xmx1500m -XX:MaxGCPauseMillis=200 -XX:-UseParallelOldGC -XX:+UseGCOverheadLimit -jar -Dspring.profiles.active=${ENV} root.jar  >> /opt/jetty/logs/app.log &
tailf /dev/null
