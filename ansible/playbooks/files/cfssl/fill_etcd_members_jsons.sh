#!/bin/bash

# check os
OS=$(uname -s)
set -euo pipefail

# shellcheck disable=SC2013
fill_json_mac() {
  for i in $(cat hostname_list); do
    sh_hostname=$i
#    fqdn=${sh_hostname}.{domain}.ru
    ip_a=$(echo $sh_hostname | cut -c 4- | sed 's/\-/./g')
    json_file=${sh_hostname}.json
    cp memberN.json "$json_file"
    sed -i '' -e "s|<hostname>|$sh_hostname|g" "$json_file"
#    sed -i '' -e "s|<fqdn>|$fqdn|g" "$json_file"
    sed -i '' -e "s|<ip_address>|$ip_a|g" "$json_file"
    sed -i '' -e "s|<algorithm>|ecdsa|g" "$json_file"
    sed -i '' -e "s|<size_in_bytes>|256|g" "$json_file"
  done
}

fill_json_linux() {
  for i in $(cat hostname_list); do
    sh_hostname=$i
 #   fqdn=${sh_hostname}.{domain}.ru
    ip_a=$(echo $sh_hostname | cut -c 4- | sed 's/\-/./g')
    json_file=${sh_hostname}.json
    cp memberN.json "$json_file"
    sed -i  "s/<hostname>/$sh_hostname/g" "$json_file"
#    sed -i  "s/<fqdn>/$fqdn/g" "$json_file"
    sed -i  "s/<ip_address>/$ip_a/g" "$json_file"
    sed -i  "s/<algorithm>/ecdsa/g" "$json_file"
    sed -i  "s/<size_in_bytes>/256/g" "$json_file"
  done
}

if [ $OS == Linux ]; then
	fill_json_linux	
elif [ $OS == Darwin ]; then
	fill_json_mac
else
   echo 'Running M$ windows? Sorry, you need some handjob to fill these jsons'
fi