############################################################
# Functions to archive the app and upload it to TestFlight
############################################################

# Required: TESTFLIGHT_SCHEME
#    Xcode scheme that is archived, set by the BuildXXX script
#    For example: TESTFLIGHT_SCHEME="LoopWorkspace"

URL_TESTFLIGHT_GROUP="https://loopkit.github.io/loopdocs/browser/tf-users/#configure-testflight-group-for-the-app"
URL_TESTFLIGHT_INSTALL="https://loopkit.github.io/loopdocs/browser/phone-install/"

function select_xcode_or_testflight() {
    section_separator
    echo -e "${INFO_FONT}Choose how to install the app${NC}"
    echo -e ""
    echo -e "  Open Xcode:"
    echo -e "    Build in Xcode and install on a phone connected to this computer"
    echo -e ""
    echo -e "  Upload to TestFlight:"
    echo -e "    The script builds the app and uploads it to TestFlight"
    echo -e "    You install the app on the phone with the TestFlight app"
    echo -e "    Requires a paid Apple Developer account"
    echo -e "    TestFlight builds expire after 90 days"
    echo -e ""
    options=("Open Xcode" "Upload to TestFlight" "$(exit_or_return_menu)")
    actions=("TESTFLIGHT_UPLOAD=0" "TESTFLIGHT_UPLOAD=1" "exit_script")
    menu_select "${options[@]}" "${actions[@]}"
}

function testflight_team_id() {
    if [ -f "${OVERRIDE_FULLPATH}" ]; then
        grep "^$DEV_TEAM_SETTING_NAME" "${OVERRIDE_FULLPATH}" | tail -1 | awk -F= '{gsub(/[ \t]/, "", $2); print $2}'
    fi
}

function create_testflight_export_options() {
    local plist_file=$1
    local team_id=$(testflight_team_id)

    cat > "$plist_file" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store-connect</string>
    <key>destination</key>
    <string>upload</string>
    <key>signingStyle</key>
    <string>automatic</string>
    <key>testFlightInternalTestingOnly</key>
    <true/>
    <key>manageAppVersionAndBuildNumber</key>
    <true/>
EOF
    if [ -n "$team_id" ]; then
        echo "    <key>teamID</key>" >> "$plist_file"
        echo "    <string>${team_id}</string>" >> "$plist_file"
    fi
    echo "</dict>" >> "$plist_file"
    echo "</plist>" >> "$plist_file"
}

function testflight_next_steps() {
    echo -e "  Apple processes the build before it shows up in TestFlight"
    echo -e "    This usually takes 5 to 30 minutes"
    echo -e ""
    echo -e "  First time only: set up an internal TestFlight group for the app"
    echo -e "    and add yourself and anyone else who will install the app"
    echo -e "    The steps are the same for Loop, Trio and LoopFollow:"
    echo -e "    ${URL_TESTFLIGHT_GROUP}"
    echo -e ""
    echo -e "  Install the app on the phone with the TestFlight app:"
    echo -e "    ${URL_TESTFLIGHT_INSTALL}"
}

function testflight_missing_app_instructions() {
    echo -e "${INFO_FONT}The app is not yet registered in App Store Connect${NC}"
    echo -e "  This is expected the first time you upload this app"
    echo -e "  The archive opens in the Xcode Organizer when you hit return"
    echo -e ""
    echo -e "  In the Organizer:"
    echo -e "    1. Select the newest archive and click Distribute App"
    echo -e "    2. Choose TestFlight Internal Only and click Distribute"
    echo -e "    3. Xcode offers to create an app record for you"
    echo -e "       The Name must be unique in the whole App Store"
    echo -e "       Add something to make it unique, for example: ${APP_NAME}-$(testflight_team_id)"
    echo -e "    4. Keep the other values and click Next until the upload starts"
    echo -e ""
    echo -e "  Future uploads from this script will not need this step"
}

function upload_to_testflight() {
    local workspace=$(ls -d *.xcworkspace 2>/dev/null | head -1)
    local testflight_dir="${LOCAL_DIR}/TestFlight"
    local archive_path="${testflight_dir}/${REPO_NAME}.xcarchive"
    local export_options="${testflight_dir}/ExportOptions.plist"
    local archive_log="${testflight_dir}/archive.log"
    local upload_log="${testflight_dir}/upload.log"

    section_separator
    if [ -z "$workspace" ]; then
        echo -e "❌ ${ERROR_FONT}No Xcode workspace found in $(pwd)${NC}"
        exit_message
    fi

    mkdir -p "${testflight_dir}"
    create_testflight_export_options "${export_options}"

    echo -e "${INFO_FONT}Building the app for TestFlight${NC}"
    echo -e "  This usually takes 10 to 30 minutes"
    echo -e "  The full build log is saved to:"
    echo -e "    ${archive_log}"
    echo -e ""
    xcodebuild archive \
        -workspace "${workspace}" \
        -scheme "${TESTFLIGHT_SCHEME}" \
        -configuration Release \
        -destination "generic/platform=iOS" \
        -archivePath "${archive_path}" \
        -allowProvisioningUpdates \
        > "${archive_log}" 2>&1
    if [ $? -ne 0 ]; then
        echo -e "❌ ${ERROR_FONT}The build failed${NC}"
        echo -e ""
        grep -E "error:" "${archive_log}" | sort -u | head -20
        echo -e ""
        echo -e "  The full build log is saved to:"
        echo -e "    ${archive_log}"
        exit_message
    fi
    echo -e "✅ ${SUCCESS_FONT}Build succeeded${NC}"
    echo -e ""

    echo -e "${INFO_FONT}Uploading the app to App Store Connect${NC}"
    echo -e ""
    xcodebuild -exportArchive \
        -archivePath "${archive_path}" \
        -exportOptionsPlist "${export_options}" \
        -exportPath "${testflight_dir}/export" \
        -allowProvisioningUpdates \
        > "${upload_log}" 2>&1
    if [ $? -eq 0 ]; then
        echo -e "✅ ${SUCCESS_FONT}Upload succeeded${NC}"
        echo -e ""
        testflight_next_steps
        return
    fi

    local distribution_logs=$(grep -o 'Created bundle at path "[^"]*"' "${upload_log}" | tail -1 | sed 's/.*"\(.*\)"/\1/')
    if [ -n "$distribution_logs" ] && \
        grep -qs "missingApp" "${distribution_logs}"/IDEDistribution*.log; then
        testflight_missing_app_instructions
        return_when_ready
        open "${archive_path}"
        echo -e ""
        echo -e "When the upload in the Organizer has finished:"
        echo -e ""
        testflight_next_steps
        return
    fi

    echo -e "❌ ${ERROR_FONT}The upload failed${NC}"
    echo -e ""
    grep -E "error:" "${upload_log}" | sort -u | head -20
    echo -e ""
    echo -e "  Common causes:"
    echo -e "    - An agreement is waiting to be accepted in App Store Connect"
    echo -e "      https://appstoreconnect.apple.com/business"
    echo -e "    - Your Apple ID is not signed in to Xcode (Xcode Settings, Accounts)"
    echo -e ""
    echo -e "  The full upload log is saved to:"
    echo -e "    ${upload_log}"
    echo -e ""
    echo -e "  You can also upload the archive from the Xcode Organizer,"
    echo -e "    which often shows a more detailed error message"
    echo -e "    Select the newest archive, click Distribute App"
    echo -e "    and choose TestFlight Internal Only"
    echo -e ""
    echo -e "The archive opens in the Xcode Organizer when you hit return"
    return_when_ready
    open "${archive_path}"
}

############################################################
# End of TestFlight functions
############################################################
