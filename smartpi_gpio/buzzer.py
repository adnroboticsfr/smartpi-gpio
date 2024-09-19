import time
from smartpi_gpio.gpio import GPIO

class Buzzer:
    def __init__(self, pin):
        self.gpio = GPIO()
        self.pin = pin
        self.gpio.set_direction(self.pin, "out")

    def beep(self, duration=0.5):
        self.gpio.write(self.pin, 1)
        time.sleep(duration)
        self.gpio.write(self.pin, 0)

    def beep_pattern(self, pattern):
        for duration in pattern:
            self.beep(duration)
            time.sleep(0.1) 
