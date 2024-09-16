from setuptools import setup, find_packages

setup(
    name="smartpi-gpio",
    version="1.0.0",
    description="Gestion des GPIO pour Smart Pi One",
    author="Votre Nom",
    packages=find_packages(),
    scripts=['bin/gpio-smpi'],
    classifiers=[
        "Programming Language :: Python :: 3",
        "Operating System :: POSIX :: Linux",
    ],
)
