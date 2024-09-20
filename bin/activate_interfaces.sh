#!/bin/bash 

ARMBIAN_ENV="/boot/armbianEnv.txt"

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

add_overlay_if_missing "i2c1"
add_overlay_if_missing "i2c2"
add_overlay_if_missing "pwm"

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
