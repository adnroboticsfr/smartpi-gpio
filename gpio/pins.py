# gpio/pins.py

class PinMode:
    BCM = "BCM"
    BOARD = "BOARD"
    SUNXI = "SUNXI"

class Pins:
    BOARD_PINS = {
        1: "SYS_3.3V", 2: "VDD_5V", 3: "GPIO2", 4: "VDD_5V", 5: "GPIO3", 6: "GND",
        7: "GPIO4", 8: "GPIO14", 9: "GND", 10: "GPIO15", 11: "GPIO17", 12: "GPIO18",
    }

    BCM_PINS = {
        2: "GPIO2", 3: "GPIO3", 4: "GPIO4", 17: "GPIO17", 27: "GPIO27", 22: "GPIO22",
        10: "GPIO10", 9: "GPIO9", 11: "GPIO11", 14: "GPIO14", 15: "GPIO15",
    }

    SUNXI_PINS = {
        "PA0": 0, "PA1": 1, "PA2": 2, "PA3": 3, "PG6": 198, "PG7": 199,
    }

    @classmethod
    def get_pin(cls, mode, pin_number):
        """Returns the GPIO number based on the mode (BCM, BOARD, SUNXI) and pin number."""
        if mode == PinMode.BOARD:
            return cls.BOARD_PINS.get(pin_number)
        elif mode == PinMode.BCM:
            return cls.BCM_PINS.get(pin_number)
        elif mode == PinMode.SUNXI:
            return cls.SUNXI_PINS.get(pin_number)
        return None
