#!/bin/bash

# Exit if any of the intermediate steps fail
set -e

# Script is executed by a Terraform external data source hook
# Inputs passed as stdin variables:
#    ibmcloud_api_key = "${var.ibmcloud_api_key}"
#    generation = "${var.generation}"
#    region = "${var.region}"
#    resource_group_id = "${data.ibm_resource_group.rg.id}"
#    f5_image_name = "${var.f5_image_name}"
#    vnf_f5bigip_cos_image_url = "${var.vnf_f5bigip_cos_image_url}"
#
#  output: {"id": "<id of custom image created"}
#

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
    if [[ -z "${ibmcloud_api_key}" ]] || [[ -z "${generation}" ]] || [[ -z "${region}" ]] || [[ -z "${resource_group_id}" ]] || [[ -z "${f5_image_name}" ]] || [[ -z "${vnf_f5bigip_cos_image_url}" ]]; then
        eval "$(jq -r '@sh "ibmcloud_endpoint=\(.ibmcloud_endpoint) ibmcloud_api_key=\(.ibmcloud_api_key) generation=\(.generation) region=\(.region) resource_group_id=\(.resource_group_id) f5_image_name=\(.f5_image_name) vnf_f5bigip_cos_image_url=\(.vnf_f5bigip_cos_image_url)"')"
    fi

}

####
## USAGE: prep_deps <ibmcloud_api_key> <region> <resource_group> <generation>
####
function prep_deps() {
    _log "## Entering function: ${FUNCNAME[0]}"

    # Install the Infrastructure-Services IBMCloud CLI Plugin
    ibmcloud plugin install vpc-infrastructure -f &> $MSG_FILE

    # Login to IBMCloud for given region and resource-group
    ibmcloud login -a ${ibmcloud_endpoint} --apikey "${ibmcloud_api_key}" -r "${region}" -g "${resource_group_id}" &> $MSG_FILE

    # Set the generation of VPC
    ibmcloud is target --gen ${generation} &> $MSG_FILE

    _log "## Exiting function: ${FUNCNAME[0]}"
}

####
## USAGE: get_image_id <f5_image_name>
####
function get_image_id() {
    _log "## Entering function: ${FUNCNAME[0]}"
    IMAGE_ID=$(eval "ibmcloud is images --visibility private --json | jq -r '.[] | select (.name==\"${f5_image_name}\") | .id'")
    _log "## Exiting function: ${FUNCNAME[0]}"
}

####
## USAGE: get_image_status <f5_image_name>
####
function get_image_status() {
    _log "## Entering function: ${FUNCNAME[0]}"
    IMAGE_STATUS=$(eval "ibmcloud is images --visibility private --json | jq -r '.[] | select (.name==\"${f5_image_name}\") | .status'")
    _log "Image status is $IMAGE_STATUS "
    _log "## Exiting function: ${FUNCNAME[0]}"
}

function produce_output() {
    _log "## Entering function: ${FUNCNAME[0]}"
    get_image_id
    jq -n --arg id "$IMAGE_ID" '{"id":$id}'
    _log "## Exiting function: ${FUNCNAME[0]}"
}

####
## USAGE: create_image <f5_image_name> <vnf_f5bigip_cos_image_url> <resource_group_id>
####
function create_image() {
    _log "## Entering function: ${FUNCNAME[0]}"
    get_image_id
    if [ "$IMAGE_ID" == "" ]; then
        local image_create_cmd="ibmcloud is image-create '${f5_image_name}' --file '${vnf_f5bigip_cos_image_url}' --os-name 'centos-7-amd64' --resource-group-id '${resource_group_id}'"
        _log "${image_create_cmd} "
        eval $image_create_cmd &> $MSG_FILE

        # Wait 5 mins for image to get fully created i.e status=available
        sleep_counter=1
        max_sleep=20
        while [ "$IMAGE_STATUS" != "available" ]; do
            get_image_status  # refresh IMAGE_STATUS
            if [ $sleep_counter -le $max_sleep ]; then
                _log "$sleep_counter : Waiting on image status to become available."
                sleep 30
                sleep_counter=$((sleep_counter+1))
            else
                _log "Image creation is stuck in pending state for $(($sleep_counter/2)) minutes. "
                break
            fi
        done
    else
        _log "Skipping image creation as it already exists with image_id ${IMAGE_ID}. "
    fi
    _log "## Exiting function: ${FUNCNAME[0]}"
}

# main()
# Assign variables from input passed (debugging purpose)
# ibmcloud_endpoint=$1
# ibmcloud_api_key=$2
# generation=$3
# region=$4
# resource_group_id=$5
# f5_image_name=$6
# vnf_f5bigip_cos_image_url=$7

# Global variables shared by functoins
MSG_FILE="/tmp/out.log" && rm -f "$MSG_FILE" &> /dev/null && touch "$MSG_FILE" &> /dev/null
_log "## Entering function: Main"
IMAGE_ID=""
IMAGE_STATUS="pending"

# call functions to get image created
parse_input
prep_deps
create_image
produce_output
_log "## Exiting function: Main "
