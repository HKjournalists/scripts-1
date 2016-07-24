#!/bin/bash
a=($(ls -l -I "lost+found" /var/log/app/  | awk -F" " '{print $NF}'))
for i in ${a[@]};
do echo "alias ${i}='tail -F /var/log/app/${i}/app.log'" >> ~/.bashrc
 done;

echo "alias prod-db='mysql -ufame -pfamedefault -hdb.livfame.com'" >> ~/.bashrc
echo "alias qa-db='mysql -ufame -pfamedefault -hqa-db.livfame.com'" >> ~/.bashrc
echo "alias qa1-db='mysql -ufame -pfamedefault -hqa1-db.livfame.com'" >> ~/.bashrc
echo "alias uat-db='mysql -ufame -pfamedefault -huat-db.livfame.com'" >> ~/.bashrc
sudo apt-get install mysql-client-5.6 -y
source ~/.bashrc
