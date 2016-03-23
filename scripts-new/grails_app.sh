#!/bin/bash
wget https://s3-ap-southeast-1.amazonaws.com/bootcamp.demo.public/grails-2.4.3.zip
sudo apt-get update -y
sudo apt-get install unzip -y
sudo unzip grails-2.4.3.zip 
echo -ne '\n' | sudo add-apt-repository ppa:webupd8team/java 
echo -ne '\n' | sudo apt-get install openjdk-7-jdk -y 

echo "JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64" >> .usersetting
echo "GRAILS_HOME=/home/ubuntu/grails-2.4.3"  >> .usersetting
echo "PATH='$PATH':'$GRAILS_HOME'/bin:'$JAVA_HOME'/bin"  >> .usersetting
echo "export GRAILS_HOME"  >> .usersetting
echo "export JAVA_HOME"  >> .usersetting
echo "export PATH"  >> .usersetting

echo ". /home/ubuntu/.usersetting" >> .bashrc
source .bashrc
