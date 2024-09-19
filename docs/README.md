# SmartPi-GPIO

SmartPi-GPIO is a Python package that provides comprehensive control over GPIO (General Purpose Input/Output) pins for Smart Pi One (SBCs) running Armbian. It supports basic GPIO operations, PWM, I2C-based components like the PCA9685, OLED screens, and GPIO interrupts. It also includes a web-based interface to control the GPIO remotely.

## Features
- Basic GPIO read/write operations
- PWM control via PCA9685
- GPIO interrupt support
- Web-based interface using Flask
- Control OLED displays over I2C
- Post-installation scripts for setting up GPIO interfaces

## Installation

1. Download the installation script:
    ```bash
    wget https://raw.githubusercontent.com/adnroboticsfr/smartpi-gpio/main/install_script.sh
    ```
2. Make the script executable:
    ```bash
    chmod +x install_script.sh
    ```
3. Run the installation script with administrative privileges:
    ```bash
    sudo ./install_script.sh
    ```
## Example Usage
Here’s a sample code to read from GPIO pin 17:
```python
from smartpi_gpio.gpio import GPIO
gpio = GPIO()
value = gpio.read(17)
print(f"GPIO 17 value: {value}")
```

