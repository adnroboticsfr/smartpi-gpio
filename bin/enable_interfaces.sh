#!/bin/bash 

ARMBIAN_ENV="/boot/armbianEnv.txt"
BACKUP_ENV="/boot/armbianEnv_backup.txt"

# Define colors
COLOR_I2C="\033[32m"
COLOR_UART="\033[34m"
COLOR_VDD="\033[33m"
COLOR_GPIO="\033[35m"
COLOR_RESET="\033[0m"

# Function to create a backup of armbianEnv.txt
backup_armbian_env() {
    cp "$ARMBIAN_ENV" "$BACKUP_ENV"
    echo -e "\033[32mBackup of armbianEnv.txt created at $BACKUP_ENV\033[0m"
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
    else
        echo "${uart}_baud=$baud_rate" >> "$ARMBIAN_ENV"
        echo -e "\033[32m${uart}_baud set to $baud_rate\033[0m"
    fi
}

display_gpio_table() {
    echo -e "\n==================== GPIO Pinout ====================\n"
    echo -e "               Name                \t   Pins (Odd)      \t   (Even)              \t              Name"
    echo -e "====================================================="
    
    printf "${COLOR_VDD}   SYS_3.3V\t\t\t1\t\t\t\t2\t\t\t\t${COLOR_VDD}VDD_5V${COLOR_RESET}\n"
    printf "${COLOR_I2C}   I2C0_SDA/GPIOA12\t\t3\t\t\t\t4\t\t\t\t${COLOR_I2C}VDD_5V${COLOR_RESET}\n"
    printf "   I2C0_SCL/GPIOA11\t\t5\t\t\t\t6\t\t\t\tGND\n"
    printf "   GPIOG11\t\t\t7\t\t\t\t8\t\t\t\t${COLOR_UART}UART1_TX/GPIOG6${COLOR_RESET}\n"
    printf "   GND\t\t\t\t9\t\t\t\t10\t\t\t\t${COLOR_UART}UART1_RX/GPIOG7${COLOR_RESET}\n"
    printf "${COLOR_UART}   UART2_TX/GPIOA0\t\t11\t\t\t\t12\t\t\t\tGPIOA6${COLOR_RESET}\n"
    printf "   UART2_RTS/GPIOA2\t\t13\t\t\t\t14\t\t\t\tGND\n"
    printf "   UART2_CTS/GPIOA3\t\t15\t\t\t\t16\t\t\t\tUART1_RTS/GPIOG8\n"
    printf "   SYS_3.3V\t\t\t17\t\t\t\t18\t\t\t\tUART1_CTS/GPIOG9\n"
    printf "   ${COLOR_GPIO}SPI0_MOSI/GPIOC0${COLOR_RESET}\t19\t\t\t\t20\t\t\t\tGND\n"
    printf "   ${COLOR_GPIO}SPI0_MISO/GPIOC1${COLOR_RESET}\t21\t\t\t\t22\t\t\t\t${COLOR_UART}UART2_RX/GPIOA1${COLOR_RESET}\n"
    printf "   ${COLOR_GPIO}SPI0_CLK/GPIOC2${COLOR_RESET}\t23\t\t\t\t24\t\t\t\t${COLOR_GPIO}SPI0_CS/GPIOC3${COLOR_RESET}\n"
    printf "   GND\t\t\t\t25\t\t\t\t26\t\t\t\tSPDIF-OUT/GPIOA17\n"
    printf "   ${COLOR_I2C}I2C1_SDA/GPIOA19${COLOR_RESET}\t27\t\t\t\t28\t\t\t\t${COLOR_I2C}I2C1_SCL/GPIOA18${COLOR_RESET}\n"
    printf "   GPIOA20/PCM0_DOUT\t\t29\t\t\t\t30\t\t\t\tGND\n"
    printf "   GPIOA21/PCM0_DIN\t\t31\t\t\t\t32\t\t\t\tGPIOA7\n"
    printf "   GPIOA8\t\t\t33\t\t\t\t34\t\t\t\tGND\n"
    printf "   UART3_CTS/SPI1_MISO/GPIOA16\t35\t\t\t\t36\t\t\t\tUART3_TX/SPI1_CS/GPIOA13\n"
    printf "   GPIOA9\t\t\t37\t\t\t\t38\t\t\t\tUART3_RTS/SPI1_MOSI/GPIOA15\n"
    printf "   GND\t\t\t\t39\t\t\t\t40\t\t\t\tUART3_RX/SPI1_CLK/GPIOA14\n"
    
    echo -e "=====================================================\n"
}




