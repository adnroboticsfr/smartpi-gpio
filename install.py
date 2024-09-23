import shutil
import os

def main():
    source = 'bin/enable_interfaces'
    destination = '/usr/local/bin/enable_interfaces'
    
    # Copier le fichier
    shutil.copy(source, destination)
    # Rendre le fichier exécutable
    os.chmod(destination, 0o755)

if __name__ == '__main__':
    main()
