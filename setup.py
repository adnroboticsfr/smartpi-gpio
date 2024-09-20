from setuptools import setup, find_packages
from setuptools.command.install import install
import subprocess
import os
import shutil

class PostInstallCommand(install):
    """Commande post-installation pour exécuter activate_interfaces.sh."""
    def run(self):
        install.run(self)  # Exécuter le processus d'installation standard
        try:
            # Chemin du script à copier
            src_script = os.path.join(os.path.dirname(__file__), 'bin/activate_interfaces.sh')
            dest_script = '/usr/local/bin/activate_interfaces.sh'

            # Copier le script dans /usr/local/bin/
            shutil.copy(src_script, dest_script)
            print(f"Script copié dans {dest_script}")

            # S'assurer que le script est exécutable
            subprocess.run(['sudo', 'chmod', '+x', dest_script], check=True)

            # Exécuter le script après installation
            subprocess.run(['sudo', 'bash', dest_script], check=True)
        except Exception as e:
            print(f"Erreur lors de l'exécution du script post-installation : {e}")

setup(
    name="smartpi-gpio",
    version="1.0.0",
    description="Gestion des GPIO pour Smart Pi One",
    author="ADNroboticsfr",
    packages=find_packages(),
    scripts=['bin/gpio'],  # Le script 'gpio' sera installé dans /usr/local/bin/
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
