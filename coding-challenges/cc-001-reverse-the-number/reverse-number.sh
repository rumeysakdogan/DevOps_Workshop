#!/bin/bash

read -p "Enter a number: " number

reversed_num=0
while [[ $number -gt 0 ]]
do
reversed_num=$(expr $reversed_num \* 10)
last_digit=$(expr $number % 10)
reversed_num=$(($reversed_num+$last_digit))
number=$(($number/10))
done
echo "Reversed number: $reversed_num"

