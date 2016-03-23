#!/bin/bash

#rm -rf /home/ubuntu/ZombieAMIs.txt
touch /home/ubuntu/ZombieAMIs.txt

########Filewhere the zombie snaps will be stored#######

image_ids=($(aws ec2 describe-snapshots --owner-ids 069716362557 |grep -i CreateImage|awk {'print $6'}|sort | uniq))
##### finds image ids ---------AMI Snapshots have description as "created by AMi" so grepping & awking those snapshots & finding their AMI ids" 


for i in "${image_ids[@]}"
do
        /usr/local/bin/aws ec2 describe-images --owners 069716362557 --image-ids $i | grep -i BLOCKDEVICEMAPPINGS
        ##the above command will check if the AMI exists or not 
        
        if [ $? -eq 0 ];then
                echo "AMI exists :D so linked snapshots wont be deleted"      
        else 
                snap_ids=($(/usr/local/bin/aws ec2 describe-snapshots --owner-ids 069716362557 |grep "$i" | awk '{print $12}'))
                for j in "${snap_ids[@]}"   
                        do
                        #/usr/local/bin/aws ec2 delete-snapshot --snapshot-id $snap_ids    UNCOMMENT TO DELETE ZOMBIE SNAPSHOTS
                        echo "$j" >>/home/ubuntu/ZombieAMIs.txt
                        done     
        fi                          
done 
