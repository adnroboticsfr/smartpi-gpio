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
            echo "$overlay is already present in the overlays line"
        fi
    else
        echo "overlays=$overlay" >> "$ARMBIAN_ENV"
        echo "Overlays line created with $overlay"
    fi
}

# Function to remove an overlay and associated configurations
remove_overlay() {
    local overlay="$1"
    
    if grep -q "^overlays=" "$ARMBIAN_ENV"; then
        sed -i "/^overlays=/ s/ $overlay//" "$ARMBIAN_ENV"
        echo "$overlay removed from the overlays line"
    fi

    remove_uart_configuration "$overlay"
}

# Function to remove UART baud rate configuration
remove_uart_configuration() {
    local uart="$1"
    
    local temp_file=$(mktemp)

    while IFS= read -r line; do
        if [[ "$line" != "${uart}_baud="* ]]; then
            echo "$line" >> "$temp_file"
        fi
    done < "$ARMBIAN_ENV"
    
    mv "$temp_file" "$ARMBIAN_ENV"
}

# Function to configure UART baud rate
configure_uart_baud_rate() {
    local uart="$1"
    echo "Configuring baud rate for $uart."
    read -p "Enter baud rate for $uart (default is 115200, or press Enter to keep): " baud_rate
    baud_rate=${baud_rate:-115200}
    
    if grep -q "^${uart}_baud=" "$ARMBIAN_ENV"; then
        sed -i "/^${uart}_baud=/ s/= .*/= $baud_rate/" "$ARMBIAN_ENV"
        echo "$uart baud rate updated to $baud_rate"
    else
        echo "${uart}_baud=$baud_rate" >> "$ARMBIAN_ENV"
        echo "${uart}_baud set to $baud_rate"
    fi
}

# Function to display GPIO ports and their numbers
display_gpio_ports() {
    echo "=== GPIO Ports ==="
    echo "Pin#  Name                             Linux GPIO"
    echo "-------------------------------------------------"
    echo "1     SYS_3.3V                       -"
    echo "2     VDD_5V                         -"
    echo "3     I2C0_SDA/GPIOA12               -"
    echo "4     VDD_5V                         -"
    echo "5     I2C0_SCL/GPIOA11               -"
    echo "6     GND                             -"
    echo "7     GPIOG11                        203"
    echo "8     UART1_TX/GPIOG6                198"
    echo "9     GND                             -"
    echo "10    UART1_RX/GPIOG7                199"
    echo "11    UART2_TX/GPIOA0                 0"
    echo "12    GPIOA6                          6"
    echo "13    UART2_RTS/GPIOA2                2"
    echo "14    GND                             -"
    echo "15    UART2_CTS/GPIOA3                3"
    echo "16    UART1_RTS/GPIOG8                200"
    echo "17    SYS_3.3V                       -"
    echo "18    UART1_CTS/GPIOG9                201"
    echo "19    SPI0_MOSI/GPIOC0                64"
    echo "20    GND                             -"
    echo "21    SPI0_MISO/GPIOC1                65"
    echo "22    UART2_RX/GPIOA1                 1"
    echo "23    SPI0_CLK/GPIOC2                 66"
    echo "24    SPI0_CS/GPIOC3                  67"
    echo "25    GND                             -"
    echo "26    SPDIF-OUT/GPIOA17               17"
    echo "27    I2C1_SDA/GPIOA19                19"
    echo "28    I2C1_SCL/GPIOA18                18"
    echo "29    GPIOA20                          20"
    echo "30    GND                             -"
    echo "31    GPIOA21                          21"
    echo "32    GPIOA7                           7"
    echo "33    GPIOA8                           8"
    echo "34    GND                             -"
    echo "35    UART3_CTS/SPI1_MISO/GPIOA16     16"
    echo "36    UART3_TX/SPI1_CS/GPIOA13        13"
    echo "37    GPIOA9                           9"
    echo "38    UART3_RTS/SPI1_MOSI/GPIOA15     15"
    echo "39    GND                             -"
    echo "40    UART3_RX/SPI1_CLK/GPIOA14       14"
    echo "-------------------------------------------------"
    read -p "Press any key to continue..."  # Attendre l'entrée de l'utilisateur
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
    echo "|  1 | [$(if grep -q "i2c1" "$ARMBIAN_ENV"; then echo "X"; else echo " "; fi)] | I2C1 (SDA: GPIOA19[27], SCL: GPIOA18[28])  |"
    echo "|  2 | [$(if grep -q "i2c2" "$ARMBIAN_ENV"; then echo "X"; else echo " "; fi)] | I2C2 (SDA: GPIOA12[3], SCL: GPIOA11[4])  |"
    echo "|  3 | [$(if grep -q "pwm" "$ARMBIAN_ENV"; then echo "X"; else echo " "; fi)] | PWM (GPIO à déclarer)              |"
    echo "|  4 | [$(if grep -q "uart1" "$ARMBIAN_ENV"; then echo "X"; else echo " "; fi)] | UART1 (TX: GPIOG6[8], RX: GPIOG7[10])     |"
    echo "|  5 | [$(if grep -q "uart2" "$ARMBIAN_ENV"; then echo "X"; else echo " "; fi)] | UART2 (TX: GPIOA0[11], RX: GPIOA1[22])     |"
    echo "|  6 | [$(if grep -q "uart3" "$ARMBIAN_ENV"; then echo "X"; else echo " "; fi)] | UART3 (TX: GPIOA16[35], RX: GPIOA14[40])   |"
    echo "|  7 | [$(if grep -q "spi0" "$ARMBIAN_ENV"; then echo "X"; else echo " "; fi)] | SPI0 (MOSI: GPIOC0[19], MISO: GPIOC1[21])  |"
    echo "-------------------------------------------"
    echo "|  8 | Exit                                     |"
    echo "-------------------------------------------"
}

# Main loop to show the menu and process choices
while true; do
    show_dashboard
    display_gpio_ports  # Afficher les ports GPIO
    show_menu
    read -p "Enter your choice (1-8): " choice

    if ! validate_input "$choice"; then
        echo "Invalid option. Please try again."
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
                configure_uart_baud_rate "uart1"
            fi
            ;;
        5) 
            if grep -q "uart2" "$ARMBIAN_ENV"; then
                remove_overlay "uart2"
            else
                add_overlay_if_missing "uart2"
                configure_uart_baud_rate "uart2"
            fi
            ;;
        6) 
            if grep -q "uart3" "$ARMBIAN_ENV"; then
                remove_overlay "uart3"
            else
                add_overlay_if_missing "uart3"
                configure_uart_baud_rate "uart3"
            fi
            ;;
        7) 
            if grep -q "spi0" "$ARMBIAN_ENV"; then
                remove_overlay "spi0"
            else
                add_overlay_if_missing "spi0"
                configure_spi_frequency "spi0"
            fi
            ;;
        8) break;;
    esac
done

# Show changes before reboot
echo "Changes made to overlays:"
grep "^overlays=" "$ARMBIAN_ENV"

echo "System will reboot in a moment to apply changes..."
echo "Press any key to cancel the reboot."
backup_armbian_env

while true; do
    echo -n "."
    sleep 1
    if read -t 0.1 -n 1; then
        echo -e "\nReboot canceled."
        break
    fi
done

if [ $? -eq 0 ]; then
    echo "Rebooting now..."
    reboot
fi
