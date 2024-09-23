from setuptools import setup, find_packages
from setuptools.command.install import install
import subprocess
import os
import shutil

class PostInstallCommand(install):
    """Post-installation script to execute activate_interfaces.sh and enable_features.sh."""
    def run(self):
        install.run(self)  # Run the standard installation process
        try:
            # Paths to the scripts in the bin/ directory
            activate_script_path = 'bin/activate_interfaces.sh'
            enable_script_path = 'bin/enable_interfaces.sh'
            
            # Destination paths in /usr/local/bin/
            activate_dest_path = '/usr/local/bin/activate_interfaces.sh'
            enable_dest_path = '/usr/local/bin/enable_interfaces.sh'

            print(f"Copying activation script to {activate_dest_path}")
            print(f"Copying enabling features script to {enable_dest_path}")

            # Check if activate_interfaces.sh exists
            if os.path.exists(activate_script_path):
                # Copy the script to /usr/local/bin/
                shutil.copy(activate_script_path, activate_dest_path)
                # Make the script executable
                subprocess.run(['chmod', '+x', activate_dest_path], check=True)

            else:
                print(f"Error: The file {activate_script_path} is not found.")

            # Check if enable_features.sh exists
            if os.path.exists(enable_script_path):
                # Copy the script to /usr/local/bin/
                shutil.copy(enable_script_path, enable_dest_path)
                # Make the script executable
                subprocess.run(['chmod', '+x', enable_dest_path], check=True)

                # Execute the script
                subprocess.run(['bash', enable_dest_path], check=True)
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
