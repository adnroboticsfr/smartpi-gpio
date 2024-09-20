#!/bin/bash

ARMBIAN_ENV="/boot/armbianEnv.txt"
BACKUP_ENV="/boot/armbianEnv_backup.txt"

# Function to create a backup of armbianEnv.txt
backup_armbian_env() {
    cp "$ARMBIAN_ENV" "$BACKUP_ENV"
    echo -e "\033[32mBackup of armbianEnv.txt created at $BACKUP_ENV\033[0m"
}

# Function to validate user input
validate_input() {
    [[ $1 =~ ^[1-8]$ ]]
}

# Function to remove UART baud rate configuration
remove_uart_configuration() {
    local uart="$1"
    # Use awk to filter out the line
    awk -v uart="${uart}_baud=" '!index($0, uart)' "$ARMBIAN_ENV" > "${ARMBIAN_ENV}.tmp" && mv "${ARMBIAN_ENV}.tmp" "$ARMBIAN_ENV"
    echo -e "\033[31mConfiguration for $uart removed from $ARMBIAN_ENV\033[0m"
}

# Function to add an overlay if it is not already present
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

# Function to remove an overlay and associated configurations
remove_overlay() {
    local overlay="$1"
    # Remove the overlay from the overlays line
    if grep -q "^overlays=" "$ARMBIAN_ENV"; then
        sed -i "/^overlays=/ s/ $overlay//" "$ARMBIAN_ENV"
        echo -e "\033[31m$overlay removed from the overlays line\033[0m"
    fi
    remove_uart_configuration "$overlay"
}

# Main loop to process user choices
while true; do
    echo "=== Choose an option to modify UARTs ==="
    echo "1) Enable UART1"
    echo "2) Disable UART1"
    echo "3) Enable UART2"
    echo "4) Disable UART2"
    echo "5) Enable UART3"
    echo "6) Disable UART3"
    echo "7) Exit"
    read -p "Enter your choice (1-7): " choice

    if ! validate_input "$choice"; then
        echo -e "\033[31mInvalid option. Please try again.\033[0m"
        continue
    fi

    case $choice in
        1) add_overlay_if_missing "uart1";;
        2) remove_overlay "uart1";;
        3) add_overlay_if_missing "uart2";;
        4) remove_overlay "uart2";;
        5) add_overlay_if_missing "uart3";;
        6) remove_overlay "uart3";;
        7) break;;
    esac
done

# Show changes before reboot
echo -e "\033[34mChanges made to overlays:\033[0m"
grep "^overlays=" "$ARMBIAN_ENV"

backup_armbian_env
