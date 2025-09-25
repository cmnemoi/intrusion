FROM haxe:4.3-alpine

WORKDIR /app

# Install Node.js and npm
RUN apk add --no-cache nodejs npm

# Install haxelib dependencies
RUN haxelib install pixijs
RUN haxelib install pixi-sound
RUN haxelib install haxe-concurrent
RUN haxelib install jsasync
RUN haxelib install hxnodejs
RUN haxelib install json2object
RUN haxelib install hx3compat

# Copy Haxe files
COPY . .

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