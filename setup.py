from setuptools import setup, find_packages
from setuptools.command.install import install
import subprocess
import os
import shutil

class PostInstallCommand(install):
    """Post-installation script to copy necessary files and run enable_interfaces.sh."""
    def run(self):
        install.run(self)  # Run the standard installation process

        # Paths to the scripts in the bin/ directory
        scripts = ['bin/gpio', 'bin/activate_interfaces.sh', 'bin/enable_interfaces.sh']
        
        # Destination folder in /usr/local/bin/
        dest_folder = '/usr/local/bin/'

        for script in scripts:
            script_name = os.path.basename(script)
            dest_path = os.path.join(dest_folder, script_name)

            try:
                if os.path.exists(script):
                    print(f"Copying {script_name} to {dest_path}")
                    # Copy the script to /usr/local/bin/
                    shutil.copy(script, dest_path)
                    # Make the script executable
                    subprocess.run(['chmod', '+x', dest_path], check=True)
                else:
                    print(f"Error: The file {script} is not found.")
            except subprocess.CalledProcessError as e:
                print(f"Error making {dest_path} executable: {e}")
            except Exception as e:
                print(f"Error copying {script} to {dest_path}: {e}")

        # Run enable_interfaces.sh only after installation is complete
        enable_script_path = os.path.join(dest_folder, 'enable_interfaces.sh')
        if os.path.exists(enable_script_path):
            try:
                print(f"Executing {enable_script_path} at the end of installation")
                subprocess.run(['bash', enable_script_path], check=True)
            except subprocess.CalledProcessError as e:
                print(f"Error executing {enable_script_path}: {e}")

setup(
    name="smartpi-gpio",
    version="1.0.0",
    description="GPIO management for Smart Pi One",
    author="ADNroboticsfr",
    packages=find_packages(),
    scripts=['bin/gpio'],  # Include the gpio script
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
