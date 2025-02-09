

## Build
Build the client:
```
haxelib install client.hxml
haxe client.hxml
```
Build the website:
```
haxelib install website.hxml
haxe website.hxml
cd website-bin; npm install;cd ..
```

## Launch
You'll need to have a Redis instance running:
```
sudo service redis-server restart
```
Start the node app
```
node website-bin/website.js
```

## TODO

- Bitmaps not drawn properly
- Key listeners disabled
- Focus broken in user termninal
- Tab may be incorrectly disabled
- Live videos aren't loaded
- Bitmaps attached at layer 0 instead of 1
- Effects don't use smc layer
