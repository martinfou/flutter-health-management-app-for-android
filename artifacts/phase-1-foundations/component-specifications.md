# Component Specifications

## Overview

This document defines reusable UI components for the Flutter Health Management App for Android. Each component includes specifications, states, accessibility requirements, and ASCII art representations.

**Reference**: Based on design system options in `artifacts/phase-1-foundations/design-system-options.md` and wireframes in `artifacts/phase-1-foundations/wireframes.md`.

## Button Components

### Primary Button

**Purpose**: Main action button for primary user actions (Save, Submit, Continue)

**Specifications**:
- Height: 48dp minimum (56dp for emphasis)
- Padding: 12dp vertical, 24dp horizontal
- Border Radius: 8dp (Option 1), 12dp (Option 2), 4dp (Option 3), 16dp (Option 4)
- Background: Primary color
- Text Color: White
- Font: Medium, 16sp
- Elevation: 2dp (pressed: 4dp)

**ASCII Representation**:
```
┌─────────────────────────────┐
│                             │
│    [Save Weight]            │
│                             │
└─────────────────────────────┘
```

**States**:
- **Default**: Primary color background, white text
- **Pressed**: Darker shade, elevated shadow
- **Disabled**: Grey background, grey text, no elevation
- **Loading**: Spinner icon, disabled interaction

**Accessibility**:
- Screen reader label: "Save Weight button"
- Minimum touch target: 48x48dp
- Focus indicator: 2dp outline
- Keyboard: Enter/Space to activate

### Secondary Button

**Purpose**: Secondary actions (Cancel, Back, Alternative options)

**Specifications**:
- Height: 48dp minimum
- Padding: 12dp vertical, 24dp horizontal
- Border: 1dp, primary color
- Background: Transparent
- Text Color: Primary color
- Font: Medium, 16sp
- Elevation: 0dp

**ASCII Representation**:
```
┌─────────────────────────────┐
│ ┌─────────────────────────┐ │
│ │   Cancel                 │ │
│ └─────────────────────────┘ │
└─────────────────────────────┘
```

**States**:
- **Default**: Outlined, transparent background
- **Pressed**: Light primary color background
- **Disabled**: Grey border, grey text
- **Loading**: Spinner icon

**Accessibility**: Same as Primary Button

### Text Button

**Purpose**: Tertiary actions (Learn More, View Details)

**Specifications**:
- Height: 48dp minimum
- Padding: 8dp vertical, 16dp horizontal
- Background: Transparent
- Text Color: Primary color
- Font: Medium, 14sp
- No border, no elevation

**ASCII Representation**:
```
[View Details →]
```

**States**:
- **Default**: Primary color text
- **Pressed**: Darker shade
- **Disabled**: Grey text
- **Hover**: Underline (web)

**Accessibility**: Same as Primary Button

### Icon Button

**Purpose**: Icon-only actions (Settings, Close, Back)

**Specifications**:
- Size: 48x48dp (minimum touch target)
- Border Radius: 24dp (circular) or 8dp (rounded square)
- Background: Transparent or light grey
- Icon Size: 24dp
- Icon Color: Primary or grey

**ASCII Representation**:
```
┌────┐
│ ⚙️ │
└────┘
```

**States**:
- **Default**: Transparent or light background
- **Pressed**: Darker background
- **Disabled**: Grey icon, no interaction

**Accessibility**:
- Screen reader label required (e.g., "Settings button")
- Minimum 48x48dp touch target
- Focus indicator: 2dp outline

---

## Input Components

### Text Input Field

**Purpose**: Text entry (Name, Notes, Search)

**Specifications**:
- Height: 56dp
- Padding: 16dp
- Border: 1dp, grey (default), primary (focused), red (error)
- Border Radius: 8dp
- Background: White
- Text: 16sp, regular
- Label: 12sp, above input (floating label)

**ASCII Representation**:
```
┌─────────────────────────────┐
│ Name                        │
│ ┌─────────────────────────┐ │
│ │                         │ │
│ │                         │ │
│ └─────────────────────────┘ │
└─────────────────────────────┘
```

**States**:
- **Default**: Grey border, white background
- **Focused**: Primary color border (2dp), label moves up
- **Error**: Red border (2dp), error message below
- **Disabled**: Grey background, grey text, no interaction
- **Filled**: Text entered, label remains at top

