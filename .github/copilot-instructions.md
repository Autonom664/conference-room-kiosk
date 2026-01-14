# Conference Room Kiosk System

## Architecture Overview

This is a **Linux-based kiosk system** that runs a Home Assistant dashboard in fullscreen Chromium browser. Three main components:

1. **Home Assistant** (containerized): Manages conference room calendar, presence detection, and meeting display
2. **Kiosk Loader** (web page): Splash screen that auto-redirects to Home Assistant dashboard
3. **Kiosk Scripts** (bash): Launch and maintain the browser kiosk mode

## Key Workflows

### Starting the Kiosk
- Run `start-kiosk.sh` to launch Chromium in kiosk mode
- This script starts a local web server at `localhost:8000` serving [kiosk-loader/index.html](kiosk-loader/index.html)
- The loader displays a 30-second countdown, then redirects to Home Assistant at `http://172.17.60.100:8123/conference-room/kiosk?kiosk`

### Auto-Refresh Mechanism
- `refresh-loop.sh` uses `xdotool` to send F5 key every 60 seconds to keep the display fresh
- `refresh-loop-supervisor.sh` wraps the refresh loop with auto-restart on crash (exponential backoff, max 10 retries)
- Run supervisor in the background or use systemd service: `systemctl start kiosk-refresh`

### Home Assistant Management
```bash
cd homeassistant
docker-compose up -d    # Start Home Assistant
docker-compose logs -f  # View logs
docker-compose down     # Stop
```

## Home Assistant Configuration

### Calendar Integration
- **Conference Room calendar** is accessed via MS365 integration (`ms365_calendar` custom component)
- Calendar entity: `calendar.conferenceroom_calendar`
- Calendar config stored in [homeassistant/config/ms365_storage/ms365_calendars_ConferenceRoom.yaml](homeassistant/config/ms365_storage/ms365_calendars_ConferenceRoom.yaml)

### Key Sensors & Logic

