import os
from .pins import Pins, PinMode
from colorama import Fore, Style, init

init()

GPIO_PATH = '/sys/class/gpio'

class InvalidPinError(Exception):
    def __init__(self, pin_number, mode):
        super().__init__(f"Error: Pin {pin_number} is not valid in {mode} mode.")

class GPIO:
    def __init__(self, mode=PinMode.BOARD):
        self.mode = mode
        print(f"Pin numbering mode: {self.mode}")
    
    def _validate_pin(self, pin_number):
        if not Pins.is_valid_pin(self.mode, pin_number):
            raise InvalidPinError(pin_number, self.mode)

    def export(self, pin_number):
        self._validate_pin(pin_number)
        gpio_pin = Pins.get_pin(self.mode, pin_number)
        if not os.path.exists(f"{GPIO_PATH}/gpio{gpio_pin}"):
            try:
                with open(f"{GPIO_PATH}/export", 'w') as f:
                    f.write(str(gpio_pin))
            except OSError as e:
                print(f"Error exporting pin {gpio_pin}: {e}")
                raise

    def unexport(self, pin_number):
        self._validate_pin(pin_number)
        gpio_pin = Pins.get_pin(self.mode, pin_number)
        if os.path.exists(f"{GPIO_PATH}/gpio{gpio_pin}"):
            try:
                with open(f"{GPIO_PATH}/unexport", 'w') as f:
                    f.write(str(gpio_pin))
            except OSError as e:
                print(f"Error unexporting pin {gpio_pin}: {e}")
                raise

    def set_direction(self, pin_number, direction, pull="None"):
        self._validate_pin(pin_number)
        gpio_pin = Pins.get_pin(self.mode, pin_number)
        self.export(pin_number)

        gpio_dir_path = f"{GPIO_PATH}/gpio{gpio_pin}/direction"
        try:
            with open(gpio_dir_path, 'w') as f:
                f.write(direction)
        except OSError as e:
            print(f"Error setting direction for GPIO {gpio_pin}: {e}")
            raise

        if pull:
            self.set_pull_resistor(gpio_pin, pull)

    def set_pull_resistor(self, gpio_pin, pull):
        if pull == "pull-up":
            print(f"Pull-up resistor enabled for pin {gpio_pin}")
        elif pull == "pull-down":
            print(f"Pull-down resistor enabled for pin {gpio_pin}")
        elif pull == "none":
            print(f"No internal resistor configured for pin {gpio_pin}")
        else:
            raise ValueError("Invalid resistor type. Use 'pull-up', 'pull-down', or 'none'.")

    def write(self, pin_number, value):
        self._validate_pin(pin_number)
        gpio_pin = Pins.get_pin(self.mode, pin_number)
        self.export(pin_number)
        try:
            with open(f"{GPIO_PATH}/gpio{gpio_pin}/value", 'w') as f:
                f.write(str(value))
        except OSError as e:
            print(f"Error writing value to pin {gpio_pin}: {e}")
            raise

    def read(self, pin_number):
        self._validate_pin(pin_number)
        gpio_pin = Pins.get_pin(self.mode, pin_number)
        self.export(pin_number)
        try:
            with open(f"{GPIO_PATH}/gpio{gpio_pin}/value", 'r') as f:
                return f.read().strip()
        except OSError as e:
            print(f"Error reading value from pin {gpio_pin}: {e}")
            raise

    def version(self):
        print("smartpi-gpio version 1.0.0")
