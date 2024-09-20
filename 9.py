        try:
            # Copier le script dans /usr/local/bin
            script_src = os.path.join(os.path.dirname(__file__), 'bin/activate_interfaces.sh')
            script_dest = '/usr/local/bin/activate_interfaces.sh'

            # Copier le script dans /usr/local/bin
            shutil.copy(script_src, script_dest)

            # Rendre le script exécutable
            subprocess.run(['chmod', '+x', script_dest], check=True)

            # Exécuter le script après l'installation
            subprocess.run(['sudo', 'bash', script_dest], check=True)
        except Exception as e:
            print(f"Erreur lors de l'exécution du script post-installation : {e}")