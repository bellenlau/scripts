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

input=$1
cp input.json input.mod.json

echo "name hipMemcpyHtoD"


# take src addresses from json file
addresses_s=( $(awk '/"Name":"hipMemcpyHtoD"/ {getline ; print $3}' input.mod.json | sed 's/src(0x//g' | sed 's/)//g') )
addresses_d=( $(awk '/"Name":"hipMemcpyHtoD"/ {getline ; print $2}' input.mod.json | sed 's/dst(0x//g' | sed 's/)//g') )
len=$((${#addresses_s[@]}-1))

echo " Found ${#addresses_s[@]} ${#addresses_d[@]} "

for j in $(seq 0 $len) ; do
	#find the name of the variable from debugger output
	var_name=$( grep -B 16 "host ${addresses_s[$j]} to acc ${addresses_d[$j]}" $input | grep "Simple transfer of" | tail -n 1 | awk '{print $5}' | sed "s/'//g")
	echo "$var_name with addr dst(0x${addresses_d[$j]}), src(0x${addresses_s[$j]}) occurs $(grep -c "dst(0x${addresses_d[$j]}) src(0x${addresses_s[$j]})" input.mod.json) times"
	#put the name of the variable in Data
	sed -i '/dst(0x'${addresses_d[$j]}') src(0x'${addresses_s[$j]}')/{n;s/"Data":"",/"Data":"'$var_name'",/}' input.mod.json
done
echo "name hipMemcpyDtoH"

addresses_d=( $(awk '/"Name":"hipMemcpyDtoH"/ {getline ; print $2}' input.mod.json | sed 's/dst(0x//g' | sed 's/)//g') )
addresses_s=( $(awk '/"Name":"hipMemcpyDtoH"/ {getline ; print $3}' input.mod.json | sed 's/src(0x//g' | sed 's/)//g') )
len=$((${#addresses_s[@]}-1))

echo " Found ${#addresses_s[@]} ${#addresses_d[@]} "

for j in $(seq 0 $len) ; do
        #find the name of the variable from debugger output
        var_name=$( grep -B 16 "acc ${addresses_s[$j]} to host ${addresses_d[$j]}" $input | grep "Simple transfer of" | tail -n 1 | awk '{print $5}' | sed "s/'//g")
        echo "$var_name with addr dst(0x${addresses_d[$j]}), src(0x${addresses_s[$j]}) occurs $(grep -c "dst(0x${addresses_d[$j]}) src(0x${addresses_s[$j]})" input.mod.json) times"
        #put the name of the variable in Data
        sed -i '/dst(0x'${addresses_d[$j]}') src(0x'${addresses_s[$j]}')/{n;s/"Data":"",/"Data":"'$var_name'",/}' input.mod.json
done
