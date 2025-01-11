# Use the official Node.js image as a base image
FROM node:16-slim

# Install necessary dependencies, including Chromium
RUN apt-get update && apt-get install -y \
    wget \
    ca-certificates \
    fonts-liberation \
    libappindicator3-1 \
    libasound2 \
    libx11-xcb1 \
    libxtst6 \
    libnss3 \
    chromium

# Set the environment variable for Chromium's path
ENV CHROME_PATH=/usr/bin/chromium

# Set the working directory in the container
WORKDIR /app

# Copy all the files from the current directory to the /app directory in the container
COPY . .

# Install dependencies defined in package.json
RUN npm install

# Expose the port your app will run on (3000 is the default in your code)
EXPOSE 3000

# Command to run your app (same as `npm start`)
CMD ["npm", "start"]
