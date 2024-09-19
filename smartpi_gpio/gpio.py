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
