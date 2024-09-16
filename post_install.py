# post_install.py
import shutil
import os
import sys

def main():
    script_name = 'gpio'
    bin_path = os.path.join(sys.prefix, 'bin', script_name)
    target_path = '/usr/bin/' + script_name

    # Move the script to /usr/bin
    try:
        shutil.move(bin_path, target_path)
        os.chmod(target_path, 0o755)
        print(f'Successfully moved {script_name} to /usr/bin and made it executable.')
    except Exception as e:
        print(f'Error: {e}')

if __name__ == "__main__":
    main()
