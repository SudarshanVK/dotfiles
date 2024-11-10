#!/usr/bin/env zsh

# Function to paste content
paste_content() {
    osascript <<EOF
        tell application "System Events"
            -- Small delay to ensure the target window is active
            delay 0.5
            -- Simulate Cmd+V
            keystroke "v" using command down
        end tell
EOF
}

# Function to get list of passwords and handle selection
get_password() {
    # Store passwords list in an array
    # You can customize this list with your actual keychain items
    local passwords=(
        "UoM"
        "3p"
        # Add more password identifiers as needed
    )

    # Use fzf to select password
    local selected=$(printf "%s\n" "${passwords[@]}" | fzf --height 40% --border --prompt="Select password: ")

    if [[ -n "$selected" ]]; then
        # Get the password from keychain
        local PASSWORD=$(security find-generic-password -a "$USER" -s "$selected" -w 2>/dev/null)

        if [[ $? -eq 0 ]]; then
            # Copy to clipboard
            echo "$PASSWORD" | pbcopy
            # Paste the password
            # paste_content

            # Show notification
            osascript -e "display notification \"Password for '$selected' copied to clipboard\" with title \"Password Manager\""

            # Clear clipboard after 30 minutes
            (
                sleep 1800  # 30 minutes
                # Only clear if the current clipboard content matches our password
                local CURRENT_CLIP=$(pbpaste)
                if [[ "$CURRENT_CLIP" = "$PASSWORD" ]]; then
                    echo "" | pbcopy
                    osascript -e "display notification \"Clipboard cleared for security\" with title \"Password Manager\""
                fi
            ) &

            echo "✔ Password for '$selected' copied to clipboard. Will be cleared in 30 minutes."
        else
            echo "❌ Error: Could not retrieve password for '$selected' from keychain"
            return 1
        fi
    else
        echo "No password selected"
        return 1
    fi
}

# Run the function
get_password
