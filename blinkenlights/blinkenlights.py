"""
Provide "blinkenlights" for FauxStar. This includes the Maintenance Panel (MP) and floppy activity LED.

Options:
    -m | --mpcode NUMBER : Sets the maintenance panel code to NUMBER.
    -t | --text String   : Set the Maintenance Panel code to a 4-char string.
    -f | --fakeactivity  : Enables the LED blinking activity.
    -s | --stop          : Clear the Maintenance Panel and exit
    -h | --help          : Displays help information.

Two concurrent threads control the lights:

1. **MP Loop (Maintenance Panel Loop)**:
    - Displays a number (0-9999) on an OLED display connected via I2C.
    - If the input exceeds 10,000, it is displayed modulo 10,000.
    - If a negative number is read, the OLED screen clears, and the thread terminates.

2. **LED Blink Loop**:
    - Controls the Floppy LED (GPIO pin).
    - Waits between 10 and 20 seconds, then blinks the LED between 3 and 8 times.
    - Blinks last 0.1 seconds on and 0.1 seconds off.
    - Runs indefinitely but checks for a stop signal from the MP loop.

Program Exit:
    - The main thread waits for the MP loop to finish, signals the LED loop to stop, and cleans up GPIO resources.

Dependencies:
    - Adafruit CircuitPython SSD1306 for OLED display control.
    - Pillow for rendering fonts and images on the display.
    - RPi.GPIO for controlling the LED via GPIO.
    - Python threading for managing concurrent threads.

"""

import os
import sys
import argparse
import threading
import time
import random
import RPi.GPIO as GPIO
import board
import busio
from PIL import Image, ImageDraw, ImageFont
import adafruit_ssd1306

# Constants
LED_PIN = 17
BLINK_DURATION = 0.1  # Time in seconds for LED blink on/off
OLED_WIDTH = 128
OLED_HEIGHT = 32
FONT_SIZE = 32
FONT_NAME = "DSEG7Classic-BoldItalic.ttf"
FONT_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), FONT_NAME)

# Event to signal the led_blink_loop to stop
stop_event = threading.Event()

# Argument parser setup
def parse_args():
    parser = argparse.ArgumentParser(description="Provide 'blinkenlights' for FauxStar.")
    parser.add_argument("-s", "--stop", action="store_true", help="Clear the Maintenance Panel and LED, then quit.")
    parser.add_argument("-m", "--mpcode", type=int, help="Set the Maintenance Panel code to a NUMBER.")
    parser.add_argument("-t", "--text", type=str, help="Set the Maintenance Panel code to a 4-char string.")
    parser.add_argument("-f", "--fakeactivity", action="store_true", help="Enable the fake LED blinking activity.")
    return parser.parse_args()

# GPIO setup and cleanup functions
def setup_gpio():
    """Setup the GPIO pin for the LED."""
    GPIO.setmode(GPIO.BCM)
    GPIO.setup(LED_PIN, GPIO.OUT)

def cleanup_gpio():
    """Ensure LED is off and cleanup GPIO resources."""
    GPIO.output(LED_PIN, GPIO.LOW)
    GPIO.cleanup()

# OLED Display setup
def setup_oled():
    """Initialize and return an OLED display object."""
    i2c = busio.I2C(board.SCL, board.SDA)
    oled = adafruit_ssd1306.SSD1306_I2C(OLED_WIDTH, OLED_HEIGHT, i2c)
    oled.fill(0)
    oled.show()
    return oled

# Update the display with a 4-character (max) string
def update_display_with_text(display_text, oled):
    font = ImageFont.truetype(FONT_PATH, FONT_SIZE)
    image = Image.new('1', (OLED_WIDTH, OLED_HEIGHT))
    draw = ImageDraw.Draw(image)

    # Get the size of the text to be drawn
    bbox = draw.textbbox((0, 0), display_text, font=font)
    text_width = bbox[2] - bbox[0]
    text_height = bbox[3] - bbox[1]

    if text_height > OLED_HEIGHT:
        print("Warning: Text height exceeds the viewable area!")

    # Calculate the position to center the text
    x = (OLED_WIDTH - text_width) // 2
    y = (OLED_HEIGHT - text_height) // 2

    # Draw the text onto the image
    draw.text((x, y), display_text, font=font, fill=255)  # '255' for white text

    oled.image(image)
    oled.show()

