#!/bin/bash
port=1
function cport1 {
#echo "calling function askMyName"
echo "in func cport1 befor changing"
echo $port
echo "in func cport1 after changing"
port=2
echo $port

}

function cport2 {
echo "in func cport2 befor changing"
echo $port
echo "in func cport2 after changing"
port=3
echo $port
#echo "displaying name from askMyName: $name"
}



cport1
cport2
echo "final port : $port "

