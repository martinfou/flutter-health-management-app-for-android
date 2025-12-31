# Design System Options

## Overview

This document presents 3-4 distinct design system options for the Flutter Health Management App for Android. Each option includes a complete color palette, typography system, spacing system, and component styles. The design systems are optimized for health data visualization, accessibility (WCAG 2.1 AA compliance), and Android platform conventions.

**Reference**: Based on requirements in `artifacts/requirements.md` and architecture in `artifacts/phase-1-foundations/architecture-documentation.md`.

## Design System Option 1: Modern Health Minimal

### Design Philosophy

Clean, minimal design focused on data clarity and user focus. Emphasizes whitespace and clear typography hierarchy. Ideal for users who prefer distraction-free interfaces and clear data visualization.

### Color Palette

**Primary Colors**:
- Primary: `#2E7D32` (Green 800) - Health, growth, progress
- Primary Light: `#4CAF50` (Green 500) - Accents, success states
- Primary Dark: `#1B5E20` (Green 900) - Dark mode, emphasis

**Secondary Colors**:
- Secondary: `#1976D2` (Blue 700) - Information, links
- Secondary Light: `#42A5F5` (Blue 400) - Highlights
- Secondary Dark: `#0D47A1` (Blue 900) - Dark mode

**Accent Colors**:
- Accent: `#FF6F00` (Amber 800) - Warnings, important alerts
- Success: `#2E7D32` (Green 800)
- Warning: `#F57C00` (Orange 700)
- Error: `#C62828` (Red 800)
- Info: `#1976D2` (Blue 700)

**Neutral Colors**:
- Background: `#FFFFFF` (White)
- Surface: `#F5F5F5` (Grey 100)
- Surface Elevated: `#FFFFFF` (White with shadow)
- Text Primary: `#212121` (Grey 900)
- Text Secondary: `#757575` (Grey 600)
- Text Disabled: `#BDBDBD` (Grey 400)
- Divider: `#E0E0E0` (Grey 300)
- Border: `#E0E0E0` (Grey 300)

**Dark Mode Support**:
- Background: `#121212` (Material Dark)
- Surface: `#1E1E1E` (Dark Surface)
- Text Primary: `#FFFFFF` (White)
- Text Secondary: `#B3B3B3` (Grey 400)

### Typography

**Font Family**: Roboto (Android system font)

**Font Sizes**:
- Display Large: 57sp (Hero text, large titles)
- Display Medium: 45sp (Section headers)
- Display Small: 36sp (Page titles)
- Headline Large: 32sp (Card titles)
- Headline Medium: 28sp (Subsection headers)
- Headline Small: 24sp (Card subtitles)
- Title Large: 22sp (List item titles)
- Title Medium: 16sp (Button text, labels)
- Title Small: 14sp (Small labels)
- Body Large: 16sp (Body text)
- Body Medium: 14sp (Secondary body text)
- Body Small: 12sp (Captions, hints)
- Label Large: 14sp (Input labels)
- Label Medium: 12sp (Small labels)
- Label Small: 11sp (Tiny labels)

**Font Weights**:
- Regular: 400 (Body text)
- Medium: 500 (Emphasis, buttons)
- Bold: 700 (Headings, important text)

**Line Heights**:
- Tight: 1.2 (Headings)
- Normal: 1.5 (Body text)
- Relaxed: 1.75 (Long-form content)

### Spacing System

**Base Unit**: 4dp (Material Design standard)

**Spacing Scale**:
- XS: 4dp (Tight spacing, icon padding)
- SM: 8dp (Component padding, small gaps)
- MD: 16dp (Standard padding, card padding)
- LG: 24dp (Section spacing, large gaps)
- XL: 32dp (Page margins, major sections)
- XXL: 48dp (Screen edges, major breaks)

**Component Spacing**:
- Button Padding: 12dp vertical, 24dp horizontal
- Card Padding: 16dp
- Input Padding: 16dp
- List Item Padding: 16dp vertical, 16dp horizontal
- Screen Padding: 16dp (mobile), 24dp (tablet)

### Component Styles

**Buttons**:
- Primary: Green background, white text, 8dp radius, 48dp min height
- Secondary: Outlined, green border, green text, 8dp radius
- Text: Transparent, green text, no border
- Icon: Circular, 48dp, icon only

**Input Fields**:
- Border: 1dp, grey border, 8dp radius
- Focus: 2dp, green border
- Error: 2dp, red border
- Padding: 16dp
- Min Height: 56dp

**Cards**:
- Background: White, elevated with shadow
- Border Radius: 12dp
- Padding: 16dp
- Elevation: 2dp (subtle shadow)

