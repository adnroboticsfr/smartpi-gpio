from setuptools import setup, find_packages
from setuptools.command.install import install
import subprocess
import os

class PostInstallCommand(install):
    """Post-installation script to execute activate_interfaces.sh."""
    def run(self):
        install.run(self)  # Run the standard installation process
        try:
            # Chemin direct du script dans le dossier bin/
            script_path = 'bin/activate_interfaces.sh'

            print(f"Chemin du script : {script_path}")

            # Vérifier que le script existe
            if os.path.exists(script_path):
                # Rendre le script exécutable
                subprocess.run(['chmod', '+x', script_path], check=True)

                # Exécuter le script
                subprocess.run(['bash', script_path], check=True)
            else:
                print(f"Erreur : Le fichier {script_path} est introuvable.")
        except subprocess.CalledProcessError as e:
            print(f"Erreur lors de l'exécution du script post-installation : {e}")

setup(
    name="smartpi-gpio",
    version="1.0.0",
    description="Gestion des GPIO pour Smart Pi One",
    author="ADNroboticsfr",
    packages=find_packages(),
    scripts=['bin/gpio'],  # Inclure seulement le script gpio
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
