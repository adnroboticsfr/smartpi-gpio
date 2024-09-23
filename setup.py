from setuptools import setup, find_packages
from setuptools.command.install import install
import subprocess
import os

class PostInstallCommand(install):
    """Post-installation script to execute activate_interfaces.sh and enable_features.sh."""
    def run(self):
        install.run(self)  # Run the standard installation process
        try:
            # Paths to the scripts in the bin/ directory
            activate_script_path = 'install.py'
            enable_script_path = '/usr/local/bin/enable_interfaces.sh'

            print(f"Script path for activation: {activate_script_path}")
            print(f"Script path for enabling features: {enable_script_path}")
        
            # Check if activate_interfaces.sh exists
            if os.path.exists(activate_script_path):
                # Make the script executable
                subprocess.run(['chmod', '+x', activate_script_path], check=True)

                # Execute the script
                subprocess.run(['python3', activate_script_path], check=True)
            else:
                print(f"Error: The file {activate_script_path} is not found.")

            # Check if enable_features.sh exists
            if os.path.exists(enable_script_path):
                # Make the script executable
                subprocess.run(['chmod', '+x', enable_script_path], check=True)

                # Execute the script
                subprocess.run(['bash', enable_script_path], check=True)
            else:
                print(f"Error: The file {enable_script_path} is not found.")

        except subprocess.CalledProcessError as e:
            print(f"Error executing the post-installation script: {e}")

setup(
    name="smartpi-gpio",
    version="1.0.0",
    description="GPIO management for Smart Pi One",
    author="ADNroboticsfr",
    packages=find_packages(),
    scripts=['bin/gpio'],  # Include only the gpio script
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
