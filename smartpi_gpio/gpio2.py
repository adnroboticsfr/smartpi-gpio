import os
from .pins import Pins, PinMode
from colorama import Fore, Style, init

init()

GPIO_PATH = '/sys/class/gpio'

class InvalidPinError(Exception):
    def __init__(self, pin_number, mode):
        super().__init__(f"Error: Pin {pin_number} is not valid in {mode} mode.")

class GPIO:
    def __init__(self, mode=PinMode.BOARD):
        self.mode = mode
        print(f"Pin numbering mode: {self.mode}")
    
    def _validate_pin(self, pin_number):
        if not Pins.is_valid_pin(self.mode, pin_number):
            raise InvalidPinError(pin_number, self.mode)

    def export(self, pin_number):
        self._validate_pin(pin_number)
        gpio_pin = Pins.get_pin(self.mode, pin_number)
        if not os.path.exists(f"{GPIO_PATH}/gpio{gpio_pin}"):
            try:
                with open(f"{GPIO_PATH}/export", 'w') as f:
                    f.write(str(gpio_pin))
            except OSError as e:
                print(f"Error exporting pin {gpio_pin}: {e}")
                raise

    def unexport(self, pin_number):
        self._validate_pin(pin_number)
        gpio_pin = Pins.get_pin(self.mode, pin_number)
        if os.path.exists(f"{GPIO_PATH}/gpio{gpio_pin}"):
            try:
                with open(f"{GPIO_PATH}/unexport", 'w') as f:
                    f.write(str(gpio_pin))
            except OSError as e:
                print(f"Error unexporting pin {gpio_pin}: {e}")
                raise

    def set_direction(self, pin_number, direction, pull="None"):
        self._validate_pin(pin_number)
        gpio_pin = Pins.get_pin(self.mode, pin_number)
        self.export(pin_number)

        gpio_dir_path = f"{GPIO_PATH}/gpio{gpio_pin}/direction"
        try:
            with open(gpio_dir_path, 'w') as f:
                f.write(direction)
        except OSError as e:
            print(f"Error setting direction for GPIO {gpio_pin}: {e}")
            raise

        if pull:
            self.set_pull_resistor(gpio_pin, pull)

    def set_pull_resistor(self, gpio_pin, pull):
        if pull == "pull-up":
            print(f"Pull-up resistor enabled for pin {gpio_pin}")
        elif pull == "pull-down":
            print(f"Pull-down resistor enabled for pin {gpio_pin}")
        elif pull == "none":
            print(f"No internal resistor configured for pin {gpio_pin}")
        else:
            raise ValueError("Invalid resistor type. Use 'pull-up', 'pull-down', or 'none'.")

    def write(self, pin_number, value):
        self._validate_pin(pin_number)
        gpio_pin = Pins.get_pin(self.mode, pin_number)
        self.export(pin_number)
        try:
            with open(f"{GPIO_PATH}/gpio{gpio_pin}/value", 'w') as f:
                f.write(str(value))
        except OSError as e:
            print(f"Error writing value to pin {gpio_pin}: {e}")
            raise

    def read(self, pin_number):
        self._validate_pin(pin_number)
        gpio_pin = Pins.get_pin(self.mode, pin_number)
        self.export(pin_number)
        try:
            with open(f"{GPIO_PATH}/gpio{gpio_pin}/value", 'r') as f:
                return f.read().strip()
        except OSError as e:
            print(f"Error reading value from pin {gpio_pin}: {e}")
            raise

    def afficher_tableau_gpio(self):
        """Affiche le tableau des GPIOs avec les détails BCM, Nom et Board, côte à côte pour les impairs et pairs."""
        # Largeur des colonnes ajustée pour prendre plus de place à l'écran
        width = 11

        # Fonction pour tronquer le texte trop long (uniquement pour les chaînes)
        def truncate(text, max_length):
            if isinstance(text, str) and len(text) > max_length:
                return text[:max_length-1] + "…"  # Tronque et ajoute un point de suspension
            return text

        # Fonction pour colorer les noms de GPIOs en vert et les tensions (5V, 3.3V) en rouge
        def color_text(text, is_bcm_or_board=False):
            if "5V" in text or "3.3V" in text:
                return f"{Fore.RED}{text}{Style.RESET_ALL}"
            elif "GPIO" in text and not is_bcm_or_board:
                return f"{Fore.GREEN}{text}{Style.RESET_ALL}"
            return text

        # En-tête du tableau avec centrage
        header = f"| {'LINUX gpio':^{width}} | {'Name':^{width}} | {'Board':^{width}} | {'Board':^{width}} | {'Name':^{width}} | {'LINUX gpio':^{width}} |"
        
        print("")
        print("-" * len(header))
        print(" ".center((width * 3) + 1) + "GPIO - Smart Pi One")
        print("-" * len(header))
        print(header)
        print("-" * len(header))

        # Récupère les GPIOs impairs et pairs
        impairs = [(Pins.BCM_PINS.get(pin, ""), Pins.NAME_PINS.get(pin, ""), "( "+str(pin)+" )") for pin in sorted(Pins.NAME_PINS.keys()) if pin % 2 != 0]
        pairs = [(Pins.BCM_PINS.get(pin, ""), Pins.NAME_PINS.get(pin, ""), "( "+str(pin)+" )") for pin in sorted(Pins.NAME_PINS.keys()) if pin % 2 == 0]

        # Nombre maximal de lignes
        max_lines = max(len(impairs), len(pairs))

        for i in range(max_lines):
            # Données pour les lignes impaires
            if i < len(impairs):
                bcm_odd, name_odd, board_odd = impairs[i]
            else:
                bcm_odd = name_odd = board_odd = ""

            # Données pour les lignes paires
            if i < len(pairs):
                bcm_even, name_even, board_even = pairs[i]
            else:
                bcm_even = name_even = board_even = ""

            # Tronquer uniquement les valeurs de type chaîne de caractères (Name)
            name_odd = truncate(name_odd, width)
            name_even = truncate(name_even, width)

            # Créer les lignes avant d'appliquer les couleurs pour garder la bonne largeur
            line = f"| {bcm_odd:^{width}} | {name_odd:^{width}} | {board_odd:^{width}} | {board_even:^{width}} | {name_even:^{width}} | {bcm_even:^{width}} |"
            
            # Appliquer les couleurs après avoir formaté les lignes
            colored_line = line.replace(name_odd, color_text(name_odd)).replace(name_even, color_text(name_even))
            colored_line = colored_line.replace(bcm_odd, color_text(bcm_odd, True)).replace(bcm_even, color_text(bcm_even, True))
            
            print(colored_line)
        
        print("-" * len(header))


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

            
    def version(self):
        print("smartpi-gpio version 1.0.0")
