#!/bin/bash
case "$1" in
        admin)
            echo "-DbuildModule=admin  -Dgrails.env=qaReplica -XX:MaxPermSize=513m -Xms513m -Xmx1501m -XX:MaxGCPauseMillis=200 -XX:-UseParallelOldGC -XX:+UseGCOverheadLimit -Dfile.encoding=UTF8"
            ;;
         
        api)
            echo "-DbuildModule=api  -Dgrails.env=qaReplica -XX:MaxPermSize=512m -Xms512m -Xmx1500m -XX:MaxGCPauseMillis=200 -XX:-UseParallelOldGC -XX:+UseGCOverheadLimit -Dfile.encoding=UTF8"
            ;;
         
        job)
            echo "-DbuildModule=jobs  -Dgrails.env=qaReplica -XX:MaxPermSize=512m -Xms512m -Xmx1500m -XX:MaxGCPauseMillis=200 -XX:-UseParallelOldGC -XX:+UseGCOverheadLimit -Dfile.encoding=UTF8"
            ;;
         
        worker)
            echo "java -Dserver.port=8080 -XX:MaxPermSize=513m -Xms1025m -Xmx1501m -XX:MaxGCPauseMillis=200 -XX:-UseParallelOldGC -XX:+UseGCOverheadLimit -jar -Dspring.profiles.active=qa /root/root.jar"
            ;;
        *)
         
 
esac
