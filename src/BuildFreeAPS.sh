#!/bin/bash # script BuildFreeAPS.sh

############################################################
# Required parameters for any build script that uses
#   inline build_functions
############################################################

BUILD_DIR=~/Downloads/BuildLoop
OVERRIDE_FILE=LoopConfigOverride.xcconfig
DEV_TEAM_SETTING_NAME="LOOP_DEVELOPMENT_TEAM"

#!inline build_functions.sh


############################################################
# The rest of this is specific to the particular script
############################################################

open_source_warning


############################################################
# Welcome & Branch Selection
############################################################

URL_THIS_SCRIPT="https://github.com/loopnlearn/LoopWorkspace.git"

function choose_main_branch() {
    branch_select ${URL_THIS_SCRIPT} freeaps FreeAPS
}

if [ -z "$CUSTOM_BRANCH" ]; then
    section_separator
    echo -e "\n ${INFO_FONT}You are running the script to build FreeAPS"
    echo -e " This app is a fork based off of Loop 2.2.x."
    echo -e " Please consider Loop 3 instead.${NC}"
    echo -e " You need Xcode and Xcode command line tools installed"
    echo -e ""
    echo -e " If you have not read this page - please review before continuing"
    echo -e "    https://www.loopandlearn.org/freeapsdoc"
    section_divider

    options=("Continue" "$(exit_or_return_menu)")
    actions=("choose_main_branch" "exit_script")
    menu_select "${options[@]}" "${actions[@]}"
else
    branch_select ${URL_THIS_SCRIPT} $CUSTOM_BRANCH
fi

############################################################
# Standard Build train
############################################################

standard_build_train

############################################################
# Open Xcode
############################################################

section_divider
before_final_return_message
echo -e ""
return_when_ready
cd $REPO_NAME
xed . 
after_final_return_message
exit_script
