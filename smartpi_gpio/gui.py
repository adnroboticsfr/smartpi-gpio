import tkinter as tk
from smartpi_gpio.gpio import GPIO

class GPIOGUI:
    def __init__(self):
        self.gpio = GPIO()
        self.window = tk.Tk()
        self.window.title("GPIO Management")

        self.led_button = tk.Button(self.window, text="Turn On LED", command=self.toggle_led)
        self.led_button.pack(pady=20)

        self.window.mainloop()

    def toggle_led(self):
        self.gpio.export(18)
        current_value = self.gpio.read(18)
        if current_value == "1": 
            self.gpio.write(18, 0)
            self.led_button.config(text="Turn On LED")
        else:
            self.gpio.write(18, 1)
            self.led_button.config(text="Turn Off LED")

if __name__ == "__main__":
    GPIOGUI()
