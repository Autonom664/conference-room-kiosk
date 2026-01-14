# New Dashboard Design Guide

## Visual Layout (9" Touchscreen - 1280×720)

```
┌────────────────────────────────────────────────────┐
│                                                    │
│  Conference Room                          (title)  │
│                                                    │
├────────────────────────────────────────────────────┤
│  ┌─────────────────────┬──────────────────────────┐│
│  │                     │                          ││
│  │  ✓ AVAILABLE        │  📅 BOOK NOW             ││
│  │  Room is empty      │  Select duration         ││
│  │                     │                          ││
│  │  (GREEN)            │  (BLUE)                  ││
│  └─────────────────────┴──────────────────────────┘│
│                                                    │
├────────────────────────────────────────────────────┤
│                                                    │
│  ↩️  Cancel Last Booking                           │
│  (Dark gray, low opacity)                        │
│                                                    │
├────────────────────────────────────────────────────┤
│                                                    │
│  Today's Meetings                                 │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  │
│  Team Standup: 10:00 - 10:30                     │
│  Design Review: 11:00 - 12:00                    │
│  Lunch with Client: 13:00 - 14:00                │
│                                                    │
├────────────────────────────────────────────────────┤
│                                                    │
│         🕐  [Analog Clock]                        │
│         Display current time                      │
│                                                    │
└────────────────────────────────────────────────────┘
```

## Card Specifications

### 1. Title Bar (Full Width)
```
Height: 50px
Font: 40px, bold, white
Background: Transparent (dark)
Content: "Conference Room"
```

### 2. Status Cards (2-Column Grid)

#### Left Card: Occupancy
```
Width: 50% - 6px gap
Height: 140px
Border Radius: 16px
Padding: 16px

States:
├─ Available (Green #388e3c)
│  ├─ Icon: check-circle (48px)
│  ├─ Name: "AVAILABLE" (24px, bold, white)
│  └─ Label: "Room is empty" (14px, 80% opacity)
│
└─ Occupied (Red #d32f2f)
   ├─ Icon: account-multiple (48px)
   ├─ Name: "OCCUPIED" (24px, bold, white)
   └─ Label: "People in the room" (14px, 80% opacity)
```

#### Right Card: Booking
```
Width: 50% - 6px gap
Height: 140px
Border Radius: 16px
Padding: 16px

States:
├─ Available (Blue #1976d2)
│  ├─ Icon: calendar-plus (48px)
│  ├─ Name: "BOOK NOW" (24px, bold, white)
│  ├─ Label: "Select duration" (14px, 80% opacity)
│  └─ Cursor: pointer
│
├─ Booked (Red #d32f2f)
│  ├─ Icon: calendar-plus (48px, grayed)
│  ├─ Name: "BOOKED" (24px, bold, white)
│  ├─ Label: "Next 30 min" (14px, 80% opacity)
│  └─ Cursor: not-allowed (disabled)
│
└─ Room Occupied (Gray #999)
   ├─ Icon: calendar-plus (48px, grayed)
   ├─ Name: "BOOKED" (24px, bold, white)
   ├─ Label: "Room in use" (14px, 80% opacity)
   └─ Cursor: not-allowed (disabled)
```

### 3. Cancel Button (Full Width)
```
Height: 60px
Border Radius: 12px
Background: #666 with 0.7 opacity
Padding: 16px

Icon: ↩️ undo (32px, white)
Text: "Cancel Last Booking" (16px, white, bold)
```

### 4. Calendar Card (Full Width)
```
Height: Auto (fits content)
Border Radius: 16px
Padding: 20px
Font: 24px
Line Height: 2.0

Title: "Today's Meetings"
Content: List of events with times
Fallback: "No meetings today"
```

### 5. Clock Card (Full Width)
```
Size: 200px diameter (centered)
Theme:
├─ Background: rgba(255,255,255,0.05)
├─ Hands: #1976d2 (blue)
├─ Numbers: white
└─ Border: #1976d2
```

## Color Scheme

```
Primary Colors:
├─ Available: #388e3c (Green)
├─ Booked: #d32f2f (Red)
├─ Bookable: #1976d2 (Blue)
├─ Disabled: #999 (Gray)
└─ Accent: #1976d2 (Blue clock)

Text Colors:
├─ Primary: white (100%)
├─ Secondary: white (80% opacity)
└─ Background: Dark (transparent or dark gray)
```

## Interaction Flow

### Booking Flow
```
1. User sees "BOOK NOW" (blue button) → Room available & empty
   │
   └─→ User taps "BOOK NOW"
       │
       └─→ Popup appears with options:
           ├─ 15 Minutes
           ├─ 30 Minutes  ← Most popular
           └─ 60 Minutes
       │
       └─→ User taps preferred duration
           │
           └─→ Calendar event created
               │
               └─→ Toast notification: "✓ Room Booked until 2:45 PM"
                   │
                   └─→ Button turns RED ("BOOKED")
                       Dashboard refreshes (60-second refresh loop)
```

### Cancellation Flow
```
1. User taps "Cancel Last Booking"
   │
   └─→ Script finds most recent "Booked from touch panel" event
       │
       └─→ Event deleted from calendar
           │
           └─→ Toast notification: "✓ Booking Cancelled"
               │
               └─→ Button turns BLUE ("BOOK NOW") if no other conflicts
```

### Occupancy Detection
```
Room Empty (Green AVAILABLE)
   ↓
  [User enters - FP2 detects presence]
   ↓
Room Occupied (Red OCCUPIED)
   ↓
  [User leaves - 10-second delay-off]
   ↓
Room Empty (Green AVAILABLE)
   
Note: Button is disabled (gray) while room is occupied
```

## Responsive Design Notes

- **9" display (1280×720)**: Perfect fit with current design
- **Larger displays**: Grid will expand proportionally
- **Smaller displays**: May require hamburger menu for extra options
- **Touch targets**: All interactive elements are minimum 60px height for finger-friendly interaction
- **Font sizes**: Optimized for 6+ feet viewing distance

## Accessibility Considerations

✅ **Color + Text**: Cards show both color AND text ("AVAILABLE"/"OCCUPIED")
✅ **High Contrast**: White text on saturated colors (meets WCAG AA)
✅ **Large Fonts**: 24px+ for primary content
✅ **Clear Icons**: Using Material Design Icons for universality
✅ **Touch Friendly**: All buttons are 60px+ height
⚠️ **Color Blind**: Relies on color + shape/text (not just color)

## Browser Compatibility

- **Chromium**: ✅ Full support
- **Firefox**: ✅ Full support
- **Safari**: ✅ Full support
- **Mobile browsers**: ✅ Responsive design works

## Performance Notes

- **Load time**: ~2-3 seconds (cached)
- **Refresh rate**: 60 seconds via F5 key
- **Memory**: ~150MB (Chromium + HA connection)
- **CPU**: Minimal when idle (~5-10% during refresh)

---

**Design Version**: 2.0 (January 2026)
**Optimized For**: 9" touchscreen, Raspberry Pi + Home Assistant
**Last Updated**: January 2026
