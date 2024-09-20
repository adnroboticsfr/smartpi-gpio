from setuptools import setup, find_packages
from setuptools.command.install import install
import subprocess
import os

class PostInstallCommand(install):
    """Commande post-installation pour exécuter le script activate_interfaces.sh après l'installation."""
    def run(self):
        install.run(self)  # Exécuter le processus d'installation standard
        try:
            # Chemin vers le script dans /usr/local/bin après qu'il a été copié
            script_dest = '/usr/local/bin/activate_interfaces.sh'

            # Vérifier que le script a bien été copié
            if os.path.exists(script_dest):
                # Rendre le script exécutable
                subprocess.run(['chmod', '+x', script_dest], check=True)

                # Exécuter le script
                subprocess.run(['sudo', 'bash', script_dest], check=True)
            else:
                print(f"Erreur : Le fichier {script_dest} est introuvable.")
        except subprocess.CalledProcessError as e:
            print(f"Erreur lors de l'exécution du script post-installation : {e}")

setup(
    name="smartpi-gpio",
    version="1.0.0",
    description="Gestion des GPIO pour Smart Pi One",
    author="ADNroboticsfr",
    packages=find_packages(),
    scripts=['bin/gpio'],  # Ne pas inclure activate_interfaces.sh ici
    data_files=[('/usr/local/bin', ['bin/activate_interfaces.sh'])],  # Copie le script dans /usr/local/bin
    install_requires=[
        'Flask>=2.0.0',
        'Pillow>=8.0.0',
        'smbus2>=0.4.3',
        'luma.core>=1.0.0',
        'luma.oled>=1.0.0',
        'colorama>=0.4.6'
    ],
    cmdclass={
        'install': PostInstallCommand,
    },
    classifiers=[
        "Programming Language :: Python :: 3",
        "Operating System :: POSIX :: Linux",
    ],
)
