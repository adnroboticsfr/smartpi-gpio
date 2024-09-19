#!/bin/bash

# Fichier de configuration
ARMBIAN_ENV="/boot/armbianEnv.txt"

# Fonction pour ajouter une interface si elle n'existe pas dans 'overlays='
add_overlay_if_missing() {
    local overlay="$1"
    if grep -q "^overlays=" "$ARMBIAN_ENV"; then
        if ! grep -q "$overlay" "$ARMBIAN_ENV"; then
            sed -i "/^overlays=/ s/$/ $overlay/" "$ARMBIAN_ENV"
            echo "$overlay ajouté à la ligne overlays"
        else
            echo "$overlay déjà présent dans la ligne overlays"
        fi
    else
        echo "overlays=$overlay" >> "$ARMBIAN_ENV"
        echo "Ligne overlays créée avec $overlay"
    fi
}

# Ajouter I2C1 et I2C2 si nécessaire
add_overlay_if_missing "i2c1"
add_overlay_if_missing "i2c2"

# Ajouter PWM si nécessaire
add_overlay_if_missing "pwm"

# Redémarrer pour appliquer les changements
echo "Redémarrage du système pour appliquer les changements..."
reboot
