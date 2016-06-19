FROM tarunsaxena/ms-2may-final:latest
MAINTAINER DevOps Support tech-fame-devops@tothenew.com
ADD restartserver.sh /root/
RUN chmod +x /root/restartserver.sh
ADD startUp.sh /root/
RUN chmod +x /root/startUp.sh
ADD APP_PATH /root/jars/root.jar 
CMD ["/root/startUp.sh"]
