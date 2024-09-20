#!/bin/bash

echo "Updating repositories and packages..."
sudo apt update && sudo apt upgrade -y

echo "Installing required dependencies..."
sudo apt-get install -y python3-dev python3-pip libjpeg-dev zlib1g-dev libtiff-dev

echo "Renaming the EXTERNALLY-MANAGED file..."
sudo mv /usr/lib/python3.11/EXTERNALLY-MANAGED /usr/lib/python3.11/EXTERNALLY-MANAGED.old

echo "Cloning the smartpi-gpio repository..."
git clone https://github.com/adnroboticsfr/smartpi-gpio.git
cd smartpi-gpio

echo "Installing project dependencies..."
sudo pip3 install -r requirements.txt

echo "Building and installing the package..."
sudo python3 setup.py sdist bdist_wheel
sudo pip3 install dist/smartpi_gpio-1.0.0-py3-none-any.whl

echo "Enabling GPIO interfaces..."
sudo /usr/local/bin/enable_interfaces.sh

echo "Installation completed successfully!"
