#!/bin/bash

echo "Installing the blinkenlights functionality"

pushd blinkenlights

python3 -m venv bl-env
source bl-env/bin/activate
pip install adafruit-circuitpython-ssd1306
pip install adafruit-circuitpython-busdevice
pip install pillow
pip install adafruit-blinka
deactivate

popd

echo "blinkenlights installation complete"
echo ""