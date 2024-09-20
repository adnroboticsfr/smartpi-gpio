#!/bin/bash

ARMBIAN_ENV="/boot/armbianEnv.txt"
BACKUP_ENV="/boot/armbianEnv_backup.txt"

# Pin configuration table
declare -A pins=(
    [1]="SYS_3.3V"
    [2]="VDD_5V"
    [3]="I2C0_SDA/GPIOA12"
    [4]="VDD_5V"
    [5]="I2C0_SCL/GPIOA11"
    [6]="GND"
    [7]="GPIOG11"
    [8]="UART1_TX/GPIOG6"
    [9]="GND"
    [10]="UART1_RX/GPIOG7"
    [11]="UART2_TX/GPIOA0"
    [12]="GPIOA6"
    [13]="UART2_RTS/GPIOA2"
    [14]="GND"
    [15]="UART2_CTS/GPIOA3"
    [16]="UART1_RTS/GPIOG8"
    [17]="SYS_3.3V"
    [18]="UART1_CTS/GPIOG9"
    [19]="SPI0_MOSI/GPIOC0"
    [20]="GND"
    [21]="SPI0_MISO/GPIOC1"
    [22]="UART2_RX/GPIOA1"
    [23]="SPI0_CLK/GPIOC2"
    [24]="SPI0_CS/GPIOC3"
    [25]="GND"
    [26]="SPDIF-OUT/GPIOA17"
    [27]="I2C1_SDA/GPIOA19"
    [28]="I2C1_SCL/GPIOA18"
    [29]="GPIOA20"
    [30]="GND"
    [31]="GPIOA21"
    [32]="GPIOA7"
    [33]="GPIOA8"
    [34]="GND"
    [35]="UART3_CTS/SPI1_MISO/GPIOA16"
    [36]="UART3_TX/SPI1_CS/GPIOA13"
    [37]="GPIOA9"
    [38]="UART3_RTS/SPI1_MOSI/GPIOA15"
    [39]="GND"
    [40]="UART3_RX/SPI1_CLK/GPIOA14"
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
    echo "Exemples de composants :"
    echo "- Capteur I2C connecté à I2C1_SDA (GPIOA19[27])"
    echo "- Module UART connecté à UART2_TX (GPIOA0[11])"
    echo "- Module SPI connecté à SPI0_MOSI (GPIOC0[19])"
    echo "========================="
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

# Function to add an overlay if it is not already present
add_overlay_if_missing() {
    local overlay="$1"
    if grep -q "^overlays=" "$ARMBIAN_ENV"; then
        if ! grep -q "$overlay" "$ARMBIAN_ENV"; then
            sed -i "/^overlays=/ s/$/ $overlay/" "$ARMBIAN_ENV"
            echo -e "\033[32m$overlay added to the overlays line\033[0m"
            sleep 3
        else
            echo -e "\033[33m$overlay is already present in the overlays line\033[0m"
            sleep 3
        fi
    else
        echo "overlays=$overlay" >> "$ARMBIAN_ENV"
        echo -e "\033[32mOverlays line created with $overlay\033[0m"
        sleep 3
    fi
}

# Function to remove an overlay
remove_overlay() {
    local overlay="$1"
    if grep -q "^overlays=" "$ARMBIAN_ENV"; then
        sed -i "/^overlays=/ s/ $overlay//" "$ARMBIAN_ENV"
        echo -e "\033[31m$overlay removed from the overlays line\033[0m"
        sleep 3
    else
        echo "No overlays line found."
    fi
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
        sleep 3
    else
        echo "${uart}_baud=$baud_rate" >> "$ARMBIAN_ENV"
        echo -e "\033[32m${uart}_baud set to $baud_rate\033[0m"
        sleep 3
    fi
}

# Function to configure SPI frequency
configure_spi_frequency() {
    local spi="$1"
    echo "Configuring frequency for $spi."
    read -p "Enter frequency for $spi (default is 500000, or press Enter to keep): " frequency
    frequency=${frequency:-500000}
    
    if grep -q "^${spi}_freq=" "$ARMBIAN_ENV"; then
        sed -i "/^${spi}_freq=/ s/= .*/= $frequency/" "$ARMBIAN_ENV"
        echo -e "\033[32m$spi frequency updated to $frequency\033[0m"
        sleep 3
    else
        echo "${spi}_freq=$frequency" >> "$ARMBIAN_ENV"
        echo -e "\033[32m${spi}_freq set to $frequency\033[0m"
        sleep 3
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
    echo "Enable/Disable une interface :"
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
    show_menu
    display_pin_config

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
