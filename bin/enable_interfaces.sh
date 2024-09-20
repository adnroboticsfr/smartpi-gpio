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

# Function to remove an overlay
remove_overlay() {
    local overlay="$1"
    if grep -q "^overlays=" "$ARMBIAN_ENV"; then
        sed -i "/^overlays=/ s/ $overlay//" "$ARMBIAN_ENV"
        echo -e "\033[31m$overlay removed from the overlays line\033[0m"
    else
        echo "No overlays line found."
    fi
}

# Function to configure UART baud rate
configure_uart_baud_rate() {
    local uart="$1"
    local default_baud=115200
    local baud_rate

    # Check if a baud rate is already set
    if grep -q "^${uart}_baud=" "$ARMBIAN_ENV"; then
        baud_rate=$(grep "^${uart}_baud=" "$ARMBIAN_ENV" | cut -d'=' -f2)
        echo -e "\033[33mCurrent baud rate for $uart is $baud_rate (default is $default_baud)\033[0m"
    else
        baud_rate=$default_baud
    fi

    # Prompt user for new baud rate or to keep the default
    read -p "Enter new baud rate for $uart (or press Enter to keep $baud_rate): " new_baud_rate
    if [[ -n $new_baud_rate ]]; then
        baud_rate=$new_baud_rate
    fi

    # Update the baud rate configuration
    if grep -q "^${uart}_baud=" "$ARMBIAN_ENV"; then
        sed -i "/^${uart}_baud=/ s/= .*/= $baud_rate/" "$ARMBIAN_ENV"
        echo -e "\033[32m$uart baud rate updated to $baud_rate\033[0m"
    else
        echo "${uart}_baud=$baud_rate" >> "$ARMBIAN_ENV"
        echo -e "\033[32m${uart}_baud set to $baud_rate\033[0m"
    fi
}

# Function to display the dashboard
show_dashboard() {
    clear
    echo "=== Dashboard ==="
    echo "Current Overlays:"
    if grep -q "^overlays=" "$ARMBIAN_ENV"; then
        grep "^overlays=" "$ARMBIAN_ENV" | cut -d'=' -f2
    else
        echo "No overlays currently set."
    fi
    echo "=================="
    echo ""
}

# Function to display the menu
show_menu() {
    clear
    echo "=== Enable/Disable Interfaces Menu ==="
    echo "Please select options to enable or disable:"
    echo "-------------------------------------------"
    echo "| No | Status | Feature                             |"
    echo "-------------------------------------------"
    echo "|  1 | [$(if grep -q "i2c1" "$ARMBIAN_ENV"; then echo "X"; else echo " "; fi)] | I2C1                             |"
    echo "|  2 | [$(if grep -q "i2c2" "$ARMBIAN_ENV"; then echo "X"; else echo " "; fi)] | I2C2                             |"
    echo "|  3 | [$(if grep -q "pwm" "$ARMBIAN_ENV"; then echo "X"; else echo " "; fi)] | PWM                              |"
    echo "|  4 | [$(if grep -q "uart1" "$ARMBIAN_ENV"; then echo "X"; else echo " "; fi)] | UART1                            |"
    echo "|  5 | [$(if grep -q "uart2" "$ARMBIAN_ENV"; then echo "X"; else echo " "; fi)] | UART2                            |"
    echo "|  6 | [$(if grep -q "uart3" "$ARMBIAN_ENV"; then echo "X"; else echo " "; fi)] | UART3                            |"
    echo "|  7 | [$(if grep -q "spi0" "$ARMBIAN_ENV"; then echo "X"; else echo " "; fi)] | SPI0                             |"
    echo "-------------------------------------------"
    echo "|  8 | Exit                                     |"
    echo "-------------------------------------------"
}

# Main loop to show the menu and process choices
while true; do
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
        2) 
            if grep -q "i2c2" "$ARMBIAN_ENV"; then
                remove_overlay "i2c2"
            else
                add_overlay_if_missing "i2c2"
            fi
            ;;
        3) 
            if grep -q "pwm" "$ARMBIAN_ENV"; then
                remove_overlay "pwm"
            else
                add_overlay_if_missing "pwm"
            fi
            ;;
        4) 
            if grep -q "uart1" "$ARMBIAN_ENV"; then
                remove_overlay "uart1"
                sed -i "/^uart1_baud=/d" "$ARMBIAN_ENV"  # Supprimer la configuration du baud rate
                echo -e "\033[31mUART1 configuration removed.\033[0m"
            else
                add_overlay_if_missing "uart1"
                echo -e "\033[32mUART1 enabled.\033[0m"
                configure_uart_baud_rate "uart1"
            fi
            ;;
        5) 
            if grep -q "uart2" "$ARMBIAN_ENV"; then
                remove_overlay "uart2"
                sed -i "/^uart2_baud=/d" "$ARMBIAN_ENV"  # Supprimer la configuration du baud rate
                echo -e "\033[31mUART2 configuration removed.\033[0m"
            else
                add_overlay_if_missing "uart2"
                echo -e "\033[32mUART2 enabled.\033[0m"
                configure_uart_baud_rate "uart2"
            fi
            ;;
        6) 
            if grep -q "uart3" "$ARMBIAN_ENV"; then
                remove_overlay "uart3"
                sed -i "/^uart3_baud=/d" "$ARMBIAN_ENV"  # Supprimer la configuration du baud rate
                echo -e "\033[31mUART3 configuration removed.\033[0m"
            else
                add_overlay_if_missing "uart3"
                echo -e "\033[32mUART3 enabled.\033[0m"
                configure_uart_baud_rate "uart3"
            fi
            ;;
        7) 
            if grep -q "spi0" "$ARMBIAN_ENV"; then
                remove_overlay "spi0"
            else
                add_overlay_if_missing "spi0"
            fi
            ;;
        8) break;;
    esac
done

# Show changes before reboot
echo -e "\033[34mChanges made to overlays:\033[0m"
grep "^overlays=" "$ARMBIAN_ENV"

# Prompt for reboot with animated points
echo -e "\033[33mSystem will reboot in a moment to apply changes...\033[0m"
echo "Press any key to cancel the reboot."
backup_armbian_env

while true; do
    echo -n "."
    sleep 1
    if read -t 0.1 -n 1; then
        echo -e "\n\033[31mReboot canceled.\033[0m"
        break
    fi
done

if [ $? -eq 0 ]; then
    echo "Rebooting now..."
    reboot
fi
