#!/bin/bash

#  summ_files.sh
#
#
#  Created by Semyon Goryunov on 25/01/2020.
#

file_name="summ_file.txt"
>$file_name
num=0
sawCount=0
wo_sawCount=0
fixedEffect="0"
fixedEffectErrSq="0"
array=()
#echo "$@"
for dir in $@
do
    for file_num in $PWD/$dir*
    do
        array=($(awk '/M1_sum:/ {printf "%d %d", $5+$11, $9+$7; next} /M2_sum:/ {printf " %d %d", $5+$11, $7+$9}' "$file_num"))
#        awk -v f=$file_num -v a0=${array[0]} -v a1=${array[1]} -v a2=${array[2]} -v a3=${array[3]} BEGIN'{printf "%s %d %d %d %d %f %f %f %f\n", f, a0, a1, a2, a3, (a0-a1)/100, sqrt(a0+a1)/100, (a0-a1*a2/a3)/100, sqrt(a0+(a1*a2/a3)^2*(1/a1+1/a2+1/a3))/100}' >> $file_name
        awk -v a0=${array[0]} -v a1=${array[1]} -v a2=${array[2]} -v a3=${array[3]} BEGIN'{printf "%d %d %d %d %f %f %f %f\n", a0, a1, a2, a3, (a0-a1)/100, sqrt(a0+a1)/100, (a0-a1*a2/a3)/100, sqrt(a0+(a1*a2/a3)^2*(1/a1+1/a2+1/a3))/100}' >> $file_name
        fixedEffect=$(echo "scale=6; $fixedEffect+${array[0]}-${array[1]}*${array[2]}/${array[3]}" | bc | sed 's/^\./0./')
        fixedEffectErrSq=$(echo "scale=6; $fixedEffectErrSq + ${array[0]}+(${array[1]}*${array[2]}/${array[3]})^2*(1/${array[1]}+1/${array[2]}+1/${array[3]})" | bc | sed 's/^\./0./')
        sawCount=$((sawCount+${array[0]}))
        wo_sawCount=$((wo_sawCount+${array[1]}))
        echo "$file_num --> OK"
        num=$((num+1))
    done
done
echo  "Done!"

RED=$(tput setaf 1)
NORMAL=$(tput sgr0)
echo "Directories ${RED}$@${NORMAL} have been processed!"
printf "\nEffect is ${RED}%s +/- %s${NORMAL}\n" $(echo "scale=6; ($sawCount-$wo_sawCount)/$num/100" | bc | sed 's/^\./0./') $(echo "scale=6; sqrt($sawCount+$wo_sawCount)/$num/100" | bc | sed 's/^\./0./')
echo "Fixed effect is" "${RED}$(echo "scale=6; $fixedEffect/$num/100" | bc | sed 's/^\./0./')" "+/-" "$(echo "scale=6; sqrt($fixedEffectErrSq)/$num/100" | bc | sed 's/^\./0./')${NORMAL}"
echo "Processed files are ${RED}$num${NORMAL}"
printf "Total measurement time is ${RED}%s${NORMAL} [h]\n" $(echo "scale=1; $num*200/3600" | bc | sed 's/^\./0./')
# plot graphics
echo "set decimalsign locale; set xrange[0:'$num']; set title 'Fixed effect'; plot '$file_name' using (column(0)):7:8 pt 3 lc rgb 'red' with yerrorbars" | gnuplot
echo "set decimalsign locale; set title 'Monitor count rate'; plot '$file_name' u (column(0)):((column(3)+column(4))/200):(sqrt(column(3)+column(4))/200) pt 3 lc rgb 'blue' with yerrorbars" | gnuplot
#echo "set decimalsign locale; set title 'Monitor count rate'; plot '$file_name' u (column(0)):((column(3)+column(4))/200):(sqrt(column(3)+column(4))/200) pt 3 lc rgb 'blue' with yerrorbars" | gnuplot
exit 0
