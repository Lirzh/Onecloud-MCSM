#!/bin/bash

cd web || exit
node --max-old-space-size=1024 --enable-source-maps app.js
