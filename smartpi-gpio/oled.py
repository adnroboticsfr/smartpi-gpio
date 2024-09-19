from luma.core.interface.serial import i2c
from luma.oled.device import ssd1306
from PIL import Image, ImageDraw, ImageFont

class OledDisplay:
    def __init__(self, i2c_address=0x3C):
        serial = i2c(port=1, address=i2c_address)
        self.device = ssd1306(serial)

    def display_text(self, text):
        img = Image.new("1", (self.device.width, self.device.height), "black")
        draw = ImageDraw.Draw(img)
        font = ImageFont.load_default()
        draw.text((0, 0), text, font=font, fill="white")
        self.device.display(img)

    def clear(self):
        self.device.clear()
