#!/bin/bash

# Define the list of Keychain item names you want to select from
keychain_items=("3p")

# Function to get the password from Keychain
get_keychain_password() {
    local item_name="$1"
    local password=$(security find-generic-password -s "$item_name" -w)
    echo "$password"
}

# Present the user with a menu to select the password
selected_item=$(printf '%s\n' "${keychain_items[@]}" | fzf --prompt="Select a password to insert: ")

if [ -n "$selected_item" ]; then
    password=$(get_keychain_password "$selected_item")
    if [ -n "$password" ]; then
        # Insert the password into the current application
        printf '%s' "$password" | pbcopy
        osascript -e 'tell application "System Events" to keystroke "v" using command down'
    else
        echo "Error: Could not retrieve the password for '$selected_item'"
    fi
else
    echo "No item selected."
fi