**Accessibility**:
- Screen reader label: "Name input field"
- Keyboard: Standard text input
- Error announcement: "Name is required"
- Minimum touch target: 56dp height

### Number Input Field

**Purpose**: Numeric entry (Weight, Measurements, Macros)

**Specifications**:
- Height: 56dp
- Padding: 16dp
- Border: Same as Text Input
- Border Radius: 8dp
- Background: White
- Text: 24sp (large numbers), 16sp (regular)
- Keyboard: Numeric keypad
- Unit Label: Right-aligned, 14sp

**ASCII Representation**:
```
┌─────────────────────────────┐
│ Weight                      │
│ ┌─────────────────────────┐ │
│ │                         │ │
│ │        75.5             │ │
│ │        kg               │ │
│ └─────────────────────────┘ │
└─────────────────────────────┘
```

**States**: Same as Text Input

**Accessibility**: Same as Text Input, plus numeric keyboard

### Date Picker Button

**Purpose**: Date selection

**Specifications**:
- Height: 56dp
- Padding: 16dp
- Border: 1dp, grey
- Border Radius: 8dp
- Background: White
- Text: 16sp
- Icon: Calendar icon, 24dp, right-aligned

**ASCII Representation**:
```
┌─────────────────────────────┐
│ ┌─────────────────────────┐ │
│ │ Today            📅      │ │
│ └─────────────────────────┘ │
└─────────────────────────────┘
```

**States**:
- **Default**: Grey border, white background
- **Pressed**: Opens date picker dialog
- **Selected**: Primary color border, selected date displayed

**Accessibility**:
- Screen reader: "Date picker, Today, tap to select date"
- Opens date picker dialog on tap
- Keyboard navigation in picker

### Dropdown/Select Field

**Purpose**: Selection from options (Meal Type, Units)

**Specifications**:
- Height: 56dp
- Padding: 16dp
- Border: 1dp, grey
- Border Radius: 8dp
- Background: White
- Text: 16sp
- Icon: Dropdown arrow, 24dp, right-aligned

**ASCII Representation**:
```
┌─────────────────────────────┐
│ Meal Type                    │
│ ┌─────────────────────────┐ │
│ │ Breakfast          ▼    │ │
│ └─────────────────────────┘ │
└─────────────────────────────┘
```

**States**:
- **Default**: Grey border, white background
- **Pressed**: Opens dropdown menu
- **Selected**: Primary color border, selected option displayed

**Accessibility**:
- Screen reader: "Meal Type dropdown, Breakfast selected"
- Opens dropdown on tap
- Keyboard navigation in dropdown

### Slider/Rating Component

**Purpose**: 1-10 scale rating (Sleep Quality, Energy Level)

**Specifications**:
- Height: 48dp (touch target)
- Track: Full width, 4dp height, grey background
- Active Track: Primary color
- Thumb: 24dp circle, primary color
- Labels: 1-10 below track, 12sp
- Value Display: Above thumb, 16sp, bold

**ASCII Representation**:
```
┌─────────────────────────────┐
│ Sleep Quality                │
│        5                     │
│ ───●─────────────────────────│
│ 1  2  3  4  5  6  7  8  9 10 │
└─────────────────────────────┘
```

**States**:
- **Default**: Grey track, primary thumb
- **Dragging**: Thumb follows finger, value updates
- **Selected**: Value displayed, primary color

**Accessibility**:
- Screen reader: "Sleep Quality slider, 5 out of 10"
- Keyboard: Arrow keys to adjust value
- Announce value changes

---

## Card Components

### Information Card

**Purpose**: Display information (Summary, Stats, Details)

**Specifications**:
- Padding: 16dp
- Border Radius: 12dp (Option 1), 16dp (Option 2), 8dp (Option 3), 20dp (Option 4)
- Background: White
- Elevation: 2dp (subtle shadow)
- Margin: 16dp (between cards)

**ASCII Representation**:
```
┌─────────────────────────────┐
│                             │
│  Today's Summary            │
│  ─────────────────────────  │
│  Weight: 75.5 kg            │
│  7-Day Avg: 75.2 kg         │
│  Trend: ↓ 0.3 kg            │
│                             │
└─────────────────────────────┘
```

**States**:
- **Default**: White background, subtle shadow
- **Pressed**: Slightly elevated (4dp)
- **Selected**: Primary color border (2dp)

**Accessibility**:
- Screen reader: Reads card title and content
- Semantic structure: Heading, content

