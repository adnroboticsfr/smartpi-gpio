import RPi.GPIO as GPIO_lib
from .pins import Pins

class PWMGPIO:
    def __init__(self, mode=PinMode.BCM):
        GPIO_lib.setmode(GPIO_lib.BCM if mode == "BCM" else GPIO_lib.BOARD)
        GPIO_lib.setwarnings(False)
        self.pwm_instances = {}

    def start_pwm(self, pin_number, frequency=1000):
        """
        Démarrer un signal PWM sur une broche.

        :param pin_number: Numéro de la broche
        :param frequency: Fréquence du signal PWM en Hertz
        """
        gpio_pin = Pins.get_pin("BCM", pin_number)
        GPIO_lib.setup(gpio_pin, GPIO_lib.OUT)
        pwm_instance = GPIO_lib.PWM(gpio_pin, frequency)
        pwm_instance.start(0)
        self.pwm_instances[pin_number] = pwm_instance

    def change_duty_cycle(self, pin_number, duty_cycle):
        """
        Changer le cycle de travail (duty cycle) d'un signal PWM.

        :param pin_number: Numéro de la broche
        :param duty_cycle: Valeur du duty cycle (entre 0 et 100)
        """
        if pin_number in self.pwm_instances:
            self.pwm_instances[pin_number].ChangeDutyCycle(duty_cycle)

    def stop_pwm(self, pin_number):
        """Arrêter le signal PWM sur une broche."""
        if pin_number in self.pwm_instances:
            self.pwm_instances[pin_number].stop()
            del self.pwm_instances[pin_number]
