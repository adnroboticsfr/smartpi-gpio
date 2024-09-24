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
    echo -e "\n======================--[ GPIO Pinout - SMART PI ONE ]--======================\n"
    echo -e "              Name          \t     Pins               Name"
    echo -e "=============================================================================="
    
    printf "\t${COLOR_VDD}    SYS_3.3V${COLOR_RESET}\t\t( 1 )\t( 2 )\t       ${COLOR_VDD}VDD_5V${COLOR_RESET}\n"
    printf "\t${COLOR_I2C}I2C0_SDA${COLOR_RESET}/GPIOA12\t( 3 )\t( 4 )\t       ${COLOR_VDD}VDD_5V${COLOR_RESET}\n"
    printf "\t${COLOR_I2C}I2C0_SCL${COLOR_RESET}/GPIOA11\t( 5 )\t( 6 )\t         ${COLOR_VDD}GND${COLOR_RESET}\n"
    printf "\t     GPIOG11\t\t( 7 )\t( 8 )\t   ${COLOR_UART}UART1_TX${COLOR_RESET}/GPIOG6\n"
    printf "\t      ${COLOR_VDD}GND${COLOR_RESET}\t\t( 9 )\t( 10 )\t   ${COLOR_UART}UART1_RX${COLOR_RESET}/GPIOG7\n"
    printf "\t${COLOR_UART}UART2_TX${COLOR_RESET}/GPIOA0\t\t( 11 )\t( 12 )\t        GPIOA6\n"
    printf "\t${COLOR_UART}UART2_RTS${COLOR_RESET}/GPIOA2\t( 13 )\t( 14 )\t         ${COLOR_VDD}GND${COLOR_RESET}\n"
    printf "\t${COLOR_UART}UART2_CTS${COLOR_RESET}/GPIOA3\t( 15 )\t( 16 )\t   ${COLOR_UART}UART1_RTS${COLOR_RESET}/GPIOG8\n"
    printf "\t${COLOR_VDD}    SYS_3.3V${COLOR_RESET}\t\t( 17 )\t( 18 )\t   ${COLOR_UART}UART1_CTS${COLOR_RESET}/GPIOG9\n"
    printf "\t${COLOR_GPIO}SPI0_MOSI${COLOR_RESET}/GPIOC0\t( 19 )\t( 20 )\t         ${COLOR_VDD}GND${COLOR_RESET}\n"
    printf "\t${COLOR_GPIO}SPI0_MISO${COLOR_RESET}/GPIOC1\t( 21 )\t( 22 )\t   ${COLOR_UART}UART2_RX${COLOR_RESET}/GPIOA1\n"
    printf "\t${COLOR_GPIO}SPI0_CLK${COLOR_RESET}/GPIOC2\t\t( 23 )\t( 24 )\t   ${COLOR_GPIO}SPI0_CS${COLOR_RESET}/GPIOC3\n"
    printf "\t      ${COLOR_VDD}GND${COLOR_RESET}\t\t( 25 )\t( 26 )\t   SPDIF-OUT/GPIOA17\n"
    printf "\t${COLOR_I2C}I2C1_SDA${COLOR_RESET}/GPIOA19\t( 27 )\t( 28 )\t   ${COLOR_I2C}I2C1_SCL${COLOR_RESET}/GPIOA18\n"
    printf "\tGPIOA20/PCM0_DOUT\t( 29 )\t( 30 )\t         ${COLOR_VDD}GND${COLOR_RESET}\n"
    printf "\tGPIOA21/PCM0_DIN\t( 31 )\t( 32 )\t        GPIOA7\n"
    printf "\t     GPIOA8\t\t( 33 )\t( 34 )\t         ${COLOR_VDD}GND${COLOR_RESET}\n"
    printf "   ${COLOR_UART}UART3_CTS${COLOR_RESET}/${COLOR_GPIO}SPI1_MISO${COLOR_RESET}/GPIOA16\t( 35 )\t( 36 )  ${COLOR_UART}UART3_TX${COLOR_RESET}/${COLOR_GPIO}SPI1_CS${COLOR_RESET}/GPIOA13\n"
    printf "\t     GPIOA9\t\t( 37 )\t( 38 )  ${COLOR_UART}UART3_RTS${COLOR_RESET}/${COLOR_GPIO}SPI1_MOSI${COLOR_RESET}/GPIOA15\n"
    printf "\t      ${COLOR_VDD}GND${COLOR_RESET}\t\t( 39 )\t( 40 )  ${COLOR_UART}UART3_RX${COLOR_RESET}/${COLOR_GPIO}SPI1_CLK${COLOR_RESET}/GPIOA14\n"
    
    echo -e "=============================================================================\n"
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
    echo "-------------------------------------------------------------------"
    echo "|           === Enable/Disable Interfaces Menu ===                |"
    echo "-------------------------------------------------------------------"
    echo ""
    echo "Please select options to enable or disable, and choose an interface "
    echo "to configure:"
    echo "-------------------------------------------------------------------"
    echo "| No | Status | Interfaces                                        |"
    echo "-------------------------------------------------------------------"
    echo "|  1 |  [$(if grep -q "pwm" "$ARMBIAN_ENV"; then echo "X"; else echo " "; fi)]   | PWM (GPIO PIN to configure:servomotors,LEDs)      |"    
    echo "|  2 |  [$(if grep -q "i2c1" "$ARMBIAN_ENV"; then echo "X"; else echo " "; fi)]   | I2C1 (SDA: GPIOA19[27], SCL: GPIOA18[28])         |"
    echo "|  3 |  [$(if grep -q "i2c2" "$ARMBIAN_ENV"; then echo "X"; else echo " "; fi)]   | I2C2 (SDA: GPIOA12[3], SCL: GPIOA11[4])           |"
    echo "|  4 |  [$(if grep -q "spi" "$ARMBIAN_ENV"; then echo "X"; else echo " "; fi)]   | SPI (CS: GPIOC3[26], MOSI: GPIOC0[19], MISO: GPIOC1[21], CLK: GPIOC2[23]) |"
    echo "|  5 |  [$(if grep -q "uart" "$ARMBIAN_ENV"; then echo "X"; else echo " "; fi)]   | UART (TX: GPIOG6[8], RX: GPIOG7[10])               |"
    echo "-------------------------------------------------------------------"
    echo "Please enter your choice (1-5) or 'q' to quit:"
}

