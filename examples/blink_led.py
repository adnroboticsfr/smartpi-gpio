import time
from smartpi_gpio.gpio import GPIO

gpio = GPIO()
pin_led = 7
gpio.export(pin_led)
gpio.set_direction(pin_led, "out")

try:
    while True:
        gpio.write(pin_led, 1)
        time.sleep(1)
        gpio.write(pin_led, 0)
        time.sleep(1)
except KeyboardInterrupt:
    gpio.unexport(pin_led)
