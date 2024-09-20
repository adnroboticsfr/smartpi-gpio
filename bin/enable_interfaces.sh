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

# Function to check if an overlay is already present
is_overlay_present() {
    local overlay="$1"
    grep -q "$overlay" "$ARMBIAN_ENV"
}

# Function to display the menu with checkboxes
show_menu() {
    clear  # Clear the screen before showing the menu
    echo "=== Enable Features Menu ==="
    echo "Select options to enable (default options are checked):"
    
    local options=(
        "1) I2C1 - Inter-Integrated Circuit Bus 1 (Pins 27/28)"
        "2) I2C2 - Inter-Integrated Circuit Bus 2 (Pins not specified)"
        "3) PWM - Pulse Width Modulation (Check specific pins on your board)"
        "4) UART1 - Universal Asynchronous Receiver-Transmitter (Pins 7/8)"
        "5) UART2 - Universal Asynchronous Receiver-Transmitter (Pins 11/12)"
        "6) UART3 - Universal Asynchronous Receiver-Transmitter (Pins 37/38)"
        "7) SPI0 - Serial Peripheral Interface (Pins 19/20/21/22)"
        "8) Configuration Options"
        "9) Exit"
    )

    for option in "${options[@]}"; do
        echo -n "$option "
        case $option in
            *I2C1*) if is_overlay_present "i2c1"; then echo "[x]"; else echo "[ ]"; fi ;;
            *I2C2*) if is_overlay_present "i2c2"; then echo "[x]"; else echo "[ ]"; fi ;;
            *PWM*) if is_overlay_present "pwm"; then echo "[x]"; else echo "[ ]"; fi ;;
            *UART1*) if is_overlay_present "uart1"; then echo "[x]"; else echo "[ ]"; fi ;;
            *UART2*) if is_overlay_present "uart2"; then echo "[x]"; else echo "[ ]"; fi ;;
            *UART3*) if is_overlay_present "uart3"; then echo "[x]"; else echo "[ ]"; fi ;;
            *SPI0*) if is_overlay_present "spi0"; then echo "[x]"; else echo "[ ]"; fi ;;
        esac
    done
}

# Function to configure parameters for overlays
configure_parameters() {
    echo "Configuration Options:"
    read -p "Enter I2C frequency (default 100000): " i2c_freq
    read -p "Enter UART1 baud rate (default 115200): " uart1_baud
    read -p "Enter UART2 baud rate (default 115200): " uart2_baud
    read -p "Enter UART3 baud rate (default 115200): " uart3_baud

    # You can handle the parameters here (e.g., write to a config file or modify overlays)
    echo "Configured I2C frequency: ${i2c_freq:-100000}"
    echo "Configured UART1 baud rate: ${uart1_baud:-115200}"
    echo "Configured UART2 baud rate: ${uart2_baud:-115200}"
    echo "Configured UART3 baud rate: ${uart3_baud:-115200}"
}

# Main loop to show the menu and process choices
while true; do
    show_menu
    read -p "Enter your choice (1-9): " choice
    case $choice in
        1) add_overlay_if_missing "i2c1";;
        2) add_overlay_if_missing "i2c2";;
        3) add_overlay_if_missing "pwm";;
        4) add_overlay_if_missing "uart1";;
        5) add_overlay_if_missing "uart2";;
        6) add_overlay_if_missing "uart3";;
        7) add_overlay_if_missing "spi0";;
        8) configure_parameters;;
        9) break;;
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
