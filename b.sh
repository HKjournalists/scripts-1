#!/bin/bash
#declare NAME
function askMyName {
#echo "calling function askMyName"
read name
echo $name
#echo "displaying name from askMyName: $name"

}
var=$(askMyName)
echo $var
