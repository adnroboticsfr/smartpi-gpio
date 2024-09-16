# setup.py
from setuptools import setup, find_packages

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
)
