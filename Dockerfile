FROM haxe:4.3-alpine

WORKDIR /app

# Install Node.js and npm
RUN apk add --no-cache nodejs npm

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

# Expose port
EXPOSE 8001

# Run the app
CMD ["node", "website-bin/website.js"]