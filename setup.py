from setuptools import setup, find_packages
from setuptools.command.install import install as _install
import subprocess

class InstallCommand(_install):
    def run(self):
        _install.run(self)
        subprocess.call(['python3', 'post_install.py'])

setup(
    name="smart_pi_gpio",
    version="1.0.0",
    description="GPIO control for Smart Pi One",
    author="Your Name",
    packages=find_packages(),
    entry_points={
        'console_scripts': [
            'gpio=bin.gpio:main',
        ],
    },
    install_requires=[
        # Add any required dependencies here
    ],
    python_requires='>=3.6',
    cmdclass={
        'install': InstallCommand,
    },
)

