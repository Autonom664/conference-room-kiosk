# Conference Room Kiosk System

A **Linux-based smart kiosk** for conference room booking using Home Assistant, running on Raspberry Pi with a 9" touchscreen. The system integrates Microsoft 365 calendar, Aqara presence detection, and a fullscreen Chromium browser interface.

## System Architecture

```
┌─────────────────────────────────────────┐
│   RPi 4/5 (Linux)                       │
│                                         │
│  ┌──────────────────────────────────┐   │
│  │ Home Assistant (Docker)          │   │
│  │ - Calendar (MS365 integration)   │   │
│  │ - Presence sensing (FP2)         │   │
│  │ - Automation & Scripts           │   │
│  └──────────────────────────────────┘   │
│           ↑                  ↓           │
│  ┌──────────────────────────────────┐   │
│  │ Chromium Browser (Kiosk Mode)    │   │
│  │ - Fullscreen dashboard           │   │
│  │ - Booking UI                     │   │
│  │ - Auto-refresh every 60s         │   │
│  └──────────────────────────────────┘   │
│           ↓                              │
│     9" Touchscreen (HDMI)               │
└─────────────────────────────────────────┘
```

## Key Features

- **Real-time Calendar Display**: Shows today's meetings from MS365
- **Occupancy Detection**: FP2 sensor indicates if room is currently in use
- **Quick Booking**: 1-tap booking for 15/30/60 minute slots
- **Availability Check**: Prevents booking if conflicts exist in next 30 minutes
- **Booking Cancellation**: Undo recent bookings easily
- **Countdown Timer**: Shows when room becomes available
- **Error Notifications**: Alerts if booking fails
- **Auto-Refresh**: Updates dashboard every 60 seconds

## Quick Start

### Starting the Kiosk
```bash
./start-kiosk.sh
```
This launches Chromium in fullscreen kiosk mode and starts a local HTTP server (localhost:8000) with a 30-second splash screen before redirecting to the Home Assistant dashboard.

### Starting Home Assistant
```bash
cd homeassistant
docker-compose up -d
```

### Auto-Refresh Loop
```bash
./refresh-loop.sh &
```
Sends F5 key every 60 seconds to keep the dashboard current.

## File Structure

```
/home/admin/
├── start-kiosk.sh              # Launch script for Chromium kiosk
├── refresh-loop.sh             # Auto-refresh loop (F5 every 60s)
├── .github/
│   └── copilot-instructions.md # AI agent guidelines
├── homeassistant/
│   ├── docker-compose.yml      # Docker configuration
│   ├── install_hacs.sh         # HACS installation script
│   └── config/
│       ├── configuration.yaml  # Main HA config (sensors, automations)
│       ├── automations.yaml    # Automation rules
│       ├── scripts.yaml        # Booking & control scripts
│       ├── custom_components/  # Third-party integrations
│       └── .storage/           # Runtime data (gitignored)
├── kiosk-loader/
│   └── index.html              # Splash screen HTML
└── README.md                   # This file
```

## Configuration

### Key Home Assistant Entities

**Binary Sensors:**
- `binary_sensor.presence_sensor_fp2_54f1_presence_sensor_2` - Physical occupancy (FP2)
- `binary_sensor.conference_room_occupied` - Occupancy with 10s delay-off
- `binary_sensor.conference_room_booking_available` - Can book in next 30 min?

**Sensors:**
- `calendar.conferenceroom_calendar` - MS365 conference room calendar
- `sensor.todays_conference_events` - Formatted list of today's meetings

**Scripts:**
- `script.book_conference_room_30_min` - Create 30-min booking
- `script.book_conference_room_15_min` - Create 15-min booking
- `script.book_conference_room_60_min` - Create 60-min booking
- `script.cancel_last_booking` - Delete most recent "Booked from touch panel" event

## Hardware

- **Display**: ~9" touchscreen, 1280×720 resolution
- **Presence Sensor**: Aqara FP2 (via `/dev/ttyACM0` or `/dev/rfcomm0`)
- **Calendar**: Microsoft 365 (via `ms365_calendar` custom component)
- **System**: Raspberry Pi 4/5 (running Home Assistant in Docker)

## Customization

### Change Splash Screen Logo
1. Replace `/home/admin/kiosk-loader/company-logo.png` with your logo
2. Adjust sizing in [kiosk-loader/index.html](kiosk-loader/index.html)

### Change Dashboard Redirect URL
Edit [kiosk-loader/index.html](kiosk-loader/index.html#L5):
```html
<meta http-equiv="refresh" content="30; URL=http://YOUR_IP:8123/conference-room/kiosk?kiosk" />
```

### Adjust Refresh Interval
Edit [refresh-loop.sh](refresh-loop.sh#L4):
```bash
sleep 60  # Change 60 to desired seconds
```

### Modify Booking Duration
Edit [homeassistant/config/scripts.yaml](homeassistant/config/scripts.yaml) - change the `timedelta(minutes=30)` value.

## Troubleshooting

### Calendar not updating
- Check MS365 credentials in `homeassistant/config/secrets.yaml`
- Verify calendar entity in Home Assistant UI (Settings → Devices & Services → Calendar)
- Check Home Assistant logs: `docker-compose logs homeassistant`

### Presence sensor not detecting people
- Verify FP2 is powered and paired via Zigbee
- Check device availability in Home Assistant UI
- Look for connection issues: `docker-compose logs | grep "ttyACM0\|rfcomm"`

### Kiosk browser not refreshing
- Ensure `refresh-loop.sh` is running: `ps aux | grep refresh-loop`
- Check if `xdotool` is installed: `which xdotool`
- Manual refresh: Press F5 on the kiosk display

### Booking fails silently
- Check script errors in Home Assistant logs
- Verify calendar has write permissions for the account
- Test booking manually via Home Assistant UI

## Development

### Architecture Documentation
See [.github/copilot-instructions.md](.github/copilot-instructions.md) for AI agent guidance and detailed architecture notes.

### Key Technologies
- **Home Assistant**: Home automation platform
- **Docker**: Container runtime for HA
- **Chromium**: Fullscreen browser kiosk
- **Lovelace**: HA dashboard UI (YAML-based)
- **Kiosk Mode**: Custom component hiding browser chrome
- **Atomic Calendar Revive**: Event calendar display card
- **Button Card**: Custom interactive buttons

## License

Proprietary - Conference Room Booking System

## Support

For issues or improvements, check Home Assistant logs:
```bash
cd homeassistant
docker-compose logs -f
```

---

**Last Updated**: January 2026
