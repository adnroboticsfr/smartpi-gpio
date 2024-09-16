import RPi.GPIO as GPIO_lib
from .pins import Pins

class GPIO:
    def __init__(self, mode=PinMode.BCM):
        self.mode = mode
        GPIO_lib.setmode(GPIO_lib.BCM if self.mode == PinMode.BCM else GPIO_lib.BOARD)
        GPIO_lib.setwarnings(False)

    def export(self, pin_number):
        """Export GPIO pin."""
        gpio_pin = Pins.get_pin(self.mode, pin_number)
        GPIO_lib.setup(gpio_pin, GPIO_lib.OUT)

    def unexport(self, pin_number):
        """Unexport GPIO pin."""
        gpio_pin = Pins.get_pin(self.mode, pin_number)
        GPIO_lib.cleanup(gpio_pin)

    def write(self, pin_number, value):
        """Write value to GPIO pin."""
        gpio_pin = Pins.get_pin(self.mode, pin_number)
        GPIO_lib.output(gpio_pin, GPIO_lib.HIGH if value else GPIO_lib.LOW)

    def read(self, pin_number):
        """Read value from GPIO pin."""
        gpio_pin = Pins.get_pin(self.mode, pin_number)
        return GPIO_lib.input(gpio_pin)

    def setup_pin(self, pin_number, direction, pull_up_down=None):
        """
        Configurer une broche avec des résistances internes (pull-up, pull-down).

        :param pin_number: Numéro de la broche
        :param direction: Mode de la broche ('in' pour entrée, 'out' pour sortie)
        :param pull_up_down: Résistance interne ('pull_up', 'pull_down' ou None)
        """
        gpio_pin = Pins.get_pin(self.mode, pin_number)
        if direction == "in":
            if pull_up_down == "pull_up":
                GPIO_lib.setup(gpio_pin, GPIO_lib.IN, pull_up_down=GPIO_lib.PUD_UP)
            elif pull_up_down == "pull_down":
                GPIO_lib.setup(gpio_pin, GPIO_lib.IN, pull_up_down=GPIO_lib.PUD_DOWN)
            else:
                GPIO_lib.setup(gpio_pin, GPIO_lib.IN)
        elif direction == "out":
            GPIO_lib.setup(gpio_pin, GPIO_lib.OUT)
        else:
            raise ValueError("Invalid direction. Use 'in' or 'out'.")

    def read_all(self):
        """Display all GPIO pins states."""
        print("Pin | Mode  | Value")
        print("-------------------")
        for pin, name in Pins.BOARD_PINS.items():
            try:
                value = self.read(pin)
                print(f"{pin:>3} | {name:<5} | {value}")
            except:
                pass  # Pin might not be exported or not in use
