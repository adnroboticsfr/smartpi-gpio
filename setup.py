from setuptools import setup, find_packages

setup(
    name="smartpi-gpio",
    version="1.0.0",
    description="Gestion des GPIO pour Smart Pi One",
    author="Votre Nom",
    packages=find_packages(),
    entry_points={
        'console_scripts': [
            'gpio-smpi=bin.gpio-smpi:main',
        ],
    },
    install_requires=[],  # Ajoutez les dépendances ici si nécessaire
)
