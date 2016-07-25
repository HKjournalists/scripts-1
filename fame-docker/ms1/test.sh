#!/usr/bin/env bash
for (( i = 0; i < 10; i++ )); do
  #printing number from 1 to 10
    echo "hii $i"
done

i=1

while [[ i -ne 10 ]]; do
  #while printing
  echo "hii while $i"
  i=`expr $i + 1 `
done
