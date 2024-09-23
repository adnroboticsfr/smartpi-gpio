 
import shutil
import os

def main():
    # Obtenir le chemin absolu du fichier source
    source = os.path.join(os.path.dirname(__file__), 'bin', 'enable_interfaces')
    destination = '/usr/local/bin/enable_interfaces'
    
    # Vérifier si le fichier source existe
    if not os.path.isfile(source):
        print(f"Erreur : Le fichier source '{source}' n'existe pas.")
        return
    
    # Copier le fichier
    shutil.copy(source, destination)
    # Rendre le fichier exécutable
    os.chmod(destination, 0o755)
    print(f"Fichier copié et rendu exécutable : {destination}")

if __name__ == '__main__':
    main()
