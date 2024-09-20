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

# Function to remove an overlay and associated configurations
remove_overlay() {
    local overlay="$1"
    
    if grep -q "^overlays=" "$ARMBIAN_ENV"; then
        sed -i "/^overlays=/ s/ $overlay//" "$ARMBIAN_ENV"
        echo -e "\033[31m$overlay removed from the overlays line\033[0m"
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
        echo -e "\033[32m$uart baud rate updated to $baud_rate\033[0m"
    else
        echo "${uart}_baud=$baud_rate" >> "$ARMBIAN_ENV"
        echo -e "\033[32m${uart}_baud set to $baud_rate\033[0m"
    fi
}

# Function to display GPIO ports and their numbers
display_gpio_ports() {
    echo -e "\033[36m=== GPIO Ports ===\033[0m"
    echo -e "\033[32mPin#\tName\t\t\t\tLinux GPIO\033[0m"
    echo "----------------------------------------------------------"
    echo -e "\033[34m1\tSYS_3.3V\t\t\t\t-\033[0m"
    echo -e "\033[34m2\tVDD_5V\t\t\t\t\t-\033[0m"
    echo -e "\033[34m3\tI2C0_SDA/GPIOA12\t\t\t-\033[0m"
    echo -e "\033[34m4\tVDD_5V\t\t\t\t\t-\033[0m"
    echo -e "\033[34m5\tI2C0_SCL/GPIOA11\t\t\t-\033[0m"
    echo -e "\033[34m6\tGND\t\t\t\t\t-\033[0m"
    echo -e "\033[34m7\tGPIOG11\t\t\t203\t\033[0m"
    echo -e "\033[34m8\tUART1_TX/GPIOG6\t\t198\t\033[0m"
    echo -e "\033[34m9\tGND\t\t\t\t\t-\033[0m"
    echo -e "\033[34m10\tUART1_RX/GPIOG7\t\t199\t\033[0m"
    echo -e "\033[34m11\tUART2_TX/GPIOA0\t\t0\t\033[0m"
    echo -e "\033[34m12\tGPIOA6\t\t\t6\t\033[0m"
    echo -e "\033[34m13\tUART2_RTS/GPIOA2\t\t2\t\033[0m"
    echo -e "\033[34m14\tGND\t\t\t\t\t-\033[0m"
    echo -e "\033[34m15\tUART2_CTS/GPIOA3\t\t3\t\033[0m"
    echo -e "\033[34m16\tUART1_RTS/GPIOG8\t\t200\t\033[0m"
    echo -e "\033[34m17\tSYS_3.3V\t\t\t\t-\033[0m"
    echo -e "\033[34m18\tUART1_CTS/GPIOG9\t\t201\t\033[0m"
    echo -e "\033[34m19\tSPI0_MOSI/GPIOC0\t\t64\t\033[0m"
    echo -e "\033[34m20\tGND\t\t\t\t\t-\033[0m"
    echo -e "\033[34m21\tSPI0_MISO/GPIOC1\t\t65\t\033[0m"
    echo -e "\033[34m22\tUART2_RX/GPIOA1\t\t1\t\033[0m"
    echo -e "\033[34m23\tSPI0_CLK/GPIOC2\t\t66\t\033[0m"
    echo -e "\033[34m24\tSPI0_CS/GPIOC3\t\t67\t\033[0m"
    echo -e "\033[34m25\tGND\t\t\t\t\t-\033[0m"
    echo -e "\033[34m26\tSPDIF-OUT/GPIOA17\t\t17\t\033[0m"
    echo -e "\033[34m27\tI2C1_SDA/GPIOA19\t\t19\t\033[0m"
    echo -e "\033[34m28\tI2C1_SCL/GPIOA18\t\t18\t\033[0m"
    echo -e "\033[34m29\tGPIOA20\t\t\t20\t\033[0m"
    echo -e "\033[34m30\tGND\t\t\t\t\t-\033[0m"
    echo -e "\033[34m31\tGPIOA21\t\t\t21\t\033[0m"
    echo -e "\033[34m32\tGPIOA7\t\t\t7\t\033[0m"
    echo -e "\033[34m33\tGPIOA8\t\t\t8\t\033[0m"
    echo -e "\033[34m34\tGND\t\t\t\t\t-\033[0m"
    echo -e "\033[34m35\tUART3_CTS/SPI1_MISO/GPIOA16\t16\t\033[0m"
    echo -e "\033[34m36\tUART3_TX/SPI1_CS/GPIOA13\t13\t\033[0m"
    echo -e "\033[34m37\tGPIOA9\t\t\t9\t\033[0m"
    echo -e "\033[34m38\tUART3_RTS/SPI1_MOSI/GPIOA15\t15\t\033[0m"
    echo -e "\033[34m39\tGND\t\t\t\t\t-\033[0m"
    echo -e "\033[34m40\tUART3_RX/SPI1_CLK/GPIOA14\t14\t\033[0m"
    echo "----------------------------------------------------------"
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
        echo -e "\033[31mInvalid option. Please try again.\033[0m"
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
echo -e "\033[34mChanges made to overlays:\033[0m"
grep "^overlays=" "$ARMBIAN_ENV"

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
