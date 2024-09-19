from smartpi_gpio.interrupts import GPIOInterrupts
import time

# Callback function called when an interrupt is detected
def gpio_callback(pin):
    print(f"Interrupt detected on GPIO pin {pin}!")

# Create an instance of GPIOInterrupts
gpio_interrupts = GPIOInterrupts()

# Add an interrupt on pin 11 to detect changes in state (edge='both')
gpio_interrupts.add_interrupt(pin_number=11, edge='both', callback=gpio_callback)

# Start monitoring for interrupts
gpio_interrupts.start_monitoring()

try:
    while True:
        time.sleep(1)  # Keep the program running
except KeyboardInterrupt:
    print("Program stopped...")
finally:
    # Clean up GPIO interrupts before exiting
    gpio_interrupts.cleanup()

