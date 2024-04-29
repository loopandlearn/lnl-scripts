#!/bin/bash # script BuildOpen-iAPS.sh

############################################################
# Required parameters for any build script that uses
#   inline build_functions
############################################################

BUILD_DIR=~/Downloads/"BuildOpen-iAPS"
USE_OVERRIDE_IN_REPO="0"
OVERRIDE_FILE="ConfigOverride.xcconfig"
DEV_TEAM_SETTING_NAME="DEVELOPER_TEAM"

# sub modules are required
CLONE_SUB_MODULES="1"

# leave this code here, not in use now
FLAG_USE_SHA=0  # Initialize FLAG_USE_SHA to 0
FIXED_SHA=""    # Initialize FIXED_SHA with an empty string

#!inline build_functions.sh
#!inline utility_scripts.sh
#!inline run_script.sh

############################################################
# The rest of this is specific to the particular script
############################################################

# Set default values only if they haven't been defined as environment variables
: ${SCRIPT_BRANCH:="main"}

open_source_warning

############################################################
# Welcome & Branch Selection
############################################################

URL_THIS_SCRIPT="https://github.com/nightscout/Open-iAPS.git"

function select_oi_main() {
    branch_select ${URL_THIS_SCRIPT} main
}

function select_oi_dev() {
    branch_select ${URL_THIS_SCRIPT} dev
}

function customize() {
    run_script "OiCustomizationSelect.sh"
}

if [ -z "$CUSTOM_BRANCH" ]; then
    while [ -z "$BRANCH" ]; do
        section_separator
        echo -e "\n ${INFO_FONT}You are running the script to build Open-iAPS,${NC}"
        echo -e " ${INFO_FONT}run maintenance utilities or customize Open-iAPS${NC}"
        echo -e ""
        echo -e "To build Open-iAPS, you will select which branch:"
        echo -e "   most people should choose main branch"
        echo -e ""
        echo -e "To customize, you must have previously downloaded Open-iAPS"
        echo -e ""
        echo -e "  Documentation for Open-iAPS:"
        echo -e "    http://openiapsdocs.org"
        echo -e "  Documentation for maintenance utilities:"
        echo -e "    https://www.loopandlearn.org/build-select/#utilities-disk"
        echo -e "  Documentation for customization (only a subset are used for Open-iAPS):"
        echo -e "    https://www.loopandlearn.org/custom-code"
        echo -e ""
        return_when_ready
        section_divider
        echo -e "Before you continue, please ensure"
        echo -e "  you have Xcode and Xcode command line tools installed\n"


        options=("Open-iAPS main" "Open-iAPS dev" "Run Maintenance Utilities" "Customize Open-iAPS" "$(exit_or_return_menu)")
        actions=("select_oi_main" "select_oi_dev" "utility_scripts" "customize" "exit_script")
        menu_select "${options[@]}" "${actions[@]}"
    done
else
    branch_select ${URL_THIS_SCRIPT} $CUSTOM_BRANCH
fi

############################################################
# Standard Build train
############################################################

verify_xcode_path
check_versions
clone_repo
automated_clone_download_error_check

# special build train for lightly tested commit
cd $REPO_NAME

this_dir="$(pwd)"
echo -e "In ${this_dir}"
if [ ${FLAG_USE_SHA} == 1 ]; then
    echo -e "  Checking out commit ${FIXED_SHA}\n"
    git checkout ${FIXED_SHA} --recurse-submodules --quiet
    git describe --tags --exact-match
    git rev-parse HEAD
    echo -e "Continue if no errors reported"
    return_when_ready
fi

check_config_override_existence_offer_to_configure
ensure_a_year

############################################################
# Open Xcode
############################################################

section_divider
before_final_return_message
echo -e ""
return_when_ready
xed . 
after_final_return_message
exit_script
