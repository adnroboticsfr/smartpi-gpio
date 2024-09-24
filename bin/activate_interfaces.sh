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
    echo -e "${COLOR_I2C}Backup of armbianEnv.txt created at $BACKUP_ENV${COLOR_RESET}"
}

# Function to validate user input
validate_input() {
    [[ $1 =~ ^[1-5]$ ]]
}

# Function to add an overlay if it is not already present
add_overlay_if_missing() {
    local overlay="$1"
    if grep -q "^overlays=" "$ARMBIAN_ENV"; then
        if ! grep -q "$overlay" "$ARMBIAN_ENV"; then
            sed -i "/^overlays=/ s/$/ $overlay/" "$ARMBIAN_ENV"
            echo -e "${COLOR_I2C}$overlay added to the overlays line${COLOR_RESET}"
        else
            echo -e "${COLOR_VDD}$overlay is already present in the overlays line${COLOR_RESET}"
        fi
    else
        echo "overlays=$overlay" >> "$ARMBIAN_ENV"
        echo -e "${COLOR_I2C}Overlays line created with $overlay${COLOR_RESET}"
    fi
}

# Function to remove an overlay
remove_overlay() {
    local overlay="$1"
    if grep -q "^overlays=" "$ARMBIAN_ENV"; then
        sed -i "/^overlays=/ s/\(.*\)$overlay\(.*\)/\1\2/" "$ARMBIAN_ENV"
        sed -i "/^overlays=/ s/  */ /g" "$ARMBIAN_ENV"  # Remove extra spaces
        sed -i "/^overlays=/ s/=\s*$//" "$ARMBIAN_ENV" # Remove '=' if no overlays remain
        echo -e "${COLOR_GPIO}$overlay removed from the overlays line${COLOR_RESET}"
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
        echo -e "${COLOR_I2C}$uart baud rate updated to $baud_rate${COLOR_RESET}"
    else
        echo "${uart}_baud=$baud_rate" >> "$ARMBIAN_ENV"
        echo -e "${COLOR_I2C}${uart}_baud set to $baud_rate${COLOR_RESET}"
    fi
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
    echo "|  1 |  [$(if grep -q "pwm" "$ARMBIAN_ENV"; then echo "X"; else echo " "; fi)]   | PWM (GPIO PIN to configure: servomotors, LEDs)      |"    
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
