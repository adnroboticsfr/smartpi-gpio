# tests/test_gpio.py
import unittest
from gpio.gpio import GPIO
from gpio.pins import Pins

class TestGPIO(unittest.TestCase):
    def setUp(self):
        self.gpio = GPIO()

    def test_set_direction(self):
        pin = 23
        self.gpio.export(pin)
        self.gpio.set_direction(pin, "out")
        direction = self.gpio.read(pin)
        self.assertEqual(direction, "out")

    def test_write_and_read(self):
        pin = 23
        self.gpio.write(pin, 1)
        value = self.gpio.read(pin)
        self.assertEqual(value, "1")
