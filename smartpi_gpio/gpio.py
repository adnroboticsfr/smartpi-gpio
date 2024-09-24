import os
from .pins import Pins, PinMode
from colorama import Fore, Style, init

init()

GPIO_PATH = '/sys/class/gpio'  # Path to GPIO in the system

class InvalidPinError(Exception):
    def __init__(self, pin_number, mode):
        super().__init__(f"Error: Pin {pin_number} is not valid in {mode} mode.")


class GPIO:
    OUT = 'out'
    IN = 'in'
    HIGH = '1'
    LOW = '0'

    def __init__(self, mode=PinMode.BOARD):  # Default to BOARD mode
        self.mode = mode  # Store the pin numbering mode (BOARD or BCM)
        self.exported_pins = set()  # Track which pins are exported

    def _validate_pin(self, pin_number):
        if not Pins.is_valid_pin(self.mode, pin_number):
            raise InvalidPinError(pin_number, self.mode)

    def export(self, pin_number):
        self._validate_pin(pin_number)  # Validate if the pin is correct
        gpio_pin = Pins.get_pin(self.mode, pin_number)
        if not os.path.exists(f"{GPIO_PATH}/gpio{gpio_pin}"):
            try:
                with open(f"{GPIO_PATH}/export", 'w') as f:
                    f.write(str(gpio_pin))
                self.exported_pins.add(gpio_pin)
            except OSError as e:
                print(f"Error exporting pin {gpio_pin}: {e}")
                raise

    def unexport(self, pin_number):
        self._validate_pin(pin_number)  # Validate if the pin is correct
        gpio_pin = Pins.get_pin(self.mode, pin_number)
        if os.path.exists(f"{GPIO_PATH}/gpio{gpio_pin}"):
            try:
                with open(f"{GPIO_PATH}/unexport", 'w') as f:
                    f.write(str(gpio_pin))
                self.exported_pins.remove(gpio_pin)
            except OSError as e:
                print(f"Error unexporting pin {gpio_pin}: {e}")
                raise

    def set_direction(self, pin_number, direction, pull=None):
        self._validate_pin(pin_number)  # Validate if the pin is correct
        gpio_pin = Pins.get_pin(self.mode, pin_number)
        self.export(pin_number)  # Ensure the pin is exported
        
        gpio_dir_path = f"{GPIO_PATH}/gpio{gpio_pin}/direction"
        
        try:
            with open(gpio_dir_path, 'w') as f:
                f.write(direction)
        except OSError as e:
            print(f"Error setting direction for pin {gpio_pin}: {e}")
            raise

        if pull:
            self.set_pull_resistor(pin_number, pull)

    def set_pull_resistor(self, pin_number, pull):
        if pull == "pull-up":
            print(f"Pull-up resistor activated for pin {pin_number}")
        elif pull == "pull-down":
            print(f"Pull-down resistor activated for pin {pin_number}")
        elif pull == "none":
            print(f"No internal resistor configured for pin {pin_number}")
        else:
            raise ValueError("Invalid resistor type. Use 'pull-up', 'pull-down', or 'none'.")

    def write(self, pin_number, value):
        self._validate_pin(pin_number)  # Validate if the pin is correct
        gpio_pin = Pins.get_pin(self.mode, pin_number)
        self.export(pin_number)  # Ensure the pin is exported
        try:
            with open(f"{GPIO_PATH}/gpio{gpio_pin}/value", 'w') as f:
                f.write(str(value))
        except OSError as e:
            print(f"Error writing value to pin {gpio_pin}: {e}")
            raise

    def read(self, pin_number):
        self._validate_pin(pin_number)  # Validate if the pin is correct
        gpio_pin = Pins.get_pin(self.mode, pin_number)
        self.export(pin_number)
        try:
            with open(f"{GPIO_PATH}/gpio{gpio_pin}/value", 'r') as f:
                return f.read().strip()
        except OSError as e:
            print(f"Error reading value from pin {gpio_pin}: {e}")
            raise

    def toggle(self, pin_number):
        current_value = self.read(pin_number)
        new_value = GPIO.LOW if current_value == GPIO.HIGH else GPIO.HIGH
        self.write(pin_number, new_value)

    def cleanup(self):
        """Unexport all exported pins to clean up GPIO."""
        for pin in list(self.exported_pins):
            self.unexport(pin)

    def cleanup_pin(self, pin_number):
        """Unexport a specific pin."""
        self.unexport(pin_number)

    def version(self):
        print("smartpi-gpio version 1.0.0")

    def display_gpio_table(self):
        # (Same GPIO table display code here)
        pass

    def read_all(self):
        self.display_gpio_table()


# Helper functions to match the syntax you're using in scripts

def setup(pin_number, direction):
    gpio = GPIO()  # Instantiate the GPIO class
    gpio.set_direction(pin_number, direction)

def set_pull_up_down(pin_number, pull):
    gpio = GPIO()
    gpio.set_pull_resistor(pin_number, pull)

def output(pin_number, value):
    gpio = GPIO()  # Instantiate the GPIO class
    gpio.write(pin_number, value)

def input(pin_number):
    gpio = GPIO()  # Instantiate the GPIO class
    return gpio.read(pin_number)

def toggle(pin_number):
    gpio = GPIO()  # Instantiate the GPIO class
    gpio.toggle(pin_number)

def cleanup():
    gpio = GPIO()  # Instantiate the GPIO class
    gpio.cleanup()

def cleanup_pin(pin_number):
    gpio = GPIO()  # Instantiate the GPIO class
    gpio.cleanup_pin(pin_number)
