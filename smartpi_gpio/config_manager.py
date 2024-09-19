import json
import os

class GPIOConfigManager:
    CONFIG_PATH = "/etc/smartpi-gpio/config.json"

    def __init__(self, gpio):
        self.gpio = gpio

    def save_config(self, config):
        with open(self.CONFIG_PATH, "w") as f:
            json.dump(config, f)

    def load_config(self):
        if os.path.exists(self.CONFIG_PATH):
            with open(self.CONFIG_PATH, "r") as f:
                return json.load(f)
        return {}

    def apply_config(self):
        config = self.load_config()
        for pin, conf in config.items():
            self.gpio.set_direction(int(pin), conf["mode"], conf["pull"])
            if "value" in conf:
                self.gpio.write(int(pin), conf["value"])