# Main loop
while true; do
    show_menu
    read -t 5 -n 1 option

    if [[ $option == 'q' ]]; then
        echo "Exiting menu."
        exit 0
    elif validate_input "$option"; then
        case $option in
            1)
                if grep -q "pwm" "$ARMBIAN_ENV"; then
                    echo "Disabling PWM."
                    remove_overlay "pwm"
                else
                    echo "Enabling PWM."
                    add_overlay_if_missing "pwm"
                fi
                ;;
            2)
                if grep -q "i2c1" "$ARMBIAN_ENV"; then
                    echo "Disabling I2C1."
                    remove_overlay "i2c1"
                else
                    echo "Enabling I2C1."
                    add_overlay_if_missing "i2c1"
                fi
                ;;
            3)
                if grep -q "i2c2" "$ARMBIAN_ENV"; then
                    echo "Disabling I2C2."
                    remove_overlay "i2c2"
                else
                    echo "Enabling I2C2."
                    add_overlay_if_missing "i2c2"
                fi
                ;;
            4)
                if grep -q "spi" "$ARMBIAN_ENV"; then
                    echo "Disabling SPI."
                    remove_overlay "spi"
                else
                    echo "Enabling SPI."
                    add_overlay_if_missing "spi"
                fi
                ;;
            5)
                if grep -q "uart" "$ARMBIAN_ENV"; then
                    echo "Disabling UART."
                    remove_overlay "uart"
                else
                    echo "Enabling UART."
                    add_overlay_if_missing "uart"
                fi
                ;;
            *)
                echo "Invalid option."
                ;;
        esac
        sleep 1
    else
        echo "Invalid input. Please enter a number from 1 to 5."
        sleep 1
    fi

    show_dashboard
done
