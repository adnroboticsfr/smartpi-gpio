#!/bin/bash

# Mettre à jour les dépôts et les paquets
echo "Mise à jour des dépôts et des paquets..."
sudo apt update && sudo apt upgrade -y

# Installer les dépendances nécessaires
echo "Installation des dépendances requises..."
sudo apt-get install -y python3-dev python3-pip libjpeg-dev zlib1g-dev libtiff-dev

# Renommer le fichier EXTERNALLY-MANAGED
echo "Renommage du fichier EXTERNALLY-MANAGED..."
sudo mv /usr/lib/python3.11/EXTERNALLY-MANAGED /usr/lib/python3.11/EXTERNALLY-MANAGED.old

# Cloner le dépôt
echo "Clonage du dépôt smartpi-gpio..."
git clone https://github.com/adnroboticsfr/smartpi-gpio.git
cd smartpi-gpio

# Installer les dépendances du projet
echo "Installation des dépendances du projet..."
sudo pip3 install -r requirements.txt

# Construire et installer le package
echo "Construction et installation du package..."
#sudo python3 -m build
sudo ./install_script.sh
sudo pip3 install dist/smartpi_gpio-1.0.0-py3-none-any.whl

# Activer les interfaces GPIO
echo "Activation des interfaces GPIO..."
sudo /usr/local/bin/activate_interfaces.sh

echo "Installation terminée avec succès !"
