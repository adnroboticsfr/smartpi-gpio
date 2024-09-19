from luma.core.interface.serial import i2c
from luma.oled.device import ssd1306
from PIL import Image, ImageDraw, ImageFont
import time

# Initialize the I2C interface and the SSD1306 OLED device
serial = i2c(port=1, address=0x3C)  # Adjust port and address if needed
device = ssd1306(serial)

# Define OLED dimensions
width, height = device.width, device.height

# Create a blank image and draw object for updates
buffer = Image.new('1', (width, height))
draw = ImageDraw.Draw(buffer)

# Function to clear the buffer
def clear_buffer():
    draw.rectangle((0, 0, width, height), outline=0, fill=0)

# Function to display text
def display_text(text, duration):
    clear_buffer()

    # Use default font
    font = ImageFont.load_default()

    # Draw the text with the font
    bbox = draw.textbbox((0, 0), text, font=font)
    text_width = bbox[2] - bbox[0]
    text_height = bbox[3] - bbox[1]
    draw.text(((width - text_width) // 2, (height - text_height) // 2), text, font=font, fill=255)

    # Display the buffer on the OLED device
    device.display(buffer)
    time.sleep(duration)

# Function to display image (logo)
def display_image(image_path, x, y):
    # Load and convert the image
    logo = Image.open(image_path).convert("1")  # Convert to 1-bit image

    # Resize image to fit the display using LANCZOS resampling
    logo = logo.resize((width, height), Image.Resampling.LANCZOS)

    # Paste the resized image into the buffer
    buffer.paste(logo, (x, y))

    # Display the buffer on the OLED device
    device.display(buffer)

# Example 1: Simple Display with Delay
display_text("Hello Yumi, OLED!", 5)

# Example 2: Continuous Display (Loop with Refresh)
try:
    while True:
        display_text("Continuous: Hello Yumi!", 1)
        break  # Break after one iteration to move to the next example
except KeyboardInterrupt:
    device.clear()

# Example 3: Rotating Messages
messages = ["Hello Yumi!", "Welcome to OLED", "SmartPi says hi!"]

try:
    for message in messages:
        display_text(message, 2)
except KeyboardInterrupt:
    device.clear()

# Example 4: Pseudo-scrolling Text
message = "Scrolling text on OLED display!"
scroll_speed = 0.05  # Adjust the scroll speed

try:
    # Create an image for scrolling
    scroll_image = Image.new('1', (width + len(message) * 10, height))  # Width for scrolling
    scroll_draw = ImageDraw.Draw(scroll_image)
    font = ImageFont.load_default()

    # Draw the text
    scroll_draw.text((0, 0), message, font=font, fill=255)
    
    # Display scrolling text
    text_width = scroll_draw.textbbox((0, 0), message, font=font)[2]  # Get text width
    for x in range(width, -text_width, -2):
        # Create a sub-image for the visible part
        scrolling_image = scroll_image.crop((x, 0, x + width, height))
        buffer.paste(scrolling_image)
        device.display(buffer)
        time.sleep(scroll_speed)

except KeyboardInterrupt:
    device.clear()

# Example 5: Animate Yumi Logo
logo_path = 'logo_yumi.png'
logo_width = 128  # Adjust as needed
logo_height = 64  # Adjust as needed
x_pos = 0
y_pos = (height - logo_height) // 2

try:
    while True:
        clear_buffer()
        display_image(logo_path, x_pos, y_pos)
        device.display(buffer)
        x_pos += 2
        if x_pos > width:
            x_pos = -logo_width
        time.sleep(0.05)  # Adjust animation speed as needed
except KeyboardInterrupt:
    device.clear()
    print("Animation stopped and display cleared.")

# Clear display after all examples (optional)
device.clear()
