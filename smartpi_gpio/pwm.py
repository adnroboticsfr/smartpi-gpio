import os

class PWMGPIO:
    def __init__(self, pwm_chip=0, pwm_channel=0):
        self.pwm_chip = pwm_chip
        self.pwm_channel = pwm_channel
        self.pwm_path = f"/sys/class/pwm/pwmchip{pwm_chip}/pwm{pwm_channel}"
        self._export_pwm()

    def _export_pwm(self):
        if not os.path.exists(self.pwm_path):
            try:
                with open(f"/sys/class/pwm/pwmchip{self.pwm_chip}/export", 'w') as f:
                    f.write(str(self.pwm_channel))
            except IOError as e:
                print(f"Failed to export PWM channel {self.pwm_channel}: {e}")
                raise

    def _write_file(self, filename, value):
        try:
            with open(filename, 'w') as f:
                f.write(str(value))
        except IOError as e:
            print(f"Failed to write to {filename}: {e}")
            raise

    def start_pwm(self, duty_cycle=0, period=1000000):
        if not (0 <= duty_cycle <= period):
            raise ValueError("Duty cycle must be between 0 and period")
        if period <= 0:
            raise ValueError("Period must be positive")

        self._write_file(f"{self.pwm_path}/period", period)
        self._write_file(f"{self.pwm_path}/duty_cycle", duty_cycle)
        self._write_file(f"{self.pwm_path}/enable", "1")

    def change_duty_cycle(self, duty_cycle):
        if not (0 <= duty_cycle <= self._read_period()):
            raise ValueError("Duty cycle must be between 0 and the current period")
        self._write_file(f"{self.pwm_path}/duty_cycle", duty_cycle)

    def _read_period(self):
        try:
            with open(f"{self.pwm_path}/period", 'r') as f:
                return int(f.read().strip())
        except IOError as e:
            print(f"Failed to read period from {self.pwm_path}/period: {e}")
            raise

    def stop_pwm(self):
        self._write_file(f"{self.pwm_path}/enable", "0")