# Update the display with a number
def update_display(number, oled, leading_zeroes=False):
    display_text = f"{number:04d}" if leading_zeroes else str(number)
    update_display_with_text(display_text, oled);

# MP Loop (Maintenance Panel Loop)
def mp_loop(initial_code=None, initial_text=None):
    """Thread that reads numbers from stdin and displays them on the OLED."""
    oled = setup_oled()
    
    if initial_text is not None:
        update_display_with_text(initial_text, oled)
    elif initial_code is not None:
        update_display(initial_code, oled, leading_zeroes=True)
    
    for line in sys.stdin:
        line = line.strip()
        if not line.lower().startswith("mpcode:"):
            continue  # Ignore lines that don't start with "MPCODE:"

        # Split the line into parts using ":" as a delimiter
        parts = line.split(":", 1)
        if len(parts) != 2:
            continue  # Ignore lines that can't be split into exactly two parts

        # Extract and validate the number part
        try:
            number = int(parts[1].strip())
        except ValueError:
            continue  # Ignore lines where the second part is not a valid integer

        if number < 0:
            oled.fill(0)  # Clear the OLED screen
            oled.show()   # Update the screen to show the clear state
            break

        # Handle modulo 10000 for numbers greater than 9999
        number = number % 10000
        update_display(number, oled, leading_zeroes=True)

# LED Blink Loop
def led_blink_loop():
    """Thread that blinks the LED at random intervals."""
    while not stop_event.is_set():
        # Wait for a random time between 10 and 20 seconds
        total_wait_time = random.randint(10, 20)
        elapsed_time = 0
        
        # Check for stop event during the wait time
        while elapsed_time < total_wait_time:
            if stop_event.is_set():
                return  # Exit if stop event is set during waiting
            time.sleep(0.1)
            elapsed_time += 0.1

        # Blink the LED a random number of times between 3 and 8
        blink_count = random.randint(3, 8)
        for _ in range(blink_count):
            if stop_event.is_set():
                break  # Exit if stop event is set during blinking
            GPIO.output(LED_PIN, GPIO.HIGH)  # Turn LED on
            time.sleep(BLINK_DURATION)
            GPIO.output(LED_PIN, GPIO.LOW)   # Turn LED off
            time.sleep(BLINK_DURATION)

# Thread management functions
def start_threads(fakeactivity, mpcode=None, mptext=None):
    """Start the MP and LED blink threads."""
    mp_thread = threading.Thread(target=mp_loop, args=(mpcode,mptext,))
    mp_thread.start()
    
    led_thread = None
    if fakeactivity:
        led_thread = threading.Thread(target=led_blink_loop)
        led_thread.start()

    return mp_thread, led_thread

def stop_threads(mp_thread, led_thread=None):
    """Stop the MP and LED blink threads, ensuring clean exit."""
    mp_thread.join()  # Wait for MP loop to complete
    
    if led_thread:
        stop_event.set()  # Signal LED thread to stop
        led_thread.join()

# Main function
if __name__ == "__main__":
    args = parse_args()
    # args.text has precedence over args.mpcode and is at most 4 characters
    if args.text is not None:
        args.mpcode = None
        args.text = args.text[:4]  # Truncate to 4 characters

    try:
        setup_gpio()
        if args.stop:
            setup_oled()            # Initialize and clear the screen
            if args.fakeactivity:   # Turn off Faux Activity LED
                GPIO.output(LED_PIN, GPIO.LOW)
        else:
            mp_thread, led_thread = start_threads(args.fakeactivity, args.mpcode, args.text)
            stop_threads(mp_thread, led_thread)
    finally:
        cleanup_gpio()

