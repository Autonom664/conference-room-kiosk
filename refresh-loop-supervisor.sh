#!/bin/bash
# Wrapper for refresh-loop.sh with auto-restart on crash

MAX_RETRIES=10
RETRY_DELAY=5
RETRY_COUNT=0

while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
  # Run the refresh loop
  bash /home/admin/refresh-loop.sh
  
  # If we get here, the script exited unexpectedly
  RETRY_COUNT=$((RETRY_COUNT + 1))
  echo "$(date '+%Y-%m-%d %H:%M:%S') - refresh-loop.sh crashed (attempt $RETRY_COUNT/$MAX_RETRIES)" >> /var/log/kiosk-refresh.log
  
  # Exponential backoff: 5s, 10s, 20s, etc.
  sleep_time=$((RETRY_DELAY * (2 ** (RETRY_COUNT - 1))))
  echo "$(date '+%Y-%m-%d %H:%M:%S') - Restarting in ${sleep_time}s..." >> /var/log/kiosk-refresh.log
  sleep $sleep_time
done

echo "$(date '+%Y-%m-%d %H:%M:%S') - MAX_RETRIES exceeded. Giving up." >> /var/log/kiosk-refresh.log
exit 1
