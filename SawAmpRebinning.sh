#!/bin/sh

#  SawAmpRebinning.sh
#  
#
#  Created by Semyon Goryunov on 31/01/2020.
#
var=0
cpsDet=()
array=()
num=0
file="det_cps_in_cycle.txt"
#clear file
>$file
#var=$(awk '/DATA_:/{print NR}' $1)
for f in $PWD/$1*
do
    array=($(awk 'NR>29 {print $2}' "$f"))
    for idx in "${!array[@]}"; do
        cpsDet[idx]=$(( cpsDet[idx] + array[idx] ))
        echo "$f --> Ok!"
    done
    num=$((num+1))
done
# write file
i=1
echo "# X Y" >> $file
for var1 in ${cpsDet[@]}; do
    awk -v a=$var1 -v b=$num -v c=$i BEGIN'{printf "%d %f\n", c, a/b}' >> $file
    i=$((i+1))
done
RED=$(tput setaf 1)
NORMAL=$(tput sgr0)
#echo ${cpsDet[@]}
echo "set decimalsign locale; set yrange[20:30]; set xrange[0:$i   ]; plot '$file' pt 3 lc rgb 'red'" | gnuplot
echo "Processed files are $RED$num$NORMAL"
exit 0