# Function to show the dashboard
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
    echo ""
    echo "--------------------------------------------------------------"
    echo "|      === Enable/Disable Interfaces Menu ===                |"
    echo "--------------------------------------------------------------"
    echo ""
    echo "Please select options to enable or disable, and choose"
    echo "an interface to configure:"
    echo "--------------------------------------------------------------"
    echo "| No | Status | Interfaces                                   |"
    echo "--------------------------------------------------------------"
    echo "|  1 |  [$(if grep -q "pwm" "$ARMBIAN_ENV"; then echo "X"; else echo " "; fi)]   | PWM (GPIO pin to configure:servomotors,LEDs) |"    
    echo "|  2 |  [$(if grep -q "i2c1" "$ARMBIAN_ENV"; then echo "X"; else echo " "; fi)]   | I2C1 (SDA: GPIOA19[27], SCL: GPIOA18[28])    |"
    echo "|  3 |  [$(if grep -q "i2c2" "$ARMBIAN_ENV"; then echo "X"; else echo " "; fi)]   | I2C2 (SDA: GPIOA12[3], SCL: GPIOA11[4])      |"
    echo "|  4 |  [$(if grep -q "uart1" "$ARMBIAN_ENV"; then echo "X"; else echo " "; fi)]   | UART1 (TX: GPIOG6[8], RX: GPIOG7[10])        |"
    echo "|  5 |  [$(if grep -q "uart2" "$ARMBIAN_ENV"; then echo "X"; else echo " "; fi)]   | UART2 (TX: GPIOA0[11], RX: GPIOA1[22])       |"
    echo "|  6 |  [$(if grep -q "uart3" "$ARMBIAN_ENV"; then echo "X"; else echo " "; fi)]   | UART3 (TX: GPIOA16[35], RX: GPIOA14[40])     |"
    echo "|  7 |  [$(if grep -q "spi0" "$ARMBIAN_ENV"; then echo "X"; else echo " "; fi)]   | SPI0 (MOSI: GPIOC0[19], MISO: GPIOC1[21])    |"
    echo "--------------------------------------------------------------"
    echo "|  8 | Display GPIO Pinout                                   |"
    echo "--------------------------------------------------------------"
    echo "|  9 | Exit                                                  |"
    echo "--------------------------------------------------------------"
}

# Main loop to show the menu and process choices
while true; do
    show_dashboard
    show_menu
    read -p "Enter your choice (1-9): " choice

    if ! validate_input "$choice"; then
        echo -e "\033[31mInvalid option. Please try again.\033[0m"
        continue
    fi

    case $choice in
        1)
            if grep -q "pwm" "$ARMBIAN_ENV"; then
                remove_overlay "pwm"
            else
                add_overlay_if_missing "pwm"
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
            if grep -q "i2c1" "$ARMBIAN_ENV"; then
                remove_overlay "i2c1"
            else
                add_overlay_if_missing "i2c1"
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
        8) 
            display_gpio_table
            read -p "Press any key to return to the menu..."
            ;;
        9) 
            echo "Exiting..."
            # Prompt for reboot
            echo "System will reboot in 5 seconds to apply changes..."
            echo "Press any key to cancel the reboot."
            sleep 5 & wait $!
            if [ $? -eq 0 ]; then
                echo "Reboot canceled."
            else
                echo "Rebooting now to apply changes..."
                reboot
            fi
            break
            ;;
        *)
            echo -e "\033[31mInvalid option. Please try again.\033[0m"
            ;;
    esac
done
