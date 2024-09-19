from smartpi_gpio.pca9685 import PCA9685

class ServoMotor:
    def __init__(self, channel=0):
        self.pwm = PCA9685()
        self.channel = channel
        self.pwm.set_pwm_freq(50) 

    def set_angle(self, angle):
        if not (0 <= angle <= 180):
            raise ValueError("Angle must be between 0 and 180 degrees")
        pulse = self._angle_to_pulse(angle)
        self.pwm.set_pwm(self.channel, 0, pulse)

    def _angle_to_pulse(self, angle):
        pulse = int(4096 * ((angle * 11) + 500) / 20000)
        return pulse