**Binary Sensor: `conference_room_occupied`** ([configuration.yaml](homeassistant/config/configuration.yaml#L19-L25))
- Detects physical presence using FP2 sensor
- Has 10-second delay-off to prevent flickering
- Template references: `binary_sensor.presence_sensor_fp2_54f1_presence_sensor_2`

**Binary Sensor: `conference_room_booking_available`** ([configuration.yaml](homeassistant/config/configuration.yaml#L28-L43))
- Checks if room can be booked in next 30 minutes (1800 seconds)
- Parses `calendar.conferenceroom_calendar` data attribute for upcoming events
- Returns `true` if no overlapping events exist

**Sensor: `todays_conference_events`** ([configuration.yaml](homeassistant/config/configuration.yaml#L47-L73))
- Lists all meetings for current day in format: `"Title: HH:MM - HH:MM"`
- Uses Jinja2 templates to filter and format calendar events
- Output stored in `list` attribute, newline-separated

**Sensor: `room_available_at`** (new - [configuration.yaml](homeassistant/config/configuration.yaml#L75+))
- Shows countdown until room becomes available
- Formats output: "In Xm", "In Xh Ym", or "Available"
- Updates automatically and used by kiosk UI for booking countdown

### Booking Scripts
Three duration options for conference room booking ([scripts.yaml](homeassistant/config/scripts.yaml)):

1. `script.book_conference_room_15_min` - Books room for 15 minutes
2. `script.book_conference_room_30_min` - Books room for 30 minutes
3. `script.book_conference_room_60_min` - Books room for 60 minutes

All scripts include:
- Error handling: Calendar event creation with automatic error notification
- Confirmation: Sends `notify.notify` service with "✓ Room Booked" message and availability time
- Idempotent: Multiple taps don't double-book (10-second booking availability delay)

**Booking Cancellation Script: `script.cancel_last_booking`**
- Finds most recent "Booked from touch panel" event in calendar
- Deletes the event if found
- Sends confirmation notification "✓ Booking Cancelled"
- Useful for accidental bookings or changed plans

### Booking Scripts
Three duration options for conference room booking ([scripts.yaml](homeassistant/config/scripts.yaml)):

1. `script.book_conference_room_15_min` - Books room for 15 minutes
2. `script.book_conference_room_30_min` - Books room for 30 minutes
3. `script.book_conference_room_60_min` - Books room for 60 minutes

All scripts include:
- Error handling: Calendar event creation with automatic error notification
- Confirmation: Sends `notify.notify` service with "✓ Room Booked" message and availability time
- Idempotent: Multiple taps don't double-book (10-second booking availability delay)

**Booking Cancellation Script: `script.cancel_last_booking`**
- Finds most recent "Booked from touch panel" event in calendar
- Deletes the event if found
- Sends confirmation notification "✓ Booking Cancelled"
- Useful for accidental bookings or changed plans

## Hardware & Devices

- Presence sensor: Aqara FP2 (connects via `/dev/ttyACM0` or `/dev/rfcomm0`)
- Docker container runs in `network_mode: host` with privileged access for device communication
- D-Bus socket mounted for system integration

## File Organization Patterns

- Configuration uses Home Assistant's `!include` directives to split files:
  - [automations.yaml](homeassistant/config/automations.yaml): Automation rules
  - [scripts.yaml](homeassistant/config/scripts.yaml): Script definitions (booking, cancellation)
  - [scenes.yaml](homeassistant/config/scenes.yaml): Scene configurations
  - [secrets.yaml](homeassistant/config/secrets.yaml): Sensitive credentials (gitignored)

## Network & Access

- Home Assistant runs on host network at `172.17.60.100:8123`
- Kiosk dashboard path: `/conference-room/kiosk?kiosk`
- Local development server: `localhost:8000` (kiosk-loader)

## System Services (Systemd)

Two systemd services for production auto-start & auto-restart:

**kiosk.service** - Manages Chromium kiosk browser
```bash
systemctl start kiosk
systemctl status kiosk
journalctl -u kiosk -f  # View logs
```

**kiosk-refresh.service** - Manages refresh-loop with supervisor
```bash
systemctl start kiosk-refresh
systemctl status kiosk-refresh
journalctl -u kiosk-refresh -f
```

Both services have `Restart=always` and are ordered to start automatically on system boot.

## Dashboard UI

The kiosk displays a **single-column fullscreen dashboard** optimized for 9" touchscreen (1280×720):

**Top Section:**
- "Conference Room" title (40px bold white text)

**Status Row (2-column grid):**
1. **Occupancy Card** (green=available/red=occupied)
   - Shows "AVAILABLE" or "OCCUPIED" in large text
   - Icon: check-circle (available) or account-multiple (occupied)
   - FP2 sensor data with real-time updates
   
2. **Booking Card** (blue=available/red=booked/gray=room occupied)
   - Shows "BOOK NOW" or "BOOKED" in large text
   - Tap opens popup with duration selector: 15min, 30min, 60min
   - Disabled if room currently occupied (gray, not-allowed cursor)
   - Changes color based on availability

**Action Row:**
- "Cancel Last Booking" button (dark gray, 60px height)
- Calls `script.cancel_last_booking` on tap
- Allows undoing accidental bookings

**Calendar Section:**
- `atomic-calendar-revive` card showing today's meetings
- Large 24px font, line-height 2 for readability
- Shows event titles and times only
- "No events for today" message when empty

**Clock Section:**
- Analog clock display (200px diameter)
- Blue hands and border, white numbers
- Subtle transparent background

## Common Tasks

- **Modify splash screen**: Edit [kiosk-loader/index.html](kiosk-loader/index.html) and update `company-logo.png`
- **Change redirect URL**: Update the `http-equiv="refresh"` meta tag in [index.html](kiosk-loader/index.html#L5)
- **Adjust refresh interval**: Modify sleep duration in [refresh-loop.sh](refresh-loop.sh#L4)
- **Update calendar logic**: Edit template sensors in [configuration.yaml](homeassistant/config/configuration.yaml)
- **Change booking window**: Modify the `1800` (30 min) value in `conference_room_booking_available` template
- **Customize booking durations**: Edit duration values (15/30/60) in [scripts.yaml](homeassistant/config/scripts.yaml)
- **Install systemd services**: Copy `.service` files to `/etc/systemd/system/` and run `systemctl daemon-reload`

## Troubleshooting

**Dashboard not refreshing**
- Check `refresh-loop-supervisor.sh` is running: `ps aux | grep refresh-loop`
- Check systemd service: `systemctl status kiosk-refresh`
- View supervisor logs: `tail -f /var/log/kiosk-refresh.log`

**Booking fails**
- Check Home Assistant logs: `cd homeassistant && docker-compose logs homeassistant`
- Verify calendar permissions in MS365
- Check notification service is enabled in HA

**Presence sensor not detecting**
- Verify FP2 is powered and connected
- Check Zigbee integration status in Home Assistant UI
- Test binary_sensor state manually in Home Assistant

**Kiosk won't start**
- Verify `start-kiosk.sh` is executable: `chmod +x start-kiosk.sh`
- Check Chromium is installed: `which chromium-browser`
- Verify DISPLAY variable: `echo $DISPLAY` (should be `:0` for X11)

