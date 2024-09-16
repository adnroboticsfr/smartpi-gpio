import tkinter as tk
from gpio.gpio import GPIO

class GPIOGUI:
    def __init__(self):
        self.gpio = GPIO()
        self.window = tk.Tk()
        self.window.title("Gestion des GPIO")

        self.led_button = tk.Button(self.window, text="Activer LED", command=self.toggle_led)
        self.led_button.pack(pady=20)

        self.window.mainloop()

    def toggle_led(self):
        self.gpio.export(18)
        current_value = self.gpio.read(18)
        if current_value == 1:
            self.gpio.write(18, 0)
            self.led_button.config(text="Activer LED")
        else:
            self.gpio.write(18, 1)
            self.led_button.config(text="Désactiver LED")

if __name__ == "__main__":
    GPIOGUI()
