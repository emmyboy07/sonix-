# Use official Node.js image
FROM node:16

# Set working directory
WORKDIR /app

# Install Chromium dependencies
RUN apt-get update && apt-get install -y \
    wget \
    ca-certificates \
    fonts-liberation \
    libappindicator3-1 \
    libasound2 \
    libatk-bridge2.0-0 \
    libatk1.0-0 \
    libcups2 \
    libdbus-1-3 \
    libgdk-pixbuf2.0-0 \
    libnspr4 \
    libnss3 \
    libx11-xcb1 \
    libxcomposite1 \
    libxdamage1 \
    libxrandr2 \
    xdg-utils \
    && rm -rf /var/lib/apt/lists/*

# Install Puppeteer
RUN npm install puppeteer

# Copy package.json and install dependencies
COPY package*.json ./
RUN npm install

# Copy all the necessary files into the container
COPY . .

# Expose the port
EXPOSE 3000

# Start the application
CMD ["node", "server.js"]
