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
add_s=( $(awk '/"Name":"hipMemcpyHtoD"/ {getline ; print $3}' input.mod.json | sed 's/src(0x//g' | sed 's/)//g') )
add_d=( $(awk '/"Name":"hipMemcpyHtoD"/ {getline ; print $2}' input.mod.json | sed 's/dst(0x//g' | sed 's/)//g') )
#remove duplicates
addresses_s=($(printf "%s\n" "${add_s[@]}" | sort -u | tr '\n' ' '))
addresses_d=($(printf "%s\n" "${add_d[@]}" | sort -u | tr '\n' ' '))

lens=$((${#addresses_s[@]}-1))
lend=$((${#addresses_d[@]}-1))


echo " Found ${#addresses_s[@]} ${#addresses_d[@]} "

for j in $(seq 0 $lens) ; do 
	for i in $(seq 0 $lend) ; do
		#check if src and dest match
		counts=$( grep -c "dst(0x${addresses_d[$i]}) src(0x${addresses_s[$j]})" input.mod.json )
		if [[ $counts -gt 0 ]] ; then
			#find the name of the variable from debugger output
			var_name=$( grep -B 16 "host ${addresses_s[$j]} to acc ${addresses_d[$i]}" $input | grep "Simple transfer of" | tail -n 1 | awk '{print $5}' | sed "s/'//g")
			counts=$( grep -c "dst(0x${addresses_d[$i]}) src(0x${addresses_s[$j]})" input.mod.json )
			echo "$var_name with addr dst(0x${addresses_d[$i]}), src(0x${addresses_s[$j]}) occurs $counts times"
	        	#put the name of the variable in Data
			sed -i '/dst(0x'${addresses_d[$i]}') src(0x'${addresses_s[$j]}')/{n;s/"Data":"",/"Data":"'$var_name'",/}' input.mod.json
		fi
	done
done

echo "name hipMemcpyDtoH"

add_d=( $(awk '/"Name":"hipMemcpyDtoH"/ {getline ; print $2}' input.mod.json | sed 's/dst(0x//g' | sed 's/)//g') )
add_s=( $(awk '/"Name":"hipMemcpyDtoH"/ {getline ; print $3}' input.mod.json | sed 's/src(0x//g' | sed 's/)//g') )
addresses_s=($(printf "%s\n" "${add_s[@]}" | sort -u | tr '\n' ' '))
addresses_d=($(printf "%s\n" "${add_d[@]}" | sort -u | tr '\n' ' '))
lens=$((${#addresses_s[@]}-1))
lend=$((${#addresses_d[@]}-1))

echo " Found ${#addresses_s[@]} ${#addresses_d[@]} "

for j in $(seq 0 $lens) ; do
        for i in $(seq 0 $lend) ; do
                counts=$( grep -c "dst(0x${addresses_d[$i]}) src(0x${addresses_s[$j]})" input.mod.json )
                if [[ $counts -gt 0 ]] ; then
                        #find the name of the variable from debugger outp
                        var_name=$( grep -B 16 "acc ${addresses_s[$j]} to host ${addresses_d[$i]}" $input | grep "Simple transfer of" | tail -n 1 | awk '{print $5}' | sed "s/'//g")
                        counts=$( grep -c "dst(0x${addresses_d[$i]}) src(0x${addresses_s[$j]})" input.mod.json )
                        echo "$var_name with addr dst(0x${addresses_d[$i]}), src(0x${addresses_s[$j]}) occurs $counts times"
                        #put the name of the variable in Data
                        sed -i '/dst(0x'${addresses_d[$i]}') src(0x'${addresses_s[$j]}')/{n;s/"Data":"",/"Data":"'$var_name'",/}' input.mod.json
                fi
        done
done
