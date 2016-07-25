#!/bin/bash
a=50
#b=51
function add1 {
echo "add1 function is called"
echo "enter the summing amount"
read m
b=`expr $a + $m`
echo "value is $b"
}

function sub1 {
echo "sub1 function is called"
c=`expr $a - $m`
echo "value is $c"
}

add1
sub1
echo "value is a=$a, b=$b, c=$c"
