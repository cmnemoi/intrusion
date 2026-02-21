FROM haxe:4.3-alpine

WORKDIR /app

# Install Node.js and npm
RUN apk update && apk upgrade --no-cache && apk add --no-cache nodejs npm

# Copy Haxe files
COPY . .

# Setup haxelib (required for first run, must be done as root)
RUN haxelib setup /app/.haxelib

# Install haxelib dependencies
RUN haxelib install haxelib.json

# Build client
RUN haxe client.hxml

# Build website
RUN haxe website.hxml

# Install npm dependencies
RUN cd website-bin && npm install

# Create a non-root user
RUN adduser -D app

# Change ownership to non-root user
RUN chown -R app:app /app

# Switch to non-root user
USER app

# Expose port
EXPOSE 8001

# Run the app
CMD ["node", "website-bin/website.js"]
