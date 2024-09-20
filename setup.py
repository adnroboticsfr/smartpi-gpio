from setuptools import setup, find_packages
from setuptools.command.install import install
import subprocess
import os

class PostInstallCommand(install):
    """Commande post-installation pour exécuter le script activate_interfaces.sh."""
    def run(self):
        install.run(self)  # Exécuter l'installation standard
        try:
            # Exécuter le script depuis /usr/local/bin/ après qu'il a été copié
            script_path = '/usr/local/bin/activate_interfaces.sh'

            # Vérifier s'il est bien là et exécuter le script
            if os.path.exists(script_path):
                subprocess.run(['sudo', 'bash', script_path], check=True)
            else:
                print(f"Erreur: Le fichier {script_path} est introuvable.")
        except Exception as e:
            print(f"Erreur lors de l'exécution du script post-installation : {e}")

setup(
    name="smartpi-gpio",
    version="1.0.0",
    description="Gestion des GPIO pour Smart Pi One",
    author="ADNroboticsfr",
    packages=find_packages(),
    scripts=['bin/gpio'],  # Copie le script gpio dans /usr/local/bin
    data_files=[
        ('/usr/local/bin', ['bin/activate_interfaces.sh']),  # Copier activate_interfaces.sh dans /usr/local/bin
    ],
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
