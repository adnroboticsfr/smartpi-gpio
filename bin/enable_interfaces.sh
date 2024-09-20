#!/bin/bash

ARMBIAN_ENV="/boot/armbianEnv.txt"
BACKUP_ENV="/boot/armbianEnv_backup.txt"

# Pin configuration table
declare -A pins=(
    # Same pin configuration
)

# Function to display pin configuration
display_pin_config() {
    echo "=== Configuration des Pins ==="
    echo "Numéro | Nom                               | GPIO Linux"
    echo "------------------------------------------------------"
    for pin in "${!pins[@]}"; do
        printf "%-6s | %-35s | %s\n" "$pin" "${pins[$pin]}" "$(get_gpio $pin)"
    done
    echo "------------------------------------------------------"
    echo "========================="
}

# Function to get GPIO (mock function)
get_gpio() {
    # Logic to return GPIO, for now just return the pin number
    echo "$1"
}

# Function to create a backup of armbianEnv.txt
backup_armbian_env() {
    cp "$ARMBIAN_ENV" "$BACKUP_ENV"
    echo -e "\033[32mBackup of armbianEnv.txt created at $BACKUP_ENV\033[0m"
}

# Function to validate user input
validate_input() {
    [[ $1 =~ ^[1-8]$ ]]
}

# Function to add overlay if it is missing
add_overlay_if_missing() {
    local overlay="$1"
    if grep -q "^overlays=" "$ARMBIAN_ENV"; then
        if ! grep -q "$overlay" "$ARMBIAN_ENV"; then
            sed -i "/^overlays=/ s/$/ $overlay/" "$ARMBIAN_ENV"
            echo -e "\033[32m$overlay added to the overlays line\033[0m"
        else
            echo -e "\033[33m$overlay is already present in the overlays line\033[0m"
        fi
    else
        echo "overlays=$overlay" >> "$ARMBIAN_ENV"
        echo -e "\033[32mOverlays line created with $overlay\033[0m"
    fi
}

# Function to remove overlay
remove_overlay() {
    local overlay="$1"
    if grep -q "^overlays=" "$ARMBIAN_ENV"; then
        sed -i "/^overlays=/ s/ $overlay//" "$ARMBIAN_ENV"
        echo -e "\033[31m$overlay removed from the overlays line\033[0m"
    else
        echo "No overlays line found."
    fi
}

# Main loop to show the menu and process choices
while true; do
    display_pin_config
    show_dashboard
    show_menu
    read -p "Enter your choice (1-8): " choice

    if ! validate_input "$choice"; then
        echo -e "\033[31mInvalid option. Please try again.\033[0m"
        sleep 3
        continue
    fi

    case $choice in
        1) 
            if grep -q "i2c1" "$ARMBIAN_ENV"; then
                remove_overlay "i2c1"
            else
                add_overlay_if_missing "i2c1"
            fi
            ;;
        # Other cases (similar logic)
        8) break;;
    esac
done

# Show changes before reboot
echo -e "\033[34mChanges made to overlays:\033[0m"
grep "^overlays=" "$ARMBIAN_ENV"

# Reboot handling with cancellation option
backup_armbian_env
echo "Press any key within 10 seconds to cancel the reboot."
for i in $(seq 1 10); do
    echo -n "."
    sleep 1
    if read -t 0.1 -n 1; then
        echo -e "\n\033[31mReboot canceled.\033[0m"
        exit 0
    fi
done
echo -e "\nRebooting now..."
reboot
