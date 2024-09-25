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
                # Check if gpio_pin is in exported_pins before removing
                if gpio_pin in self.exported_pins:
                    self.exported_pins.remove(gpio_pin)
            except OSError as e:
                print(f"Error unexporting pin {gpio_pin}: {e}")
                raise

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

    def version(self):
        print("smartpi-gpio version 1.0.0")

    def display_gpio_table(self):
        width = 11  

        def truncate(text, max_length):
            if isinstance(text, str) and len(text) > max_length:
                return text[:max_length-1] + "…"  
            return text

        def color_text(text, is_bcm_or_board=False):
            if "5V" in text or "3.3V" in text:
                return f"{Fore.RED}{text}{Style.RESET_ALL}"
            elif "GPIO" in text and not is_bcm_or_board:
                return f"{Fore.GREEN}{text}{Style.RESET_ALL}"
            return text

        header = f"| {'LINUX gpio':^{width}} | {'Name':^{width}} | {'Board(PIN)':^{width}} | {'Board(PIN)':^{width}} | {'Name':^{width}} | {'LINUX gpio':^{width}} |"
        
        print("")
        print("-" * len(header))
        print(" ".center((width * 3) + 1) + "GPIO - Smart Pi One")
        print("-" * len(header))
        print(header)
        print("-" * len(header))

        odd_pins = [(Pins.BCM_PINS.get(pin, ""), Pins.NAME_PINS.get(pin, ""), "( "+str(pin)+" )") for pin in sorted(Pins.NAME_PINS.keys()) if pin % 2 != 0]
        even_pins = [(Pins.BCM_PINS.get(pin, ""), Pins.NAME_PINS.get(pin, ""), "( "+str(pin)+" )") for pin in sorted(Pins.NAME_PINS.keys()) if pin % 2 == 0]

        max_lines = max(len(odd_pins), len(even_pins))

        for i in range(max_lines):
            if i < len(odd_pins):
                bcm_odd, name_odd, board_odd = odd_pins[i]
            else:
                bcm_odd = name_odd = board_odd = ""

            if i < len(even_pins):
                bcm_even, name_even, board_even = even_pins[i]
            else:
                bcm_even = name_even = board_even = ""

            name_odd = truncate(name_odd, width)
            name_even = truncate(name_even, width)

            line = f"| {bcm_odd:^{width}} | {name_odd:^{width}} | {board_odd:^{width}} | {board_even:^{width}} | {name_even:^{width}} | {bcm_even:^{width}} |"
            
            colored_line = line.replace(name_odd, color_text(name_odd)).replace(name_even, color_text(name_even))
            colored_line = colored_line.replace(bcm_odd, color_text(bcm_odd, True)).replace(bcm_even, color_text(bcm_even, True))
            
            print(colored_line)
        
        print("-" * len(header))

    def read_all(self):
        self.display_gpio_table()

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

# Helper functions to match the syntax you're using in scripts

def setup(pin_number, mode, pull=None):
    gpio = GPIO()
    gpio.set_direction(pin_number, mode, pull)

def output(pin_number, value):
    gpio = GPIO()
    gpio.write(pin_number, value)

def input(pin_number):
    gpio = GPIO()
    return gpio.read(pin_number)

def toggle(pin_number):
    gpio = GPIO()
    gpio.toggle(pin_number)

def cleanup():
    gpio = GPIO()
    gpio.cleanup()

def cleanup_pin(pin_number):
    gpio = GPIO()
    gpio.cleanup_pin(pin_number)
