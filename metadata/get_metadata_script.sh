#!/bin/bash
HOST=$1
USER=$2
KEY=$3

if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]
then
echo "Pass parmaters in order ServerAdress, Username and Private Key"
exit

else
read -p 'Press 1 to get entire metadata and 2 to get the specific keys ' META
if [ $META -eq 1 ]
then
ssh -i $KEY $USER@$HOST curl -s -H Metadata:true --noproxy "*" "http://169.254.169.254/metadata/instance?api-version=2021-02-01" | jq
else
read -p 'Enter complete path for key seperated by . :' JKEY
ssh -i $KEY $USER@$HOST curl -s -H Metadata:true --noproxy "*" "http://169.254.169.254/metadata/instance?api-version=2021-02-01" | jq .$JKEY
fi
fi