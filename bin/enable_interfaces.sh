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
    [[ $1 =~ ^[1-9]$ ]]
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

# Function to display GPIO ports in two columns
display_gpio_ports() {
    echo "=== GPIO Ports ==="
    echo " Pin# | Name                          | Linux GPIO  |  Pin# | Name                          | Linux GPIO  "
    echo "------------------------------------------------------------------------------------------"

    for i in {1..40}; do
        case $i in
            1)  name="SYS_3.3V";  gpio="-";;
            2)  name="VDD_5V";    gpio="-";;
            3)  name="I2C0_SDA/GPIOA12"; gpio="-";;
            4)  name="VDD_5V";    gpio="-";;
            5)  name="I2C0_SCL/GPIOA11"; gpio="-";;
            6)  name="GND";       gpio="-";;
            7)  name="GPIOG11";   gpio="203";;
            8)  name="UART1_TX/GPIOG6"; gpio="198";;
            9)  name="GND";       gpio="-";;
            10) name="UART1_RX/GPIOG7"; gpio="199";;
            11) name="UART2_TX/GPIOA0"; gpio="0";;
            12) name="GPIOA6";    gpio="6";;
            13) name="UART2_RTS/GPIOA2"; gpio="2";;
            14) name="GND";       gpio="-";;
            15) name="UART2_CTS/GPIOA3"; gpio="3";;
            16) name="UART1_RTS/GPIOG8"; gpio="200";;
            17) name="SYS_3.3V";  gpio="-";;
            18) name="UART1_CTS/GPIOG9"; gpio="201";;
            19) name="SPI0_MOSI/GPIOC0"; gpio="64";;
            20) name="GND";       gpio="-";;
            21) name="SPI0_MISO/GPIOC1"; gpio="65";;
            22) name="UART2_RX/GPIOA1"; gpio="1";;
            23) name="SPI0_CLK/GPIOC2"; gpio="66";;
            24) name="SPI0_CS/GPIOC3"; gpio="67";;
            25) name="GND";       gpio="-";;
            26) name="SPDIF-OUT/GPIOA17"; gpio="17";;
            27) name="I2C1_SDA/GPIOA19"; gpio="19";;
            28) name="I2C1_SCL/GPIOA18"; gpio="18";;
            29) name="GPIOA20";   gpio="20";;
            30) name="GND";       gpio="-";;
            31) name="GPIOA21";   gpio="21";;
            32) name="GPIOA7";    gpio="7";;
            33) name="GPIOA8";    gpio="8";;
            34) name="GND";       gpio="-";;
            35) name="UART3_CTS/SPI1_MISO/GPIOA16"; gpio="16";;
            36) name="UART3_TX/SPI1_CS/GPIOA13"; gpio="13";;
            37) name="GPIOA9";    gpio="9";;
            38) name="UART3_RTS/SPI1_MOSI/GPIOA15"; gpio="15";;
            39) name="GND";       gpio="-";;
            40) name="UART3_RX/SPI1_CLK/GPIOA14"; gpio="14";;
        esac

        # Display in two columns
        if (( i % 2 != 0 )); then
            printf "  %3d | %-30s | %-11s |" "$i" "$name" "$gpio"
        else
            printf "  %3d | %-30s | %-11s\n" "$i" "$name" "$gpio"
        fi
    done
    echo "------------------------------------------------------------------------------------------"
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
    echo "|  8 | View GPIO Ports                      |"
    echo "|  9 | Exit                                 |"
    echo "-------------------------------------------"
}

# Main loop to show the menu and process choices
while true; do
    show_dashboard
    show_menu
    read -p "Enter your choice (1-9): " choice

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
        8)
            display_gpio_ports
            ;;
        9) break;;
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
