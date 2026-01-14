# Conference Room Kiosk - Implementation Summary

## ✅ Completed Improvements

### Phase 1: Critical Fixes
- ✅ **Booking Confirmation** - All booking scripts now send toast notifications with "✓ Room Booked" message and availability time
- ✅ **Cancel Booking** - New `script.cancel_last_booking` deletes most recent "Booked from touch panel" event with confirmation
- ✅ **Refresh Investigation** - Confirmed 60-second refresh loop is active; immediate refresh happens when button is pressed

### Phase 2: Feature Enhancements
- ✅ **Booking Duration Selector** - Three duration options now available:
  - 15 minutes: `script.book_conference_room_15_min`
  - 30 minutes: `script.book_conference_room_30_min` (default)
  - 60 minutes: `script.book_conference_room_60_min`
  - UI shows popup when "BOOK NOW" is tapped

- ✅ **Countdown Timer** - New sensor `room_available_at` shows:
  - "Now" - Room is immediately available
  - "In Xm" - Minutes until available
  - "In Xh Ym" - Hours and minutes format
  - "Available" - No upcoming bookings today

- ✅ **Error Handling** - All booking scripts include:
  - Try/catch logic with notification service
  - Error messages sent via `notify.notify`
  - Script mode: `single` to prevent race conditions

### Phase 3: System Reliability
- ✅ **Auto-Restart for refresh-loop** - New `refresh-loop-supervisor.sh` wraps the main loop with:
  - Exponential backoff (5s, 10s, 20s, 40s...)
  - Max 10 retries before giving up
  - Logging to `/var/log/kiosk-refresh.log`

- ✅ **Systemd Services** - Two production services created:
  - `kiosk.service` - Launches Chromium browser with auto-restart
  - `kiosk-refresh.service` - Manages refresh loop supervisor
  - Both set to `Restart=always` for production reliability
  - Auto-start on system boot via `multi-user.target`

### Phase 4: Dashboard Design Improvements
- ✅ **New UI Layout** - Improved dashboard with:
  - Single-column layout optimized for 9" screen
  - Larger, more readable text (24px+ fonts)
  - Color-coded status (green=available, red=occupied/booked, blue=bookable, gray=disabled)
  - Better visual hierarchy

- ✅ **Enhanced Cards**:
  - Occupancy card shows "AVAILABLE" or "OCCUPIED"
  - Booking card shows "BOOK NOW" (blue) or "BOOKED" (red) or disabled (gray)
  - Cancel button is always visible
  - Calendar and clock display in full width

## Files Modified/Created

### Configuration
- **homeassistant/config/scripts.yaml** - Enhanced with 3 booking durations, cancellation, notifications
- **homeassistant/config/configuration.yaml** - Added `room_available_at` countdown sensor

### System/Services
- **refresh-loop-supervisor.sh** - New wrapper with auto-restart capability
- **kiosk.service** - Systemd unit for browser auto-start
- **kiosk-refresh.service** - Systemd unit for refresh loop management
- **.github/copilot-instructions.md** - Updated documentation

### UI/Dashboard
- **homeassistant/config/.storage/lovelace.conference_room.new** - New improved dashboard design
  - *(Note: This needs to be manually applied or via Home Assistant UI editor)*

## Installation Instructions

### 1. Apply Updated Configuration
```bash
# Pull latest changes from GitHub
cd /home/admin
git pull origin main

# Restart Home Assistant to apply new sensors and scripts
cd homeassistant
docker-compose restart
```

### 2. Install Systemd Services
```bash
# Copy service files to systemd directory
sudo cp /home/admin/kiosk.service /etc/systemd/system/
sudo cp /home/admin/kiosk-refresh.service /etc/systemd/system/

# Reload systemd daemon
sudo systemctl daemon-reload

# Enable services to auto-start on boot
sudo systemctl enable kiosk
sudo systemctl enable kiosk-refresh

# Start the services
sudo systemctl start kiosk
sudo systemctl start kiosk-refresh
```

### 3. Apply New Dashboard Design
**Option A: Manual via Home Assistant UI**
1. Go to Home Assistant → Settings → Dashboards
2. Edit "Conference Room" dashboard
3. Replace cards with improved layout from `.storage/lovelace.conference_room.new`

**Option B: Replace storage file** (requires HA restart)
```bash
# Backup current dashboard
cp /home/admin/homeassistant/config/.storage/lovelace.conference_room \
   /home/admin/homeassistant/config/.storage/lovelace.conference_room.backup

# Apply new dashboard
cp /home/admin/homeassistant/config/.storage/lovelace.conference_room.new \
   /home/admin/homeassistant/config/.storage/lovelace.conference_room

# Restart Home Assistant
cd /home/admin/homeassistant
docker-compose restart
```

### 4. Make Scripts Executable
```bash
chmod +x /home/admin/start-kiosk.sh
chmod +x /home/admin/refresh-loop.sh
chmod +x /home/admin/refresh-loop-supervisor.sh
```

## Testing Checklist

- [ ] Booking works with 15, 30, and 60-minute options
- [ ] Toast notifications appear after successful booking
- [ ] Cancel button removes last booking
- [ ] Countdown timer shows correct time until availability
- [ ] If room is occupied, "BOOK NOW" button is disabled (gray)
- [ ] Refresh loop auto-restarts if it crashes
- [ ] Systemd services start on boot
- [ ] Dashboard displays correctly on 9" screen

## Feature Validation

### Booking Duration Selector
When user taps "BOOK NOW", a popup appears with three options:
- 15 Minutes
- 30 Minutes
- 60 Minutes

Tapping any creates a calendar event and shows confirmation.

### Countdown Timer
The `room_available_at` sensor provides text like:
- "In 12m" - Room available in 12 minutes
- "In 1h 45m" - Room available in 1 hour 45 minutes
- "Now" or "Available" - Room is available

### Booking Cancellation
"Cancel Last Booking" button always visible at bottom of status section. Taps the most recent "Booked from touch panel" event and deletes it with confirmation message.

### Auto-Restart
If `refresh-loop.sh` crashes:
1. Supervisor detects it
2. Waits 5 seconds
3. Restarts the loop
4. If it crashes again within a few minutes, waits 10 seconds before next retry
5. Logs all attempts to `/var/log/kiosk-refresh.log`

## Known Limitations

1. **Dashboard popup** - The popup for booking durations requires `browser_mod` custom component. Verify it's installed.
2. **Notification service** - Booking confirmations use `notify.notify` service. Ensure you have a notification service configured (mobile app, browser_mod toast, etc.)
3. **Calendar permissions** - Booking/cancellation requires the calendar to have write permissions
4. **Countdown timer** - Updates every 60 seconds with the refresh loop (not real-time)

## Next Steps (Optional Enhancements)

1. Add username tracking to bookings (currently anonymous "Booked from touch panel")
2. Show countdown timer prominently on the booking button
3. Add booking history/log view
4. Integrate with room lights/display controls
5. Add occupancy-based room climate control
6. Mobile app for remote booking/cancellation

## Support

For issues:
```bash
# View Home Assistant logs
cd /home/admin/homeassistant
docker-compose logs -f

# View refresh loop supervisor logs
tail -f /var/log/kiosk-refresh.log

# View systemd service logs
journalctl -u kiosk -f
journalctl -u kiosk-refresh -f
```

---

**Repository**: https://github.com/Autonom664/conference-room-kiosk
**Last Updated**: January 2026
