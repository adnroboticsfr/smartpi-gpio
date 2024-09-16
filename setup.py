from setuptools import setup, find_packages
import shutil
import os
import sys

def install_script():
    script_name = 'gpio'
    source_script = os.path.join(os.path.dirname(__file__), 'bin', f'{script_name}.py')
    target_path = '/usr/bin/' + script_name

    if not os.path.isfile(source_script):
        print(f"Source script {source_script} not found.")
        sys.exit(1)

    try:
        shutil.copy(source_script, target_path)
        os.chmod(target_path, 0o755)
        print(f'Successfully installed {script_name} to /usr/bin and made it executable.')
    except Exception as e:
        print(f'Error: {e}')
        sys.exit(1)

setup(
    name='smart-pi-gpio',
    version='1.0.0',
    packages=find_packages(),
    scripts=['bin/gpio.py'],  # Specifie le script à installer
    cmdclass={
        'install': install_script  # Appelle le script d'installation personnalisé
    },
)
