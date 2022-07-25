#!/bin/bash

read -p "Enter a number: " number

temp=$number

while [ $temp -gt 0]
do
    reverse=$reverse$(($temp%10))
    temp=$((temp/10))
done

echo "reversed of $number is: $reverse"