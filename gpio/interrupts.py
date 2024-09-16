import os
import select
from .pins import Pins

class GPIOInterrupts:
    def __init__(self, mode="BCM"):
        self.mode = mode

    def add_interrupt(self, pin_number, edge, callback):
        """Add interrupt for the specified pin."""
        gpio_pin = Pins.get_pin(self.mode, pin_number)
        with open(f"/sys/class/gpio/gpio{gpio_pin}/edge", 'w') as f:
            f.write(edge)
        
        gpio_value_path = f"/sys/class/gpio/gpio{gpio_pin}/value"
        fd = os.open(gpio_value_path, os.O_RDONLY)
        poller = select.poll()
        poller.register(fd, select.POLLPRI)

        while True:
            events = poller.poll(1000)  # Wait for an event with a timeout
            if events:
                callback(gpio_pin)
                os.lseek(fd, 0, os.SEEK_SET)  # Reset the file descriptor

    def remove_interrupt(self, pin_number):
        """Remove interrupt from the pin."""
        gpio_pin = Pins.get_pin(self.mode, pin_number)
        with open(f"/sys/class/gpio/gpio{gpio_pin}/edge", 'w') as f:
            f.write("none")
