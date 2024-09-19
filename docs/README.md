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
1. Update

   ```bash
    sudo apt update && sudo apt upgrade
    sudo apt-get install python3-dev python3-pip
   ```

2. Clone the repository:

   ```bash
   git clone https://github.com/adnroboticsfr/smartpi-gpio.git
   cd smartpi-gpio
   ```

3. Install required dependencies:

    ```bash
    sudo pip3 install -r requirements.txt
    ```

4. Build and install the package:

    ```bash
    sudo python3 -m build
    sudo pip3 install dist/smartpi_gpio-1.0.0-py3-none-any.whl
    ```

5. Activate the required GPIO interfaces:

    ```bash
    sudo /usr/local/bin/activate_interfaces.sh
    ```

## Example Usage

    Here’s a sample code to read from GPIO pin 17:
    ```bash
    from smartpi_gpio.gpio import GPIO

    gpio = GPIO()
    value = gpio.read(17)
    print(f"GPIO 17 value: {value}")