Documentation for the installation, update, and uninstallation of the smartpi-gpio library for the **[Smart Pi One](https://wanhao-europe.com/collections/yumi-smart-pi-nano-computer-diy/products/yumi-smart-pi-one-1g-ddr3-processeur-h3-allwinner** SBC from **Yumi**.

---
<img src="https://github.com/adnroboticsfr/smartpi-gpio/blob/main/img/smart-pi-one-yumi.png" alt="Smart Pi One - Yumi" width="380"/>
# SmartPi-GPIO Documentation

## Table of Contents
1. [Introduction](#introduction)
2. [Requirements](#requirements)
3. [Installation](#installation)
4. [Updating](#updating)
5. [Uninstallation](#uninstallation)
6. [Activate Interfaces Script](#activate-interfaces-script)
7. [Usage Examples](#usage-examples)
8. [Contributing](#contributing)
9. [License](#license)

---

## Introduction
**SmartPi-GPIO** is a Python library that allows users to manage GPIO pins on the Smart Pi One. It supports I2C, UART, SPI, PWM, and includes additional utilities such as displaying GPIO pinouts.

This project also provides a script, **`activate_interfaces.sh`**, to easily enable or disable GPIO interfaces directly by modifying the `/boot/armbianEnv.txt` file.

---

## Requirements
Before you start, ensure that your system meets the following requirements:
- Python 3.7 or higher
- `pip3` (Python package manager)
- A Smart Pi One with Armbian OS installed
- Root privileges for system-wide installation and modifications to the `/boot/armbianEnv.txt` file

---

## Installation

1. **Clone the repository**:

   ```bash
   git clone https://github.com/ADNroboticsfr/smartpi-gpio.git
   cd smartpi-gpio
   ```

2. **Install the library**:

   Run the following command to install the library and its dependencies:
   ```bash
   sudo python3 setup.py install
   ```

3. **Activate GPIO interfaces**:

   To activate interfaces like I2C, UART, or SPI, use the included **`activate_interfaces.sh`** script:
   ```bash
   sudo bash bin/activate_interfaces.sh
   ```

   This will present an interactive menu where you can enable or disable specific GPIO interfaces on the Smart Pi One.

---

## Updating

To update **SmartPi-GPIO** to the latest version, follow these steps:

1. **Pull the latest changes** from the repository:
   ```bash
   cd smartpi-gpio
   git pull
   ```

2. **Reinstall the package**:
   ```bash
   sudo python3 setup.py install
   ```

3. **Re-run the interfaces activation script** if necessary:
   ```bash
   sudo bash bin/activate_interfaces.sh
   ```

---

## Uninstallation

To completely remove **SmartPi-GPIO** from your system, follow these steps:

1. **Uninstall the Python package**:
   ```bash
   sudo pip3 uninstall smartpi-gpio
   ```

2. **Clean up remaining files**:

   If the `activate_interfaces.sh` script or any GPIO configuration files were modified, you may want to reset or manually remove the changes from `/boot/armbianEnv.txt`.

---

## Activate Interfaces Script

The script **`activate_interfaces.sh`** is a convenient tool to manage GPIO interfaces on your Smart Pi One.

### Usage:

1. **Run the script**:
   ```bash
   sudo bash bin/activate_interfaces.sh
   ```

2. **Options**:
   - The menu allows you to enable or disable various GPIO interfaces, such as I2C, UART, SPI, and PWM.
   - It also provides an option to display the current GPIO pinout in a colorful, easy-to-read table.

3. **Backup and restore**:
   - Every time you make changes, the script automatically creates a backup of your `/boot/armbianEnv.txt` file as `/boot/armbianEnv_backup.txt`.
   - If something goes wrong, you can restore the backup by copying the backup file back to the original location.

---

## Usage Examples

Here are some example commands and use cases for **SmartPi-GPIO**.

### Example 1: Reading and Writing GPIO Pins

- **Read the state of a pin**:
  ```bash
  gpio-smpi 17 read
  ```

- **Set a pin as output and write a value**:
  ```bash
  gpio-smpi 17 mode out
  gpio-smpi 17 write on
  ```

### Example 2: Controlling PWM using the PCA9685

- **Set PWM frequency**:
  ```bash
  gpio pca9685 freq 50
  ```

- **Set PWM values on a specific channel**:
  ```bash
  gpio pca9685 0 0 2048
  ```

### Example 3: Display All GPIO Pin States

- **View the current state of all GPIO pins**:
  ```bash
  gpio-smpi readall
  ```

---

## Contributing

We welcome contributions to **SmartPi-GPIO**. If you have suggestions, encounter bugs, or want to add new features, feel free to open an issue or submit a pull request on GitHub.

### Steps to Contribute:
1. Fork the repository.
2. Create a new branch for your changes.
3. Submit a pull request with a detailed description of your work.

---

## License

This project is licensed under the **MIT License**.

**MIT License**

```
Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

---

### Fichier `README.md`

Le contenu de cette documentation peut être intégré directement dans le fichier `README.md` de votre dépôt GitHub. Vous pouvez également utiliser un **Wiki** pour organiser la documentation en plusieurs pages et en sections détaillées.
