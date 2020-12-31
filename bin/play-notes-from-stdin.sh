#!/bin/bash
# reads letters from STDIN (space separated), play musical notes

while read -e input
do
   for i in $input
   do
      play -q -n synth 3 pluck %$(expr index aabccddeffgg $i - 1) vol 0.05 &
      sleep 0.15
   done
done
