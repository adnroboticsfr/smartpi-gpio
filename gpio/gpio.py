# gpio/gpio.py
import os
from .pins import Pins, PinMode

GPIO_PATH = "/sys/class/gpio"

class GPIO:
    def __init__(self, mode=PinMode.BCM):
        self.mode = mode

    def export(self, pin_number):
        gpio_pin = Pins.get_pin(self.mode, pin_number)
        if not gpio_pin:
            raise ValueError("Invalid pin number")
        if not os.path.exists(f"{GPIO_PATH}/gpio{gpio_pin}"):
            with open(f"{GPIO_PATH}/export", 'w') as f:
                f.write(str(gpio_pin))

    def unexport(self, pin_number):
        gpio_pin = Pins.get_pin(self.mode, pin_number)
        if os.path.exists(f"{GPIO_PATH}/gpio{gpio_pin}"):
            with open(f"{GPIO_PATH}/unexport", 'w') as f:
                f.write(str(gpio_pin))

    def set_direction(self, pin_number, direction):
        gpio_pin = Pins.get_pin(self.mode, pin_number)
        with open(f"{GPIO_PATH}/gpio{gpio_pin}/direction", 'w') as f:
            f.write(direction)

    def write(self, pin_number, value):
        gpio_pin = Pins.get_pin(self.mode, pin_number)
        with open(f"{GPIO_PATH}/gpio{gpio_pin}/value", 'w') as f:
            f.write(str(value))

    def read(self, pin_number):
        gpio_pin = Pins.get_pin(self.mode, pin_number)
        with open(f"{GPIO_PATH}/gpio{gpio_pin}/value", 'r') as f:
            return f.read().strip()

    def read_all(self):
        """Display a table of all GPIO pin states."""
        # This function will iterate over all pins and display their current states
        print("Pin | Mode  | Value")
        print("-------------------")
        for pin, name in Pins.BOARD_PINS.items():
            try:
                value = self.read(pin)
                print(f"{pin:>3} | {name:<5} | {value}")
            except:
                pass  # Pin might not be exported or not in use
