import smbus2 as smbus
import time

# I2C Address of the PCA9685
PCA9685_ADDRESS = 0x40

# PCA9685 Registers
PCA9685_MODE1 = 0x00
PCA9685_PRESCALE = 0xFE

class PCA9685:
    def __init__(self, address=PCA9685_ADDRESS):
        self.bus = smbus.SMBus(1)  # Use I2C bus 1
        self.address = address
        self.init()

    def init(self):
        self.write_register(PCA9685_MODE1, 0x00)  
        time.sleep(0.005)  

    def set_pwm_freq(self, freq):
        prescale_val = int(25000000.0 / (4096 * freq) - 1)
        old_mode = self.read_register(PCA9685_MODE1)
        new_mode = (old_mode & 0x7F) | 0x10  
        self.write_register(PCA9685_MODE1, new_mode)  
        self.write_register(PCA9685_PRESCALE, prescale_val)
        self.write_register(PCA9685_MODE1, old_mode)
        time.sleep(0.005)  
        self.write_register(PCA9685_MODE1, old_mode | 0x80)  

    def set_pwm(self, channel, on, off):
        self.write_register(0x06 + 4 * channel, on & 0xFF)
        self.write_register(0x07 + 4 * channel, on >> 8)
        self.write_register(0x08 + 4 * channel, off & 0xFF)
        self.write_register(0x09 + 4 * channel, off >> 8)

    def write_register(self, reg, value):
        self.bus.write_byte_data(self.address, reg, value)

    def read_register(self, reg):
        return self.bus.read_byte_data(self.address, reg)
