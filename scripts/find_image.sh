#!/bin/bash

# Exit if any of the intermediate steps fail
set -e

# TO-DO comments on input variables

####
## USAGE: Called by bash when exiting on error.
## Will dump stdout and stderr from lgo file to stdout
####
function error_exit() {
  cat "$MSG_FILE"
  exit 1
}

####
## USAGE: _log <log_message>
####
function _log() {
    echo "$1" > "$MSG_FILE"
}

function find_image() {

    # Login to IBMCloud for given region and resource-group
    ibmcloud login -a test.cloud.ibm.com --apikey "YxcJOxqBL20UmOR3w4qX-ncCKIVvD47ugk1EOTDuSurr" -r "us-south"  

    export apikey="YxcJOxqBL20UmOR3w4qX-ncCKIVvD47ugk1EOTDuSurr"

    export iam_token=`curl -k -X POST \
  --header "Content-Type: application/x-www-form-urlencoded" \
  --header "Accept: application/json" \
  --data-urlencode "grant_type=urn:ibm:params:oauth:grant-type:apikey" \
  --data-urlencode "apikey=$apikey" \
  "https://iam.test.cloud.ibm.com/identity/token"  |jq -r '(.token_type + " " + .access_token)'`	

   curl -X GET "$rias_endpoint/v1/images?version=2019-11-05&generation=1&visibility=private" -H "Authorization: $iam_token" > tmp.json

   found=$(cat tmp.json | jq '.images[].name|select(. == "f5-bigip-15-0-1-0-0-11")') 

if [ -z "$found" ]
then
      $found="null"
fi
   
}

function produce_output() {
    jq -n --arg  "$found" '{"id":$id}'
}

# Global variables shared by functoins
MSG_FILE="/tmp/out.log" && rm -f "$MSG_FILE" &> /dev/null && touch "$MSG_FILE" &> /dev/null

find_image
produce_output