**Navigation**:
- Bottom Nav: 56dp height, white background, grey icons, green active
- App Bar: 56dp height, white background, green accent
- Tab Bar: 48dp height, underline indicator

### Accessibility

- Color Contrast: All text meets WCAG 2.1 AA (4.5:1 minimum)
- Touch Targets: Minimum 48x48dp
- Focus Indicators: 2dp green outline
- Screen Reader: Semantic labels on all interactive elements

### Use Case

Best for: Users who prefer clean, data-focused interfaces. Excellent for displaying health metrics and charts clearly.

---

## Design System Option 2: Warm Wellness

### Design Philosophy

Warm, inviting design that feels supportive and encouraging. Uses warmer tones and softer edges to create a friendly, approachable feel. Ideal for users who need motivation and positive reinforcement.

### Color Palette

**Primary Colors**:
- Primary: `#E65100` (Deep Orange 900) - Energy, warmth
- Primary Light: `#FF9800` (Orange 500) - Accents, highlights
- Primary Dark: `#BF360C` (Deep Orange 900) - Dark mode

**Secondary Colors**:
- Secondary: `#5D4037` (Brown 700) - Earthy, grounded
- Secondary Light: `#8D6E63` (Brown 500) - Subtle accents
- Secondary Dark: `#3E2723` (Brown 900) - Dark mode

**Accent Colors**:
- Accent: `#F9A825` (Amber 800) - Positive energy
- Success: `#558B2F` (Light Green 800) - Growth
- Warning: `#E65100` (Deep Orange 900)
- Error: `#C62828` (Red 800)
- Info: `#0277BD` (Light Blue 800)

**Neutral Colors**:
- Background: `#FFF8E1` (Amber 50) - Warm white
- Surface: `#FFFFFF` (White)
- Surface Elevated: `#FFF8E1` (Warm white with shadow)
- Text Primary: `#3E2723` (Brown 900)
- Text Secondary: `#6D4C41` (Brown 600)
- Text Disabled: `#BCAAA4` (Brown 300)
- Divider: `#D7CCC8` (Brown 200)
- Border: `#D7CCC8` (Brown 200)

**Dark Mode Support**:
- Background: `#1C1B1A` (Warm dark)
- Surface: `#2A2826` (Dark surface)
- Text Primary: `#FFF8E1` (Warm white)
- Text Secondary: `#D7CCC8` (Brown 200)

### Typography

**Font Family**: Roboto (Android system font)

**Font Sizes**: Same as Option 1

**Font Weights**:
- Regular: 400 (Body text)
- Medium: 500 (Emphasis)
- Semi-Bold: 600 (Headings, important text)
- Bold: 700 (Hero text)

**Line Heights**: Same as Option 1

### Spacing System

**Base Unit**: 4dp

**Spacing Scale**: Same as Option 1

**Component Spacing**:
- Button Padding: 14dp vertical, 28dp horizontal (slightly larger)
- Card Padding: 20dp (more generous)
- Input Padding: 16dp
- List Item Padding: 20dp vertical, 16dp horizontal
- Screen Padding: 20dp (mobile), 32dp (tablet)

### Component Styles

**Buttons**:
- Primary: Orange background, white text, 12dp radius (softer), 52dp min height
- Secondary: Outlined, orange border, orange text, 12dp radius
- Text: Transparent, orange text
- Icon: Circular, 52dp

**Input Fields**:
- Border: 1dp, brown border, 12dp radius (softer)
- Focus: 2dp, orange border
- Error: 2dp, red border
- Padding: 16dp
- Min Height: 56dp

**Cards**:
- Background: White, warm shadow
- Border Radius: 16dp (softer, more rounded)
- Padding: 20dp
- Elevation: 3dp (more pronounced shadow)

**Navigation**:
- Bottom Nav: 60dp height, warm white background, brown icons, orange active
- App Bar: 56dp height, warm white background, orange accent
- Tab Bar: 48dp height, underline indicator

### Accessibility

- Color Contrast: All text meets WCAG 2.1 AA
- Touch Targets: Minimum 48x48dp (some 52dp for emphasis)
- Focus Indicators: 2dp orange outline
- Screen Reader: Semantic labels

### Use Case

Best for: Users who need encouragement and motivation. Creates a supportive, friendly atmosphere.

---

## Design System Option 3: Professional Medical

### Design Philosophy

Clean, professional design inspired by medical and clinical applications. Emphasizes trust, accuracy, and clarity. Uses cool tones and precise layouts. Ideal for users who value data accuracy and professional presentation.

