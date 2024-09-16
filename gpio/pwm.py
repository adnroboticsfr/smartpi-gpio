class PWMGPIO:
    def __init__(self, pwm_chip=0, pwm_channel=0):
        self.pwm_path = f"/sys/class/pwm/pwmchip{pwm_chip}/pwm{pwm_channel}"
        if not os.path.exists(self.pwm_path):
            with open(f"/sys/class/pwm/pwmchip{pwm_chip}/export", 'w') as f:
                f.write(str(pwm_channel))

    def start_pwm(self, duty_cycle=0, period=1000000):
        """Start PWM with specified duty cycle and period."""
        with open(f"{self.pwm_path}/period", 'w') as f:
            f.write(str(period))
        with open(f"{self.pwm_path}/duty_cycle", 'w') as f:
            f.write(str(duty_cycle))
        with open(f"{self.pwm_path}/enable", 'w') as f:
            f.write("1")

    def change_duty_cycle(self, duty_cycle):
        """Change the duty cycle of the PWM."""
        with open(f"{self.pwm_path}/duty_cycle", 'w') as f:
            f.write(str(duty_cycle))

    def stop_pwm(self):
        """Stop the PWM."""
        with open(f"{self.pwm_path}/enable", 'w') as f:
            f.write("0")
