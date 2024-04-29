#!/bin/bash # script OiCustomizationSelect.sh

BUILD_DIR=~/Downloads/BuildOpen-iAPS

# Customization parameters for Open-iAPS
app_name="Open-iAPS"
app_folder_name="Open-iAPS"

#!inline patch_functions.sh

############################################################
# The rest of this is specific to the particular script
############################################################

message_incompatible_count=0

# this is always used - it is the introductory message - it can be blank
# it comes before any customizations are presented
function message_generic() {
    echo "  These Customizations are documented on the Loop and Learn web site"
    echo "        https://www.loopandlearn.org/custom-code/#custom-list"
    echo
    echo "  The script displays the subset valid for Open-iAPS"
    echo
}

# this is always used - it is the incompatible patches message - it can be blank
function message_incompatible() {
    :
}

# in order for optional messages to appear after the add_customization line
# must use printf
# optional message to go with add_customization line
function message_to_add_blank_line() {
    printf "\n"
}

# list patches in this order with args:
#   User facing information for option
#   Folder name in the patch repo
#   (Optional) message function shown prior to option

add_customization "Change Default to Upload Dexcom Readings" "dexcom_upload_readings"
add_customization "Disable Authentication Requirement" "no_auth"

param_zero_is_customization
param_zero_result=$?

if [ $param_zero_result -eq 0 ]; then
    patch_command_line $0 "$@"
elif [ $# -gt 0 ] && [ -n "$1" ]; then
    patch_command_line "$@"
else
    if [ "$GITHUB_ACTIONS" != "true" ]; then
        patch_menu
    else
        echo -e "${ERROR_FONT}  Customization in Browser Build executed without parameters, check that there is no empty line after CustomizationSelect.sh.{NC}"
        exit 1
    fi
fi