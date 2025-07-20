#!/usr/bin/env sh
cat ~/.librewolf/default/browser-extension-data/uBlock0@raymondhill.net/storage.js | jq -r '.dynamicFilteringString' > ublock-rules.txt
