from setuptools import setup, find_packages
from setuptools.command.install import install
import subprocess
import os

class PostInstallCommand(install):
    """Post-installation for setup script to run activate_interfaces.sh."""
    def run(self):
        install.run(self)  # Run the default installation
        try:
            # Running the post-installation script to activate interfaces
            script_path = os.path.join(os.path.dirname(__file__), 'bin/activate_interfaces.sh')
            subprocess.run(['sudo', 'bash', script_path], check=True)
        except subprocess.CalledProcessError as e:
            print(f"Error running post-installation script: {e}")

setup(
    name="smartpi-gpio",
    version="1.0.0",
    description="GPIO management for Smart Pi One",
    author="ADNroboticsfr",
    packages=find_packages(),
    scripts=['bin/gpio'],  # Only include `bin/gpio` in the scripts section
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
