from smartpi_gpio.oled import OledDisplay
from PIL import Image
import time

# Create an instance of OledDisplay
oled = OledDisplay()

# Example 1: Simple Display with Delay
oled.display_text("Hello Yumi, OLED!")
time.sleep(5)  # Display the message for 5 seconds

# Example 2: Continuous Display (Loop with Refresh)
try:
    while True:
        oled.display_text("Continuous: Hello Yumi!")
        time.sleep(1)  # Refresh every 1 second
        break  # Break after one iteration to move to the next example
except KeyboardInterrupt:
    oled.clear()

# Example 3: Rotating Messages
messages = ["Hello Yumi!", "Welcome to OLED", "SmartPi says hi!"]

try:
    for message in messages:
        oled.display_text(message)
        time.sleep(2)  # Display each message for 2 seconds
except KeyboardInterrupt:
    oled.clear()

# Example 4: Pseudo-scrolling Text
message = "Scrolling text on OLED display!"

try:
    for i in range(len(message)):
        oled.display_text(message[i:i+16])  # Slice the message for scrolling effect
        time.sleep(0.3)  # Adjust the scroll speed
except KeyboardInterrupt:
    oled.clear()

# Example 5: Animate Yumi Logo
# Load the Yumi logo (replace 'logo_yumi.png' with your actual logo file)
logo_path = 'logo_yumi.png'
logo = Image.open(logo_path).convert("1")  # Convert to 1-bit for OLED compatibility

# Get display dimensions (assumed to be 128x64, adjust as needed)
display_width = 128
display_height = 64
logo_width, logo_height = logo.size

# Starting position for the logo
x_pos = 0
y_pos = (display_height - logo_height) // 2  # Center vertically

try:
    while True:
        # Clear the display
        oled.clear()

        # Display the logo image at the current position
        oled.display_image(logo, x_pos, y_pos)

        # Update the position for the horizontal animation
        x_pos += 2  # Move 2 pixels to the right each frame
        if x_pos > display_width:  # Reset if the image goes off the screen
            x_pos = -logo_width  # Start from the left again

        # Delay to control animation speed
        time.sleep(0.05)  # Adjust speed as needed

except KeyboardInterrupt:
    oled.clear()
    print("Animation stopped and display cleared.")

# Clear display after all examples (optional)
oled.clear()