### Color Palette

**Primary Colors**:
- Primary: `#1565C0` (Blue 800) - Trust, professionalism
- Primary Light: `#42A5F5` (Blue 400) - Accents
- Primary Dark: `#0D47A1` (Blue 900) - Dark mode

**Secondary Colors**:
- Secondary: `#424242` (Grey 800) - Neutral, professional
- Secondary Light: `#757575` (Grey 600)
- Secondary Dark: `#212121` (Grey 900)

**Accent Colors**:
- Accent: `#00897B` (Teal 600) - Health, vitality
- Success: `#2E7D32` (Green 800)
- Warning: `#F57C00` (Orange 700)
- Error: `#C62828` (Red 800)
- Info: `#1565C0` (Blue 800)

**Neutral Colors**:
- Background: `#FAFAFA` (Grey 50) - Cool white
- Surface: `#FFFFFF` (White)
- Surface Elevated: `#FFFFFF` (White with shadow)
- Text Primary: `#212121` (Grey 900)
- Text Secondary: `#616161` (Grey 700)
- Text Disabled: `#9E9E9E` (Grey 500)
- Divider: `#E0E0E0` (Grey 300)
- Border: `#BDBDBD` (Grey 400)

**Dark Mode Support**:
- Background: `#121212` (Material Dark)
- Surface: `#1E1E1E` (Dark Surface)
- Text Primary: `#FFFFFF` (White)
- Text Secondary: `#B0B0B0` (Grey 400)

### Typography

**Font Family**: Roboto (Android system font)

**Font Sizes**: Same as Option 1

**Font Weights**:
- Regular: 400 (Body text)
- Medium: 500 (Labels, emphasis)
- Bold: 700 (Headings, data)

**Line Heights**:
- Tight: 1.15 (Data displays)
- Normal: 1.4 (Body text)
- Relaxed: 1.6 (Long-form content)

### Spacing System

**Base Unit**: 4dp

**Spacing Scale**: Same as Option 1

**Component Spacing**:
- Button Padding: 12dp vertical, 24dp horizontal
- Card Padding: 16dp
- Input Padding: 16dp
- List Item Padding: 12dp vertical, 16dp horizontal (tighter)
- Screen Padding: 16dp (mobile), 24dp (tablet)

### Component Styles

**Buttons**:
- Primary: Blue background, white text, 4dp radius (sharp), 48dp min height
- Secondary: Outlined, blue border, blue text, 4dp radius
- Text: Transparent, blue text
- Icon: Square with rounded corners, 48dp

**Input Fields**:
- Border: 1dp, grey border, 4dp radius (sharp)
- Focus: 2dp, blue border
- Error: 2dp, red border
- Padding: 16dp
- Min Height: 56dp

**Cards**:
- Background: White, precise shadow
- Border Radius: 8dp (moderate)
- Padding: 16dp
- Elevation: 2dp (subtle)

**Navigation**:
- Bottom Nav: 56dp height, white background, grey icons, blue active
- App Bar: 56dp height, white background, blue accent
- Tab Bar: 48dp height, underline indicator

### Accessibility

- Color Contrast: All text meets WCAG 2.1 AA (some 7:1 for important data)
- Touch Targets: Minimum 48x48dp
- Focus Indicators: 2dp blue outline
- Screen Reader: Comprehensive labels, ARIA attributes

### Use Case

Best for: Users who value professional presentation and data accuracy. Excellent for clinical or medical contexts.

---

## Design System Option 4: Vibrant Energy

### Design Philosophy

Bold, energetic design with vibrant colors and dynamic layouts. Encourages engagement and active participation. Uses high contrast and bold typography. Ideal for users who want an engaging, motivating experience.

### Color Palette

**Primary Colors**:
- Primary: `#7B1FA2` (Purple 700) - Energy, transformation
- Primary Light: `#BA68C8` (Purple 300) - Accents
- Primary Dark: `#4A148C` (Purple 900) - Dark mode

**Secondary Colors**:
- Secondary: `#E91E63` (Pink 500) - Vitality, energy
- Secondary Light: `#F48FB1` (Pink 200)
- Secondary Dark: `#880E4F` (Pink 900)

**Accent Colors**:
- Accent: `#FF6F00` (Amber 800) - Energy, action
- Success: `#00C853` (Green 600) - Bright success
- Warning: `#FFD600` (Amber 600) - Bright warning
- Error: `#D32F2F` (Red 700)
- Info: `#0091EA` (Light Blue 700)

