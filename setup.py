from setuptools import setup, find_packages
from setuptools.command.install import install
import subprocess
import os
import shutil

class PostInstallCommand(install):
    """Post-installation script to copy necessary files and run enable_interfaces.sh."""
    def run(self):
        install.run(self)  # Run the standard installation process

        # Define the bin/ directory where your scripts are stored in your package
        bin_scripts = ['bin/activate_interfaces.sh', 'bin/enable_interfaces.sh']
        
        # Destination folder in /usr/local/bin/
        dest_folder = '/usr/local/bin/'

        # Copy each script to the destination folder
        for script in bin_scripts:
            script_name = os.path.basename(script)
            dest_path = os.path.join(dest_folder, script_name)

            try:
                # Check if the script exists in the package
                if os.path.exists(script):
                    print(f"Copying {script_name} to {dest_path}")
                    shutil.copy(script, dest_path)
                    subprocess.run(['chmod', '+x', dest_path], check=True)
                else:
                    print(f"Error: {script} not found in the package.")
            except subprocess.CalledProcessError as e:
                print(f"Error making {dest_path} executable: {e}")
            except Exception as e:
                print(f"Error copying {script} to {dest_path}: {e}")

        # Run enable_interfaces.sh at the end of installation
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
    package_data={
        # Include the activate_interfaces.sh script in the package
        '': ['bin/activate_interfaces.sh', 'bin/enable_interfaces.sh'],
    },
    include_package_data=True,  # Ensure that package_data is included
    scripts=['bin/gpio'],  # Include the gpio CLI script
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
