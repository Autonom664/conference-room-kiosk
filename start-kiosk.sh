#!/bin/bash
cd /home/admin/kiosk-loader
python3 -m http.server 8000 &

/usr/bin/chromium-browser --kiosk --app=http://localhost:8000
