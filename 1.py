from smartpi_gpio.gpio import GPIO
from smartpi_gpio.pins import PinMode

# Initialisation en mode BCM (par défaut)
gpio = GPIO(PinMode.BCM)

# Exporter une broche pour l'utiliser
pin = 7
gpio.export(pin)

# Configurer la broche en sortie
gpio.set_direction(pin, "out")

# Écrire une valeur sur la broche (allumer)
gpio.write(pin, 1)

# Lire la valeur de la broche
value = gpio.read(pin)
print(f"Valeur actuelle de la broche {pin}: {value}")

# Désactiver la broche (éteindre)
gpio.write(pin, 0)
