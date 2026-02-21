# Stage 1: Build stage
FROM haxe:4.3-alpine AS builder

WORKDIR /app

# Install Node.js and npm
RUN apk update && apk upgrade --no-cache && apk add --no-cache nodejs npm

# Copy Haxe files
COPY . .

# Install haxelib dependencies
RUN haxelib install haxelib.json

# Build client
RUN haxe client.hxml

# Build website
RUN haxe website.hxml

# Install npm dependencies
RUN cd website-bin && npm install

# Stage 2: Production stage
FROM node:lts-alpine AS production

WORKDIR /app

# Update and upgrade
RUN apk update && apk upgrade --no-cache

# Create a non-root user
RUN adduser -D app

# Copy only the necessary artifacts from builder
COPY --from=builder /app/www /app/www
COPY --from=builder /app/website-bin /app/website-bin
COPY --from=builder /app/website /app/website

# Change ownership to non-root user
RUN chown -R app:app /app

# Switch to non-root user
USER app

# Expose port
EXPOSE 8001

# Run the app
CMD ["node", "website-bin/website.js"]