### Metric Card

**Purpose**: Display single metric (Weight, Sleep, Energy)

**Specifications**:
- Size: Flexible width, 120dp height
- Padding: 16dp
- Border Radius: 12dp
- Background: White or light primary color
- Value: Large, 32sp, bold
- Label: 14sp, secondary color
- Icon: 32dp, optional

**ASCII Representation**:
```
┌──────────────┐
│              │
│   📊         │
│              │
│   75.5       │
│   kg         │
│              │
│   ↓ 0.3kg    │
│              │
└──────────────┘
```

**States**: Same as Information Card

**Accessibility**: Screen reader announces metric name and value

### Meal Card

**Purpose**: Display meal information

**Specifications**:
- Padding: 16dp
- Border Radius: 12dp
- Background: White
- Elevation: 2dp
- Layout: Title, macro breakdown, action button

**ASCII Representation**:
```
┌─────────────────────────────┐
│ Breakfast                   │
│ ──────────────────────────  │
│ 450 cal | 35g P | 25g F     │
│ 15g C                       │
│ ──────────────────────────  │
│ [View Details →]           │
└─────────────────────────────┘
```

**States**:
- **Default**: White background
- **Pressed**: Navigate to meal detail
- **Empty**: "Not logged yet" message, "Log Meal" button

**Accessibility**: Screen reader: "Breakfast, 450 calories, 35 grams protein..."

---

## Navigation Components

### Bottom Navigation Bar

**Purpose**: Primary app navigation

**Specifications**:
- Height: 56dp (mobile), 64dp (tablet)
- Background: White
- Icon Size: 24dp
- Label: 12sp, below icon
- Active Color: Primary
- Inactive Color: Grey
- Elevation: 8dp (shadow above)

**ASCII Representation**:
```
┌─────────────────────────────────────────┐
│  🏠        📊        🍎        💪       │
│  Home    Health   Nutrition  Exercise  │
└─────────────────────────────────────────┘
```

**States**:
- **Default**: Grey icons, grey labels
- **Active**: Primary color icon, primary color label
- **Pressed**: Slightly darker shade

**Accessibility**:
- Screen reader: "Home, selected" or "Health, not selected"
- Minimum 48x48dp touch target per item
- Keyboard: Tab navigation

### App Bar

**Purpose**: Screen title and actions

**Specifications**:
- Height: 56dp
- Background: White or primary color
- Title: 20sp, medium, left-aligned
- Actions: Icon buttons, right-aligned
- Back Button: 24dp icon, left-aligned

**ASCII Representation**:
```
┌─────────────────────────────────────────┐
│  ← Back        Health Tracking      [⚙️] │
└─────────────────────────────────────────┘
```

**States**:
- **Default**: White background, dark text
- **Scrolled**: Elevated shadow (4dp)
- **Action Pressed**: Icon changes color

**Accessibility**:
- Screen reader: "Back button" or "Settings button"
- Title announced as page heading
- Keyboard: Back button, action buttons

### Tab Bar

**Purpose**: Secondary navigation within screen

**Specifications**:
- Height: 48dp
- Background: White
- Tab Width: Flexible, equal distribution
- Active Indicator: 2dp underline, primary color
- Text: 14sp, medium
- Active Text: Primary color, bold
- Inactive Text: Grey

**ASCII Representation**:
```
┌─────────────────────────────────────────┐
│  Today    Week    Month    Year         │
│  ──────                                │
└─────────────────────────────────────────┘
```

**States**:
- **Default**: Grey text, no underline
- **Active**: Primary color text, underline indicator
- **Pressed**: Slightly darker shade

**Accessibility**:
- Screen reader: "Today tab, selected" or "Week tab"
- Keyboard: Arrow keys to navigate tabs

---

## Data Visualization Components

### Line Chart

**Purpose**: Display trends over time (Weight, Macros)

**Specifications**:
- Height: 200dp (flexible)
- Padding: 16dp
- Background: White or transparent
- Line: 2dp, primary color
- Points: 8dp circle, primary color
- Grid: 1dp, light grey
- Labels: 12sp, grey
- Y-Axis: Left, numeric labels
- X-Axis: Bottom, date labels

**ASCII Representation**:
```
┌─────────────────────────────┐
│      │                      │
│  78  │  ●                   │
│      │    ●                 │
│  77  │      ●               │
│      │        ●             │
│  76  │          ●           │
│      │            ●         │
│  75  │              ●       │
│      └──────────────────────│
│      Mon  Wed  Fri  Sun     │
└─────────────────────────────┘
```

