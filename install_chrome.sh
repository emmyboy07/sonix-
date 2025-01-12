#!/bin/bash

echo "Updating packages..."
apt-get update && apt-get install -y wget gnupg

echo "Adding Google Chrome's signing key..."
wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -

echo "Adding Chrome to the package sources..."
sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list'

echo "Installing Google Chrome..."
apt-get update && apt-get install -y google-chrome-stable

echo "Google Chrome installed successfully!"
