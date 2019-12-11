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

####
## USAGE: parse_input
## Takes terrform input and sets global variables
####
function parse_input() {
    if [[ -z "${ibmcloud_api_key}" ]] || [[ -z "${ibmcloud_endpoint}" ]] || [[ -z "${iam_endpoint}" ]] || [[ -z "${rias_endpoint}" ]] || [[ -z "${name}" ]] || [[ -z "${region}" ]] || [[ -z "${resource_group_id}" ]]; then
        eval "$(jq -r '@sh "ibmcloud_endpoint=\(.ibmcloud_endpoint) rias_endpoint=\(.rias_endpoint) ibmcloud_api_key=\(.ibmcloud_api_key) region=\(.region) resource_group_id=\(.resource_group_id) iam_endpoint=\(.iam_endpoint) name=\(.name)"')"
    fi
}

function find_image() {

    # Login to IBMCloud for given region and resource-group
    ibmcloud login -a ${ibmcloud_endpoint} --apikey "${ibmcloud_api_key}" -r "${region}"  &> $MSG_FILE

    export apikey="${ibmcloud_api_key}"

    export iam_token=`curl -k -X POST \
  --header "Content-Type: application/x-www-form-urlencoded" \
  --header "Accept: application/json" \
  --data-urlencode "grant_type=urn:ibm:params:oauth:grant-type:apikey" \
  --data-urlencode "apikey=$apikey" \
  "https://${iam_endpoint}/identity/token"  |jq -r '(.token_type + " " + .access_token)'`	

   curl -X GET "${rias_endpoint}/v1/images?version=2019-11-05&generation=1&visibility=private" -H "Authorization: $iam_token" > tmp.json

   found=$(cat tmp.json | jq '.images[].name|select(. == "${name}")') 

if [[ -z "$found" ]]
then
      found="null"
fi
   
}

function produce_output() {
    jq -n --arg  "$found" '{"id":$id}'
}

# Global variables shared by functoins
MSG_FILE="/tmp/out.log" && rm -f "$MSG_FILE" &> /dev/null && touch "$MSG_FILE" &> /dev/null

parse_input
find_image
produce_output
