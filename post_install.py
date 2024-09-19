import subprocess

def run_post_install_script():
    try:
        subprocess.run(['/usr/local/bin/activate_interfaces.sh'], check=True)
    except Exception as e:
        print(f"Erreur lors de l'exécution du script d'installation : {e}")

if __name__ == "__main__":
    run_post_install_script()
