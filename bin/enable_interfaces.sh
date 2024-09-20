#!/bin/bash

ARMBIAN_ENV="/boot/armbianEnv.txt"

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

# Function to display the menu
show_menu() {
    echo "=== Enable Features Menu ==="
    echo "Select options to enable:"
    echo "1) I2C1 - Inter-Integrated Circuit Bus 1 (Pins 27/28)"
    echo "2) I2C2 - Inter-Integrated Circuit Bus 2 (Pins not specified)"
    echo "3) PWM - Pulse Width Modulation (Check specific pins on your board)"
    echo "4) UART1 - Universal Asynchronous Receiver-Transmitter (Pins 7/8)"
    echo "5) UART2 - Universal Asynchronous Receiver-Transmitter (Pins 11/12)"
    echo "6) UART3 - Universal Asynchronous Receiver-Transmitter (Pins 37/38)"
    echo "7) SPI0 - Serial Peripheral Interface (Pins 19/20/21/22)"
    echo "8) Exit"
    read -p "Enter your choice (1-8): " choice
}

# Main loop to show the menu and process choices
while true; do
    show_menu
    case $choice in
        1) add_overlay_if_missing "i2c1";;
        2) add_overlay_if_missing "i2c2";;
        3) add_overlay_if_missing "pwm";;
        4) add_overlay_if_missing "uart1";;
        5) add_overlay_if_missing "uart2";;
        6) add_overlay_if_missing "uart3";;
        7) add_overlay_if_missing "spi0";;
        8) break;;
        *) echo "Invalid option. Please try again.";;
    esac
done

# Prompt for reboot
echo "System will reboot in 10 seconds to apply changes..."
echo "Press any key to cancel the reboot."
sleep 10 & wait $!
if [ $? -eq 0 ]; then
    echo "Reboot canceled."
else
    echo "Rebooting now to apply changes..."
    reboot
fi
