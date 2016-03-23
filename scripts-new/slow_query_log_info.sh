#!/bin/bash
sed -e 's/# Query_time/\n\n================Q U E R Y_S T A R T==============>>>\nQuery_time/' -e 's/# User@Host/==================Q U E R Y _E N D=============/' my3 > my_new

time=($(cat my_new  | grep Query_time | awk '{print $2}' | sort -n -r | head -n 10))
for i in "${time[@]}"
do
echo "**********************************************Q U E R Y - S T A R T************************************************">>slowquery.text
grep $i my_new >>slowquery.text
awk '/'$i'/{flag=1;next}/==:/{flag=0}flag' my_new >>slowquery.text
echo "**********************************************Q U E R Y - E N D************************************************">>slowquery.text 
echo "                                                                                                                               ">>slowquery.text

done
