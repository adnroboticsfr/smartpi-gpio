class PinMode:
    BCM = 'BCM'
    BOARD = 'BOARD'
    SUNXI = 'SUNXI'
    NAME = 'NAME'

class Pins:
    BCM_PINS = {
        7: "203", 8: "198", 10: "199", 11: "0", 12: "6", 13: "2",
        15: "3", 16: "200", 18: "201", 19: "64", 21: "65",
        22: "1", 23: "66", 24: "67", 25: "17", 26: "19",
        27: "18", 28: "29", 29: "31", 32: "7",
        33: "8", 35: "16", 36: "13", 37: "9", 38: "15",
        40: "14",
    }

    SUNXI_PINS = {
        "PA0": 0, "PA1": 1, "PA2": 2, "PA3": 3, "PG6": 198, "PG7": 199,
        "PA4": 4, "PA5": 5, "PA6": 6, "PA7": 7, "PG8": 200, "PG9": 201,
    }

    BOARD_PINS = { 
        7: "203", 8: "198", 10: "199", 11: "0", 12: "6", 13: "2",
        15: "3", 16: "200", 18: "201", 19: "64", 21: "65",
        22: "1", 23: "66", 24: "67", 25: "17", 26: "19",
        27: "18", 28: "29", 29: "31", 32: "7",
        33: "8", 35: "16", 36: "13", 37: "9", 38: "15",
        40: "14",
    }

    NAME_PINS = {
        1: "SYS_3.3V",    2: "VDD_5V",
        3: "I2C0_SDA", 4: "VDD_5V",
        5: "I2C0_SCL", 6: "GND",
        7: "GPIOG11",    8: "UART1_TX",
        9: "GND",        10: "UART1_RX",
        11: "GPIOA0", 12: "GPIOA6",
        13: "GPIOA2", 14: "GND",
        15: "GPIOA3", 16: "GPIOG8",
        17: "SYS_3.3V",   18: "GPIOG9",
        19: "SPI0_MOSI", 20: "GND",
        21: "SPI0_MISO", 22: "GPIOA1",
        23: "SPI0_CLK", 24: "GPIOC3",
        25: "GND",       26: "GPIOA17",
        27: "I2C1_SDA", 28: "I2C1_SCL",
        29: "GPIOA20", 30: "GND",
        31: "GPIOA21", 32: "GPIOA7",
        33: "GPIOA8",    34: "GND",
        35: "GPIOA16", 36: "GPIOA13",
        37: "GPIOA9",    38: "GPIOA15",
        39: "GND",       40: "GPIOA14"
    }

    @classmethod
    def get_pin(cls, mode, pin_number_or_name):
        if mode == PinMode.BCM:
            return cls.BCM_PINS.get(pin_number_or_name, None)
        elif mode == PinMode.BOARD:
            return cls.BOARD_PINS.get(pin_number_or_name, None)
        elif mode == PinMode.NAME:
            return cls.NAME_PINS.get(pin_number_or_name, None)
        elif mode == PinMode.SUNXI:
            return cls.SUNXI_PINS.get(pin_number_or_name, None)
        return None

    @classmethod
    def is_valid_pin(cls, mode, pin_number_or_name):
        if mode == PinMode.BCM:
            return pin_number_or_name in cls.BCM_PINS
        elif mode == PinMode.BOARD:
            return pin_number_or_name in cls.BOARD_PINS
        elif mode == PinMode.NAME:
            return pin_number_or_name in cls.NAME_PINS
        elif mode == PinMode.SUNXI:
            return pin_number_or_name in cls.SUNXI_PINS
        return False
