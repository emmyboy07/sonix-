# Use official Node.js image
FROM node:16

# Set working directory
WORKDIR /app

# Copy package.json and install dependencies
COPY package*.json ./
RUN npm install

# Copy all the necessary files into the container
COPY . .

# Expose the port
EXPOSE 3000

# Start the application
CMD ["node", "server.js"]
