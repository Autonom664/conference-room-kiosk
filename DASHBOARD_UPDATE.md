# Dashboard Update - January 14, 2026

## New Kiosk Dashboard Design

The kiosk dashboard has been redesigned with improved functionality and user experience.

### Layout Changes

**Single-column, fullscreen optimized for 9" touchscreen**

```
┌─────────────────────────────────────┐
│    CONFERENCE ROOM (40px bold)      │
├─────────────────────────────────────┤
│  [AVAILABLE/OCCUPIED]  [Available In │
│   (Green/Red Card)      X Hours]     │
│    with icons           (Blue Card)  │
├─────────────────────────────────────┤
│  Select Booking Duration            │
├─────────────────────────────────────┤
│  [15 MIN]  [30 MIN]  [60 MIN]       │
│   Blue btn Blue btn  Blue btn        │
│  (unless room occupied = gray)       │
├─────────────────────────────────────┤
│  [Cancel Last Booking]              │
│     Dark gray button                │
├─────────────────────────────────────┤
│     Today's Meetings Calendar       │
│    - Meeting 1: 09:00 - 10:00       │
│    - Meeting 2: 14:00 - 15:00       │
│      (Large 22px font, easy to read)│
└─────────────────────────────────────┘
```

### Key Features

#### 1. **Occupancy Status Card** (Top Left)
- **Green + Check Circle**: Room Available
- **Red + Account Icon**: Room Occupied
- Large, clear text: "AVAILABLE" or "OCCUPIED"
- Updates in real-time from FP2 sensor

#### 2. **Countdown Timer Card** (Top Right)
- Blue background
- Shows: "Room Available In: [time]"
- Displays sensor: `sensor.room_available_at`
- Examples: "Available", "In 15m", "In 1h 23m"
- Updates every minute

#### 3. **Booking Duration Selector** (3 Buttons)
- **15 MIN** button
- **30 MIN** button  
- **60 MIN** button
- Color-coded:
  - **Blue**: Room available, can book
  - **Red**: Room already booked in next 30 min
  - **Gray**: Room currently occupied (disabled)

#### 4. **Cancel Last Booking Button**
- Dark gray button (always visible)
- Calls `script.cancel_last_booking`
- Allows users to undo accidental bookings
- Shows confirmation notification

#### 5. **Today's Meetings Calendar**
- Shows all events for today
- Large 22px font for readability
- Line-height 2 for good spacing
- Message: "No events for today" when empty
- Source: `calendar.conferenceroom_calendar`

### Technical Details

**Configuration File:**
- Location: `/home/admin/homeassistant/config/.storage/lovelace.conference_room`
- Type: JSON dashboard configuration
- Card types used:
  - `custom:button-card` - Interactive buttons and status displays
  - `custom:atomic-calendar-revive` - Calendar view
  - `custom:layout-card` - Grid layout system

**Responsive Design:**
- Single-column layout for 9" screens
- 12px gap between elements
- 16px padding around edges
- All buttons have rounded corners (12px border-radius)
- Touch-friendly minimum height of 60px for buttons

**Button Templates:**
- Buttons disable when: `conference_room_booking_available` = off OR `presence_sensor` = on
- Dynamic color changes based on state
- JavaScript templates in button-card for real-time updates

### Notification Integration

When a booking is made:
1. User taps a duration button (15/30/60 min)
2. Script creates calendar event: "Booked from touch panel"
3. Toast notification appears: "✓ Room Booked until HH:MM"
4. Buttons immediately update color to red
5. Countdown timer updates

If booking fails:
- Error notification: "✗ Booking Failed"
- User can retry

### Customization

To modify:
- **Edit the JSON file** directly in Home Assistant's `.storage/` folder
- **OR use Home Assistant UI**: Edit dashboard > Edit layout
- Changes persist in `.storage/lovelace.conference_room`

**Backup location:** `.storage/lovelace.conference_room.backup`

### Migration Notes

- Old single-button layout replaced with 3-button duration selector
- Countdown timer now prominently displayed
- Cancel button added for user convenience
- All functionality from old dashboard preserved
