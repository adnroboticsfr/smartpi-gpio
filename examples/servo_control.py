from smartpi_gpio.servomotor import ServoMotor
import time

# Create an instance of ServoMotor for channel 0
servo = ServoMotor(channel=0)

try:
    while True:
        # Sweep the servo from 0 to 180 degrees in steps of 30 degrees
        for angle in range(0, 181, 30):
            servo.set_angle(angle)  # Set the servo to the specified angle
            time.sleep(1)  # Wait for 1 second at each angle
except KeyboardInterrupt:
    pass  # Gracefully handle a keyboard interrupt to stop the program

