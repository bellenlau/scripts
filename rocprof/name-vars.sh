#####################################################################################
#
# this is a small script to cross ref addreses from CRAY DEBUGGER and hip traces
# Laura Bellentani @ CINECA
# 15 May 2023 (wip)
#
# export CRAY_ACC_DEBUG=3 is needed
#
#####################################################################################

#!/bin/bash
echo "hipMemcpyHtoD"
input=$1
addresses=( $(awk '/"Name":"hipMemcpyHtoD"/ {getline ; print $3}' input.json | sed 's/src(0x//g' | sed 's/)//g') )
for i in "${addresses[@]}" ; do
	var_name=$(grep -B 6 -m 1 $i $input | awk '/Simple transfer/ {print $5}' | sed "s/'//g")
	echo "$var_name with addr $i occurs $(grep -c $i prova.json) times"
        sed -i '/'$i'/{n;s/"Data":"",/"Data":"'$var_name'",/}' input.json
	j=$(($j+1))
	echo "$j is $var_name ... done "
done
echo "hipMemcpyDtoH"
input=$1
addresses=( $(awk '/"Name":"hipMemcpyDtoH"/ {getline ; print $3}' input.json | sed 's/src(0x//g' | sed 's/)//g') )
for i in "${addresses[@]}" ; do
        var_name=$(grep -B 6 -m 1 $i $input | awk '/Simple transfer/ {print $5}' | sed "s/'//g")
        echo "$var_name with addr $i occurs $(grep -c $i prova.json) times"
        sed -i '/'$i'/{n;s/"Data":"",/"Data":"'$var_name'",/}' input.json
        j=$(($j+1))
        echo "$j is $var_name ... done "
done


