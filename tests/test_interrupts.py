import RPi.GPIO as GPIO_lib
from .pins import Pins

class GPIOInterrupts:
    def __init__(self, mode="BCM"):
        GPIO_lib.setmode(GPIO_lib.BCM if mode == "BCM" else GPIO_lib.BOARD)
        GPIO_lib.setwarnings(False)

    def add_interrupt(self, pin_number, edge, callback):
        """
        Ajouter une interruption sur une broche.

        :param pin_number: Numéro de la broche
        :param edge: Type d'interruption ('rising', 'falling', 'both')
        :param callback: Fonction à appeler lorsque l'interruption est déclenchée
        """
        gpio_pin = Pins.get_pin("BCM", pin_number)
        if edge == "rising":
            GPIO_lib.add_event_detect(gpio_pin, GPIO_lib.RISING, callback=callback)
        elif edge == "falling":
            GPIO_lib.add_event_detect(gpio_pin, GPIO_lib.FALLING, callback=callback)
        elif edge == "both":
            GPIO_lib.add_event_detect(gpio_pin, GPIO_lib.BOTH, callback=callback)
        else:
            raise ValueError("Type d'interruption non valide. Utilisez 'rising', 'falling', ou 'both'.")

    def remove_interrupt(self, pin_number):
        """
        Supprimer l'interruption d'une broche.
        """
        gpio_pin = Pins.get_pin("BCM", pin_number)
        GPIO_lib.remove_event_detect(gpio_pin)
