
import time
from smartpi_gpio.gpio import GPIO

gpio = GPIO()
pin_led = 18
gpio.export(pin_led)
gpio.set_direction(pin_led, "out")

try:
    while True:
        gpio.write(pin_led, 1)  # Turn LED on
        time.sleep(1)
        gpio.write(pin_led, 0)  # Turn LED off
        time.sleep(1)
except KeyboardInterrupt:
    pass
finally:
    gpio.unexport(pin_led)  # Cleanup
