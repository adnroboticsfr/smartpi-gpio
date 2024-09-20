#!/bin/bash

ARMBIAN_ENV="/boot/armbianEnv.txt"
BACKUP_ENV="/boot/armbianEnv_backup.txt"

# Pin configuration table
declare -A pins=(... )  # Garde ta table de pins ici

# Function to display pin configuration
display_pin_config() {
    echo "=== Pin Configuration ==="
    echo "Pin# | Name                               | Linux GPIO"
    echo "------------------------------------------------------"
    for pin in {1..40}; do
        printf "%-5s | %-35s | %s\n" "$pin" "${pins[$pin]}" "$(get_gpio $pin)"
    done
    echo "------------------------------------------------------"
    echo "Exemples de composants :"
    echo "- Capteur I2C connecté à I2C1_SDA (GPIOA19)"
    echo "- Module UART connecté à UART2_TX (GPIOA0)"
    echo "- Module SPI connecté à SPI0_MOSI (GPIOC0)"
    echo "========================="
}

# Function to create a backup of armbianEnv.txt
backup_armbian_env() {
    cp "$ARMBIAN_ENV" "$BACKUP_ENV" && echo -e "\033[32mBackup created at $BACKUP_ENV\033[0m" || echo -e "\033[31mBackup failed.\033[0m"
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
            echo -e "\033[32m$overlay added\033[0m"
        else
            echo -e "\033[33m$overlay already present\033[0m"
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
        echo -e "\033[31m$overlay removed\033[0m"
    else
        echo "No overlays line found."
    fi
}

# Function to configure UART baud rate
configure_uart_baud_rate() {
    local uart="$1"
    read -p "Enter baud rate for $uart (default 115200): " baud_rate
    baud_rate=${baud_rate:-115200}
    
    if grep -q "^${uart}_baud=" "$ARMBIAN_ENV"; then
        sed -i "/^${uart}_baud=/ s/= .*/= $baud_rate/" "$ARMBIAN_ENV"
    else
        echo "${uart}_baud=$baud_rate" >> "$ARMBIAN_ENV"
    fi
    echo -e "\033[32m${uart}_baud set to $baud_rate\033[0m"
}

# Function to configure SPI frequency
configure_spi_frequency() {
    local spi="$1"
    read -p "Enter frequency for $spi (default 500000): " frequency
    frequency=${frequency:-500000}
    
    if grep -q "^${spi}_freq=" "$ARMBIAN_ENV"; then
        sed -i "/^${spi}_freq=/ s/= .*/= $frequency/" "$ARMBIAN_ENV"
    else
        echo "${spi}_freq=$frequency" >> "$ARMBIAN_ENV"
    fi
    echo -e "\033[32m${spi}_freq set to $frequency\033[0m"
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
}

# Function to display the menu
show_menu() {
    clear
    echo "=== Enable/Disable Interfaces Menu ==="
    echo "-------------------------------------------"
    echo "| No | Status | Feature                     |"
    echo "-------------------------------------------"
    echo "|  1 | [$(if grep -q "i2c1" "$ARMBIAN_ENV"; then echo "X"; else echo " "; fi)] | I2C1                    |"
    echo "|  2 | [$(if grep -q "i2c2" "$ARMBIAN_ENV"; then echo "X"; else echo " "; fi)] | I2C2                    |"
    echo "|  3 | [$(if grep -q "pwm" "$ARMBIAN_ENV"; then echo "X"; else echo " "; fi)] | PWM (GPIO à déclarer)   |"
    echo "|  4 | [$(if grep -q "uart1" "$ARMBIAN_ENV"; then echo "X"; else echo " "; fi)] | UART1                   |"
    echo "|  5 | [$(if grep -q "uart2" "$ARMBIAN_ENV"; then echo "X"; else echo " "; fi)] | UART2                   |"
    echo "|  6 | [$(if grep -q "uart3" "$ARMBIAN_ENV"; then echo "X"; else echo " "; fi)] | UART3                   |"
    echo "|  7 | [$(if grep -q "spi0" "$ARMBIAN_ENV"; then echo "X"; else echo " "; fi)] | SPI0                    |"
    echo "-------------------------------------------"
    echo "|  8 | Exit                                 |"
    echo "-------------------------------------------"
}

# Main loop to show the menu and process choices
while true; do
    display_pin_config
    show_dashboard
    show_menu
    read -p "Enter your choice (1-8): " choice

    if ! validate_input "$choice"; then
        echo -e "\033[31mInvalid option. Please try again.\033[0m"
        continue
    fi

    case $choice in
        1) 
            toggle_overlay "i2c1"
            ;;
        2) 
            toggle_overlay "i2c2"
            ;;
        3) 
            toggle_overlay "pwm"
            ;;
        4) 
            toggle_overlay "uart1"
            configure_uart_baud_rate "uart1"
            ;;
        5) 
            toggle_overlay "uart2"
            configure_uart_baud_rate "uart2"
            ;;
        6) 
            toggle_overlay "uart3"
            configure_uart_baud_rate "uart3"
            ;;
        7) 
            toggle_overlay "spi0"
            configure_spi_frequency "spi0"
            ;;
        8) 
            break
            ;;
    esac
done

# Show changes before reboot
echo -e "\033[34mChanges made to overlays:\033[0m"
grep "^overlays=" "$ARMBIAN_ENV"

# Prompt for reboot
echo -e "\033[33mSystem will reboot to apply changes...\033[0m"
backup_armbian_env

read -p "Press any key to cancel the reboot or wait for 10 seconds to reboot..." -t 10

if [ $? -eq 142 ]; then  # Check if the read timed out (i.e., user didn't press any key)
    echo "Rebooting now..."
    reboot
else
    echo -e "\033[31mReboot canceled.\033[0m"
fi
