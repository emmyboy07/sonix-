#!/bin/bash

# Update package list and install prerequisites
echo "Updating package list and installing prerequisites..."
apt-get update && apt-get install -y \
    fonts-liberation \
    libappindicator3-1 \
    libasound2 \
    libatk-bridge2.0-0 \
    libcups2 \
    libdbus-1-3 \
    libgbm-dev \
    libnspr4 \
    libnss3 \
    libx11-xcb1 \
    libxcomposite1 \
    libxdamage1 \
    libxrandr2 \
    xdg-utils \
    wget \
    libu2f-udev

# Install Chromium or Google Chrome
echo "Installing Chromium..."
apt-get install -y chromium chromium-driver

# Confirm installation and path
CHROME_PATH=$(which chromium || which google-chrome)
if [ -z "$CHROME_PATH" ]; then
    echo "Failed to install Chromium or Chrome. Exiting."
    exit 1
fi

# Print installed Chrome version
echo "Installed Chrome/Chromium version:"
$CHROME_PATH --version

# Export CHROME_PATH for Puppeteer
echo "Setting CHROME_PATH to $CHROME_PATH..."
export CHROME_PATH=$CHROME_PATH

# Write to profile.d for future shells
echo "export CHROME_PATH=$CHROME_PATH" > /etc/profile.d/chrome_path.sh
chmod +x /etc/profile.d/chrome_path.sh

echo "Installation complete. CHROME_PATH is set to $CHROME_PATH."