**States**:
- **Default**: Static chart
- **Interactive**: Tap point shows value tooltip
- **Loading**: Skeleton loader

**Accessibility**:
- Screen reader: "Weight trend chart, 7 days, starting at 76 kg, ending at 75 kg"
- Alternative: Data table format
- High contrast mode support

### Progress Bar

**Purpose**: Show progress toward goal (Macros, Steps)

**Specifications**:
- Height: 8dp (track), 8dp (fill)
- Width: Full width, flexible
- Track: Light grey background
- Fill: Primary color, animated
- Label: Left-aligned, 14sp
- Value: Right-aligned, 14sp, bold
- Percentage: Optional, 12sp

**ASCII Representation**:
```
┌─────────────────────────────┐
│ Protein: 120g / 140g        │
│ ████████████░░░░ 86%         │
└─────────────────────────────┘
```

**States**:
- **Default**: Grey track, primary fill
- **Complete**: Success color (green)
- **Over**: Warning color (orange)
- **Animated**: Smooth fill animation

**Accessibility**:
- Screen reader: "Protein, 120 grams out of 140 grams, 86 percent"
- High contrast mode support

### Circular Progress Indicator

**Purpose**: Show percentage or completion (Daily Goals)

**Specifications**:
- Size: 120dp diameter
- Stroke Width: 8dp
- Track: Light grey
- Fill: Primary color
- Center Text: Large, 32sp, bold
- Label: Below, 14sp

**ASCII Representation**:
```
┌─────────────────────────────┐
│        ┌─────┐              │
│        │ 86% │              │
│        └─────┘              │
│      Daily Goal             │
└─────────────────────────────┘
```

**States**: Same as Progress Bar

**Accessibility**: Screen reader: "Daily goal, 86 percent complete"

### Bar Chart

**Purpose**: Compare values (Weekly Macros, Exercise Frequency)

**Specifications**:
- Height: 200dp (flexible)
- Padding: 16dp
- Bar Width: Flexible, equal spacing
- Bar Color: Primary color
- Grid: 1dp, light grey
- Labels: 12sp, below bars
- Values: Above bars, 12sp, optional

**ASCII Representation**:
```
┌─────────────────────────────┐
│      │                      │
│  100 │     ████            │
│      │     ████            │
│   50 │     ████    ██      │
│      │     ████    ██      │
│    0 └─────────────────────│
│      Mon  Tue  Wed  Thu    │
└─────────────────────────────┘
```

**States**: Same as Line Chart

**Accessibility**: Screen reader: "Bar chart, Monday 80, Tuesday 60, Wednesday 90..."

---

## Form Components

### Checkbox

**Purpose**: Multiple selection (Notifications, Preferences)

**Specifications**:
- Size: 24x24dp (checkbox), 48x48dp (touch target)
- Border: 2dp, grey (unchecked), primary (checked)
- Background: White (unchecked), primary (checked)
- Checkmark: White, 16dp
- Label: 16sp, right of checkbox

**ASCII Representation**:
```
┌─────────────────────────────┐
│ ☑ Medication Reminders      │
│ ☐ Workout Reminders         │
│ ☐ Meal Reminders            │
└─────────────────────────────┘
```

**States**:
- **Unchecked**: Grey border, white background
- **Checked**: Primary background, white checkmark
- **Disabled**: Grey, no interaction

**Accessibility**:
- Screen reader: "Medication Reminders checkbox, checked"
- Keyboard: Space to toggle

### Radio Button

**Purpose**: Single selection (Units, Meal Type)

**Specifications**:
- Size: 24x24dp (radio), 48x48dp (touch target)
- Border: 2dp, grey (unselected), primary (selected)
- Background: White
- Dot: 12dp, primary color (selected)
- Label: 16sp, right of radio

**ASCII Representation**:
```
┌─────────────────────────────┐
│ ⦿ Metric                    │
│ ○ Imperial                  │
└─────────────────────────────┘
```

**States**:
- **Unselected**: Grey border, white background
- **Selected**: Primary border, primary dot
- **Disabled**: Grey, no interaction

**Accessibility**: Same as Checkbox

### Toggle Switch

**Purpose**: On/Off setting (Notifications, Features)