**Neutral Colors**:
- Background: `#FFFFFF` (White)
- Surface: `#F5F5F5` (Grey 100)
- Surface Elevated: `#FFFFFF` (White with shadow)
- Text Primary: `#212121` (Grey 900)
- Text Secondary: `#757575` (Grey 600)
- Text Disabled: `#BDBDBD` (Grey 400)
- Divider: `#E0E0E0` (Grey 300)
- Border: `#E0E0E0` (Grey 300)

**Dark Mode Support**:
- Background: `#121212` (Material Dark)
- Surface: `#1E1E1E` (Dark Surface)
- Text Primary: `#FFFFFF` (White)
- Text Secondary: `#B3B3B3` (Grey 400)

### Typography

**Font Family**: Roboto (Android system font)

**Font Sizes**: Same as Option 1, with slightly larger display sizes

**Font Weights**:
- Regular: 400 (Body text)
- Medium: 500 (Emphasis)
- Bold: 700 (Headings, important text)
- Extra Bold: 800 (Hero text, call-to-action)

**Line Heights**: Same as Option 1

### Spacing System

**Base Unit**: 4dp

**Spacing Scale**: Same as Option 1

**Component Spacing**:
- Button Padding: 16dp vertical, 32dp horizontal (generous)
- Card Padding: 20dp
- Input Padding: 16dp
- List Item Padding: 20dp vertical, 20dp horizontal
- Screen Padding: 20dp (mobile), 32dp (tablet)

### Component Styles

**Buttons**:
- Primary: Purple gradient background, white text, 16dp radius (very rounded), 56dp min height
- Secondary: Outlined, purple border, purple text, 16dp radius
- Text: Transparent, purple text, bold
- Icon: Circular, 56dp

**Input Fields**:
- Border: 2dp, purple border, 16dp radius (very rounded)
- Focus: 3dp, purple border with glow effect
- Error: 3dp, red border
- Padding: 16dp
- Min Height: 56dp

**Cards**:
- Background: White, bold shadow
- Border Radius: 20dp (very rounded)
- Padding: 20dp
- Elevation: 4dp (pronounced shadow)

**Navigation**:
- Bottom Nav: 64dp height, white background, purple icons, gradient active
- App Bar: 64dp height, gradient background, white text
- Tab Bar: 52dp height, underline indicator with gradient

### Accessibility

- Color Contrast: All text meets WCAG 2.1 AA (some 7:1 for emphasis)
- Touch Targets: Minimum 48x48dp (many 56dp)
- Focus Indicators: 3dp purple outline with glow
- Screen Reader: Semantic labels, animated feedback

### Use Case

Best for: Users who want an engaging, motivating experience. Excellent for users who need energy and excitement in their health journey.

---

## Design System Comparison

| Feature | Option 1: Minimal | Option 2: Warm | Option 3: Professional | Option 4: Vibrant |
|---------|------------------|----------------|----------------------|-------------------|
| **Primary Color** | Green | Orange | Blue | Purple |
| **Personality** | Clean, focused | Warm, supportive | Professional, precise | Energetic, bold |
| **Best For** | Data-focused users | Motivation seekers | Clinical contexts | Engagement seekers |
| **Border Radius** | 8dp (moderate) | 12-16dp (soft) | 4dp (sharp) | 16-20dp (very rounded) |
| **Spacing** | Standard | Generous | Tighter | Generous |
| **Accessibility** | High | High | Very High | High |

## Recommendation

For a health management app focused on weight loss, **Option 1 (Modern Health Minimal)** or **Option 2 (Warm Wellness)** are recommended:

- **Option 1** provides excellent data clarity and is ideal for users who track metrics closely
- **Option 2** provides emotional support and motivation, ideal for users who need encouragement

However, all options meet WCAG 2.1 AA accessibility requirements and can be customized based on user preference.

## Implementation Notes

- All design systems support dark mode
- Color contrast ratios meet or exceed WCAG 2.1 AA (4.5:1 for normal text, 3:1 for large text)
- Touch targets meet Material Design minimums (48x48dp)
- Typography scales are consistent across all options
- Spacing system uses 4dp base unit for consistency
- Components are designed for Flutter Material Design widgets

## References

- **Requirements**: `artifacts/requirements.md` - UI/UX requirements and accessibility standards
- **Architecture**: `artifacts/phase-1-foundations/architecture-documentation.md` - Component structure
- **WCAG 2.1**: https://www.w3.org/WAI/WCAG21/quickref/?currentsidebar=%23col_customize&levels=aaa
- **Material Design**: https://material.io/design

---

**Last Updated**: [Date]  
**Version**: 1.0  
**Status**: Design System Options Complete

