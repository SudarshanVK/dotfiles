# Function to add a new password to macOS Keychain
add_password() {
    echo "🔐 Add New Password to Keychain"
    echo "================================"

    # Prompt for service name
    echo -n "Service name (e.g., 'GitHub', 'MySQL'): "
    read service_name

    if [[ -z "$service_name" ]]; then
        echo "❌ Service name cannot be empty"
        return 1
    fi

    # Prompt for username
    echo -n "Username/Account: "
    read username

    if [[ -z "$username" ]]; then
        echo "❌ Username cannot be empty"
        return 1
    fi

    # Prompt for password (hidden input)
    echo -n "Password: "
    read -s password
    echo

    if [[ -z "$password" ]]; then
        echo "❌ Password cannot be empty"
        return 1
    fi

    # Confirm password (hidden input)
    echo -n "Confirm password: "
    read -s confirm_password
    echo

    # Check if passwords match
    if [[ "$password" != "$confirm_password" ]]; then
        echo "❌ Passwords don't match!"
        return 1
    fi

    # Check if entry already exists
    if security find-generic-password -a "$username" -s "$service_name" >/dev/null 2>&1; then
        echo "⚠️  Entry already exists for service '$service_name' with username '$username'"
        echo -n "Do you want to update it? (y/N): "
        read update_choice

        if [[ "$update_choice" =~ ^[Yy]$ ]]; then
            # Delete existing entry
            security delete-generic-password -a "$username" -s "$service_name"
        else
            echo "❌ Cancelled"
            return 1
        fi
    fi

    # Add password to keychain
    if security add-generic-password -a "$username" -s "$service_name" -w "$password"; then
        echo "✅ Password successfully added to Keychain!"
        echo "   Service: $service_name"
        echo "   Username: $username"
        echo ""
        echo "To retrieve this password later, use:"
        echo "   security find-generic-password -a \"$username\" -s \"$service_name\" -w | pbcopy"
    else
        echo "❌ Failed to add password to Keychain"
        return 1
    fi
}

# Function to update an existing password in macOS Keychain
update_password() {
    echo "🔄 Update Password in Keychain"
    echo "=============================="

    # Prompt for service name
    echo -n "Service name: "
    read service_name

    if [[ -z "$service_name" ]]; then
        echo "❌ Service name cannot be empty"
        return 1
    fi

    # Prompt for username
    echo -n "Username/Account: "
    read username

    if [[ -z "$username" ]]; then
        echo "❌ Username cannot be empty"
        return 1
    fi

    # Check if entry exists
    if ! security find-generic-password -a "$username" -s "$service_name" >/dev/null 2>&1; then
        echo "❌ No entry found for service '$service_name' with username '$username'"
        echo "💡 Use 'add_password' to create a new entry"
        return 1
    fi

    # Show current entry details (without password)
    echo "📋 Current entry found:"
    security find-generic-password -a "$username" -s "$service_name" 2>/dev/null | grep -E "(service|account|class)"
    echo ""

    # Prompt for new password
    echo -n "New password: "
    read -s new_password
    echo

    if [[ -z "$new_password" ]]; then
        echo "❌ Password cannot be empty"
        return 1
    fi

    # Confirm new password
    echo -n "Confirm new password: "
    read -s confirm_password
    echo

    # Check if passwords match
    if [[ "$new_password" != "$confirm_password" ]]; then
        echo "❌ Passwords don't match!"
        return 1
    fi

    # Delete old entry and add new one (macOS doesn't have direct update)
    if security delete-generic-password -a "$username" -s "$service_name" >/dev/null 2>&1 && \
       security add-generic-password -a "$username" -s "$service_name" -w "$new_password" >/dev/null 2>&1; then
        echo "✅ Password successfully updated!"
        echo "   Service: $service_name"
        echo "   Username: $username"
    else
        echo "❌ Failed to update password"
        return 1
    fi
}

# Function to delete a password from macOS Keychain
delete_password() {
    echo "🗑️  Delete Password from Keychain"
    echo "================================="

    # Prompt for service name
    echo -n "Service name: "
    read service_name

    if [[ -z "$service_name" ]]; then
        echo "❌ Service name cannot be empty"
        return 1
    fi

    # Prompt for username
    echo -n "Username/Account: "
    read username

    if [[ -z "$username" ]]; then
        echo "❌ Username cannot be empty"
        return 1
    fi

    # Check if entry exists
    if ! security find-generic-password -a "$username" -s "$service_name" >/dev/null 2>&1; then
        echo "❌ No entry found for service '$service_name' with username '$username'"
        return 1
    fi

    # Show current entry details (without password)
    echo "📋 Entry to be deleted:"
    security find-generic-password -a "$username" -s "$service_name" 2>/dev/null | grep -E "(service|account|class)"
    echo ""

    # Confirm deletion
    echo -n "⚠️  Are you sure you want to delete this password? (y/N): "
    read confirm_delete

    if [[ ! "$confirm_delete" =~ ^[Yy]$ ]]; then
        echo "❌ Deletion cancelled"
        return 1
    fi

    # Delete the entry
    if security delete-generic-password -a "$username" -s "$service_name" >/dev/null 2>&1; then
        echo "✅ Password successfully deleted!"
        echo "   Service: $service_name"
        echo "   Username: $username"
    else
        echo "❌ Failed to delete password"
        return 1
    fi
}

# Function to list all stored passwords (without showing actual passwords)
list_passwords() {
    echo "📋 Keychain items (Service → Account)"
    echo "------------------------------------"
    echo ""

    local output
    output=$(security dump-keychain 2>/dev/null | grep -E "(svce|acct)" | grep "svce" | cut -d'"' -f4 | sort -u)

    if [[ -z "$output" ]]; then
        echo "❌ No stored passwords found"
        return 0
    fi

    echo "$output" | awk '{ printf "%-4d %s\n", NR, $0 }' | sed 's/^/📋 /'
    echo ""
    echo "Total: $(echo "$output" | wc -l | tr -d ' ') item(s)"
}