**Specifications**:
- Width: 48dp
- Height: 28dp
- Track: Grey (off), primary (on)
- Thumb: 20dp circle, white
- Label: 16sp, left of switch

**ASCII Representation**:
```
┌─────────────────────────────┐
│ Medication Reminders    [●─] │
│ Workout Reminders       [─○] │
└─────────────────────────────┘
```

**States**:
- **Off**: Grey track, thumb on left
- **On**: Primary track, thumb on right
- **Disabled**: Grey, no interaction
- **Animating**: Smooth slide animation

**Accessibility**:
- Screen reader: "Medication Reminders switch, on"
- Keyboard: Space to toggle

---

## Feedback Components

### Alert/Toast Message

**Purpose**: Temporary feedback (Success, Error, Info)

**Specifications**:
- Position: Bottom of screen (toast) or top (alert)
- Width: Screen width minus 32dp margin
- Padding: 16dp
- Border Radius: 8dp
- Background: Primary (success), red (error), blue (info)
- Text: White, 14sp
- Icon: 24dp, left-aligned
- Duration: 3 seconds (auto-dismiss)

**ASCII Representation**:
```
┌─────────────────────────────┐
│                             │
│  ✓ Weight saved successfully│
│                             │
└─────────────────────────────┘
```

**States**:
- **Showing**: Slides in from bottom
- **Visible**: Static display
- **Dismissing**: Slides out to bottom

**Accessibility**:
- Screen reader: Announces message immediately
- Auto-dismiss: Can be extended by user

### Error Message

**Purpose**: Form validation errors

**Specifications**:
- Position: Below input field
- Text: Red, 12sp
- Icon: 16dp, error icon, optional
- Padding: 8dp top

**ASCII Representation**:
```
┌─────────────────────────────┐
│ ┌─────────────────────────┐ │
│ │                         │ │
│ └─────────────────────────┘ │
│ ⚠ Weight is required        │
└─────────────────────────────┘
```

**Accessibility**:
- Screen reader: Announces error immediately
- Associated with input field
- Keyboard focus moves to error

### Loading Indicator

**Purpose**: Show loading state

**Specifications**:
- Type: Circular spinner or linear progress
- Size: 48dp (spinner), full width (linear)
- Color: Primary color
- Animation: Continuous rotation (spinner) or fill (linear)

**ASCII Representation**:
```
┌─────────────────────────────┐
│        ⟳                     │
│     Loading...               │
└─────────────────────────────┘
```

**Accessibility**:
- Screen reader: "Loading" or "Processing"
- Non-blocking: User can cancel if needed

---

## Component States Summary

### Interactive States
1. **Default**: Initial state, ready for interaction
2. **Hover**: Mouse over (web/desktop)
3. **Pressed/Tapped**: User interaction in progress
4. **Focused**: Keyboard navigation focus
5. **Selected**: Active/selected state
6. **Disabled**: Not interactive, greyed out
7. **Loading**: Processing/loading state
8. **Error**: Error state with feedback

### Visual Feedback
- **Elevation**: Shadows indicate interactivity
- **Color Changes**: Primary color for active states
- **Animations**: Smooth transitions (200-300ms)
- **Haptic Feedback**: Vibration on tap (optional)

## Accessibility Checklist

For each component, ensure:

- [ ] Screen reader labels (SemanticLabel)
- [ ] Minimum touch target (48x48dp)
- [ ] Keyboard navigation support
- [ ] Focus indicators (2dp outline)
- [ ] Color contrast (4.5:1 minimum)
- [ ] Text scaling support (up to 200%)
- [ ] High contrast mode support
- [ ] Error announcements
- [ ] State announcements (selected, disabled)

## Implementation Notes

- All components use Material Design 3 principles
- Components are built with Flutter Material widgets
- Customization via theme (design system option)
- Responsive: Adapt to screen size
- Dark mode: All components support dark theme
- Localization: Text strings externalized

## References

- **Design System**: `artifacts/phase-1-foundations/design-system-options.md`
- **Wireframes**: `artifacts/phase-1-foundations/wireframes.md`
- **Architecture**: `artifacts/phase-1-foundations/architecture-documentation.md`
- **WCAG 2.1**: https://www.w3.org/WAI/WCAG21/quickref/
- **Material Design**: https://material.io/design

---

**Last Updated**: [Date]  
**Version**: 1.0  
**Status**: Component Specifications Complete

