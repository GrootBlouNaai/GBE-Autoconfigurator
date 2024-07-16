#!/bin/bash

########################################################################
# Usage: APPID=736260 ./goldberg.sh                                    #
# You need to set EMU_DIR to the extracted goldberg emulator directory.#
# To be able to use genconf get the scripts from the goldberg source   #
# code and put it in $EMU_DIR/scripts                                  #
########################################################################

# Configuration
EMU_DIR="/path/to/emu"

# Function to set the username
set_username() {
    mkdir -p steam_settings
    echo "jc141" > steam_settings/force_account_name.txt
}

# Function to handle native libraries
handle_native() {
    local original_lib="libsteam_api.so.orig"
    mv libsteam_api.so "$original_lib"
    if file "$original_lib" | grep -q "32-bit"; then
        cp "$EMU_DIR/linux/x32/libsteam_api.so" libsteam_api.so
    else
        cp "$EMU_DIR/linux/x64/libsteam_api.so" libsteam_api.so
    fi
}

# Function to handle Windows libraries
handle_windows() {
    if [ -e steam_api64.dll ]; then
        mv steam_api64.dll steam_api64.dll.orig
        cp "$EMU_DIR/experimental/x64/steam_api64.dll" steam_api64.dll
    else
        mv steam_api.dll steam_api.dll.orig
        cp "$EMU_DIR/experimental/x32/steam_api.dll" steam_api.dll
    fi
}

# Function to find interfaces
find_interfaces() {
    if [ -e libsteam_api.so ]; then
        "$EMU_DIR/linux/tools/find_interfaces.sh" libsteam_api.so >> steam_interfaces.txt
    else
        "$EMU_DIR/linux/tools/find_interfaces.sh" steam_api*.dll >> steam_interfaces.txt
    fi
}

# Function to generate configuration
generate_config() {
    "$EMU_DIR/scripts/generate_emu_config/generate_emu_config" "$APPID"
    cp -r output/"$APPID"/steam_settings "$PWD"
    cp -r output/"$APPID"/info "$PWD"
    rm -rf output
}

# Main execution logic
if [ -e libsteam_api.so ]; then
    find_interfaces &
    sleep 1
    handle_native
else
    find_interfaces &
    sleep 1
    handle_windows
fi

set_username
generate_config
