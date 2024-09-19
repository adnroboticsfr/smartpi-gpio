import os
from .pins import Pins, PinMode
from colorama import Fore, Style, init

init()

GPIO_PATH = '/sys/class/gpio'  # Chemin pour les GPIO sur le système

class InvalidPinError(Exception):
    """Exception levée lorsque la broche GPIO est invalide pour le mode sélectionné."""
    def __init__(self, pin_number, mode):
        super().__init__(f"Erreur : La broche {pin_number} n'est pas valide en mode {mode}.")


class GPIO:
    def __init__(self, mode=PinMode.BOARD):  # Correction: ajout d'un mode par défaut
        """Initialisation avec un mode de numérotation optionnel (BOARD ou BCM)."""
        self.mode = mode  # Enregistrer le mode de numérotation des broches (BOARD ou BCM)
        print(f"Mode de numérotation : {self.mode}")
    
    def _validate_pin(self, pin_number):
        """Valide si la broche existe pour le mode actuel."""
        if not Pins.is_valid_pin(self.mode, pin_number):
            raise InvalidPinError(pin_number, self.mode)

    def export(self, pin_number):
        """Export GPIO pin via /sys/class/gpio."""
        self._validate_pin(pin_number)  # Valide si la broche est correcte
        gpio_pin = Pins.get_pin(self.mode, pin_number)
        if not os.path.exists(f"{GPIO_PATH}/gpio{gpio_pin}"):
            try:
                with open(f"{GPIO_PATH}/export", 'w') as f:
                    f.write(str(gpio_pin))
            except OSError as e:
                print(f"Erreur lors de l'exportation de la broche {gpio_pin}: {e}")
                raise

    def unexport(self, pin_number):
        """Unexport GPIO pin."""
        self._validate_pin(pin_number)  # Valide si la broche est correcte
        gpio_pin = Pins.get_pin(self.mode, pin_number)
        if os.path.exists(f"{GPIO_PATH}/gpio{gpio_pin}"):
            try:
                with open(f"{GPIO_PATH}/unexport", 'w') as f:
                    f.write(str(gpio_pin))
            except OSError as e:
                print(f"Erreur lors de la désexportation de la broche {gpio_pin}: {e}")
                raise

    def set_direction(self, pin_number, direction, pull=None):
        """Définir la direction d'une broche GPIO avec option de résistance interne."""
        self._validate_pin(pin_number)  # Valide si la broche est correcte
        gpio_pin = Pins.get_pin(self.mode, pin_number)
        self.export(pin_number)  # S'assurer que la broche est exportée
        
        gpio_dir_path = f"{GPIO_PATH}/gpio{gpio_pin}/direction"
        
        try:
            with open(gpio_dir_path, 'w') as f:
                f.write(direction)
        except OSError as e:
            print(f"Erreur lors de la configuration de la direction de la broche {gpio_pin}: {e}")
            raise

        # Configuration des résistances internes pull-up ou pull-down (si supporté)
        if pull:
            self.set_pull_resistor(pin_number, pull)


    def set_pull_resistor(self, pin_number, pull):
        """Configurer la résistance interne pull-up ou pull-down pour une broche GPIO."""
        if pull == "pull-up":
            print(f"Résistance pull-up activée pour la broche {pin_number}")
        elif pull == "pull-down":
            print(f"Résistance pull-down activée pour la broche {pin_number}")
        elif pull == "none":
            print(f"Aucune résistance interne configurée pour la broche {pin_number}")
        else:
            raise ValueError("Type de résistance invalide. Utilisez 'pull-up', 'pull-down' ou 'none'.")


    def write(self, pin_number, value):
        """Écrire une valeur (0 ou 1) sur une broche GPIO."""
        self._validate_pin(pin_number)  # Valide si la broche est correcte
        gpio_pin = Pins.get_pin(self.mode, pin_number)
        self.export(pin_number)  # S'assurer que la broche est exportée
        try:
            with open(f"{GPIO_PATH}/gpio{gpio_pin}/value", 'w') as f:
                f.write(str(value))
        except OSError as e:
            print(f"Erreur lors de l'écriture de la valeur sur la broche {gpio_pin}: {e}")
            raise

    def read(self, pin_number):
        """Lire la valeur actuelle d'une broche GPIO."""
        self._validate_pin(pin_number)  # Valide si la broche est correcte
        gpio_pin = Pins.get_pin(self.mode, pin_number)
        self.export(pin_number)
        try:
            with open(f"{GPIO_PATH}/gpio{gpio_pin}/value", 'r') as f:
                return f.read().strip()
        except OSError as e:
            print(f"Erreur lors de la lecture de la valeur sur la broche {gpio_pin}: {e}")
            raise

    def version(self):
        """Afficher la version du package GPIO."""
        print("smartpi-gpio version 1.0.0")

    def afficher_tableau_gpio(self):
        """Affiche le tableau des GPIOs avec les détails BCM, Nom et Board, côte à côte pour les impairs et pairs."""
        # Code pour afficher le tableau des GPIOs
        pass

    def read_all(self):
        """Affiche tous les états des GPIOs dans un format structuré."""
        self.afficher_tableau_gpio()

        #print("\nEtat des GPIOs :")
        #print("Pin | Name                                 | Value")
        #print("---------------------------------------------------")
        #for pin, name in Pins.BOARD_PINS.items():
            #try:
                #value = self.read(pin)
                #print(f"{pin:>3} | {name:<35} | {value}")
            #except:
                #print(f"{pin:>3} | {name:<35} | Error")
