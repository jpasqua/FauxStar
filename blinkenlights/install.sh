#!/bin/bash

echo "Installing the blinkenlights functionality"

pushd blinkenlights

echo "== Creating a python virtual environment"
python3 -m venv bl-env
source bl-env/bin/activate
echo "== Installing libraries..."
echo ""
echo "   == adafruit-circuitpython-ssd1306"
pip install adafruit-circuitpython-ssd1306
echo ""
echo "   == adafruit-circuitpython-busdevice"
pip install adafruit-circuitpython-busdevice
echo ""
echo "   == pillow"
pip install pillow
echo ""
echo "   == adafruit-blinka"
pip install adafruit-blinka
deactivate

popd

echo "blinkenlights installation complete"
echo ""