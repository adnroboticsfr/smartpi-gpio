from setuptools import setup, find_packages

setup(
    name='smart-pi-gpio',
    version='1.0.0',
    packages=find_packages(),
    entry_points={
        'console_scripts': [
            'gpio=gpio.gpio:main',
        ],
    },
    scripts=['bin/gpio.py'],  # Assurez-vous que le chemin est correct
)
