#!/bin/bash
echo "Hello, World" "$(hostname)"  > index.html
python3 -m http.server 80 &
