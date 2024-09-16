from setuptools import setup

setup(
    name='smartpi-gpio',
    version='1.0.0',
    packages=['gpio'],
    entry_points={
        'console_scripts': [
            'gpio-smpi=bin.gpio-smpi:main',
        ],
    },
    install_requires=[
        # Add your dependencies here
    ],
)
