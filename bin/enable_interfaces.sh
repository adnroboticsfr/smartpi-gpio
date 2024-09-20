#!/bin/bash

ARMBIAN_ENV="/boot/armbianEnv.txt"
BACKUP_ENV="/boot/armbianEnv_backup.txt"

# Function to create a backup of armbianEnv.txt
backup_armbian_env() {
    cp "$ARMBIAN_ENV" "$BACKUP_ENV"
    echo "Backup of armbianEnv.txt created at $BACKUP_ENV"
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
            echo "$overlay added to the overlays line"
        else
            echo "$overlay already present in the overlays line"
        fi
    else
        echo "overlays=$overlay" >> "$ARMBIAN_ENV"
        echo "overlays line created with $overlay"
    fi
}

# Function to remove an overlay
remove_overlay() {
    local overlay="$1"
    if grep -q "^overlays=" "$ARMBIAN_ENV"; then
        sed -i "/^overlays=/ s/ $overlay//" "$ARMBIAN_ENV"
        echo "$overlay removed from the overlays line"
    else
        echo "No overlays line found."
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
    echo "=== Enable Features Menu ==="
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
        echo "Invalid option. Please try again."
        sleep 2
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
            else
                add_overlay_if_missing "uart1"
            fi
            ;;
        5) 
            if grep -q "uart2" "$ARMBIAN_ENV"; then
                remove_overlay "uart2"
            else
                add_overlay_if_missing "uart2"
            fi
            ;;
        6) 
            if grep -q "uart3" "$ARMBIAN_ENV"; then
                remove_overlay "uart3"
            else
                add_overlay_if_missing "uart3"
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
echo "Changes made to overlays:"
grep "^overlays=" "$ARMBIAN_ENV"

# Prompt for reboot with countdown
echo "System will reboot in 10 seconds to apply changes..."
echo "Press any key to cancel the reboot."
backup_armbian_env

for i in {10..1}; do
    echo "$i..."
    sleep 1
done

if read -t 1 -n 1; then
    echo "Reboot canceled."
else
    echo "Rebooting now to apply changes..."
    reboot
fi
