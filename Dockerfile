# Stage 1: Build the application

# Use a lightweight Node.js base image for building the application
FROM node:23-alpine AS build

# Set the working directory inside the container
WORKDIR /app

# Copy package.json and package-lock.json for dependency installation
COPY package*.json ./

# Install dependencies using npm ci for a clean install
RUN npm ci

# Copy the entire project directory to the container
COPY . .

# Build the application
RUN npm run build

# Stage 2: Serve the application with Nginx

# Use a slim version of Nginx for lightweight and efficient serving
FROM nginx:1.27.4-alpine-slim

# Set the working directory to Nginx's default HTML directory
WORKDIR /usr/share/nginx/html

# Install curl for debugging and health checks (optional)
RUN apk add --no-cache curl  

# Copy the built application from the previous stage to the Nginx serving directory
COPY --from=build /app/dist ./

# Copy custom Nginx configuration file to override default settings
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port 80 for HTTP traffic
EXPOSE 80

# Start Nginx in the foreground to keep the container running
CMD ["nginx", "-g", "daemon off;"]
