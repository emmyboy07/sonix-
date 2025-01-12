# Use an official Node.js runtime as a parent image
FROM node:16-slim

# Set the working directory in the container
WORKDIR /app

# Install dependencies required for Chromium
RUN apt-get update && apt-get install -y \
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
  libu2f-udev \
  chromium \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

# Set environment variable for Puppeteer to use Chromium
ENV PUPPETEER_SKIP_DOWNLOAD=true
ENV CHROME_PATH=/usr/bin/chromium

# Copy package.json and package-lock.json to the working directory
COPY package*.json ./

# Install Node.js dependencies
RUN npm install

# Copy the rest of the application files to the container
COPY . .

# Expose port 3000 for the application
EXPOSE 3000

# Command to run the application
CMD ["node", "server.js"]
