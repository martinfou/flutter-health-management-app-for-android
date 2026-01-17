# Clinical Pro Design System - Setup & Deployment Guide

## Overview

The **Clinical Pro** design system has been successfully implemented for the Laravel health management web app. This is a modern, professional, data-driven UI framework built with:

- **Frontend Framework**: Bootstrap 5 + Tailwind CSS 3
- **Chart Library**: Chart.js 4.4
- **Table Library**: DataTables.js 1.13
- **Interactivity**: Alpine.js 3.14
- **Build Tool**: Vite

## Installation & Setup

### 1. Install Dependencies

```bash
cd backend/laravel-app
npm install
```

This will install all required packages:
- `chart.js` - Data visualization
- `datatables.net` & `datatables.net-bs5` - Advanced tables
- `alpine.js` - Lightweight interactivity
- `@tailwindcss/forms` - Form styling
- And all other dev dependencies

### 2. Run Development Server

```bash
npm run dev
```

This will start the Vite development server and watch for file changes.

### 3. Build for Production

```bash
npm run build
```

This will compile and minify all assets for production deployment.

## Project Structure

```
resources/
├── sass/
│   ├── app.scss                    # Main SCSS entry point
│   ├── _clinical-variables.scss    # Clinical Pro color palette & spacing
│   ├── _clinical-typography.scss   # Font system & type scale
│   └── bootstrap/                  # Bootstrap SCSS files
│
├── views/
│   ├── layouts/
│   │   └── app.blade.php          # Main layout with sidebar + navbar
│   ├── components/
│   │   ├── clinical-sidebar.blade.php
│   │   ├── clinical-navbar.blade.php
│   │   ├── clinical-breadcrumbs.blade.php
│   │   ├── clinical-kpi-bar.blade.php
│   │   └── clinical-chart-card.blade.php
│   └── dashboard/
│       ├── index.blade.php        # Dashboard with charts & KPI
│       ├── health-metrics.blade.php
│       ├── meals.blade.php
│       ├── exercises.blade.php
│       └── profile.blade.php
│
└── js/
    ├── app.js                      # Main JS entry point
    └── modules/
        ├── dark-mode.js            # Dark mode toggle
        ├── sidebar.js              # Sidebar collapse
        ├── charts.js               # Chart.js initialization
        └── tables.js               # DataTables initialization
```

## Key Features

### 🎨 Design System

**Color Palette:**
- Primary Navy: `#1E293B` - Brand color
- Electric Blue: `#3B82F6` - Interactive elements
- Semantic Colors: Green (#10B981), Amber (#F59E0B), Red (#EF4444)

**Typography:**
- Headings: Manrope (bold, geometric)
- Body: Inter (clean, readable)
- Data: JetBrains Mono (monospace metrics)

**Spacing & Layout:**
- 8dp base unit grid
- Responsive breakpoints: sm (640px), md (768px), lg (992px), xl (1200px)
- 4-column responsive grid system

### 🌙 Dark Mode

Automatic dark mode support with:
- System preference detection
- Manual toggle in navbar
- localStorage persistence
- All components have dark variants

**Enable Dark Mode:**
```html
<!-- Automatically detected or toggled via navbar button -->
<!-- Toggle button in clinical-navbar.blade.php -->
```

### 📊 Dashboard Features

1. **KPI Bar** - Horizontal metrics with trends and sparklines
2. **Interactive Charts** - Weight trend (line chart) & activity distribution (bar chart)
3. **Data Tables** - Advanced table with sorting, filtering, pagination
4. **Responsive Layout** - Collapsible sidebar on mobile

### 🧩 Reusable Components

All components are Blade components located in `resources/views/components/`:

```blade
<!-- KPI Bar Component -->
@component('components.clinical-kpi-bar', [
    'metrics' => [
        ['icon' => 'heart', 'label' => 'Metrics', 'value' => 42, ...]
    ]
])
@endcomponent

<!-- Chart Card Component -->
@component('components.clinical-chart-card', [
    'title' => 'Weight Trend',
    'chart_id' => 'weight-chart',
    'chart_config' => $chartConfig
])
@endcomponent

<!-- Breadcrumbs Component -->
@component('components.clinical-breadcrumbs', [
    'items' => [
        ['label' => 'Home', 'url' => '/'],
        ['label' => 'Metrics']
    ]
])
@endcomponent
```

### ⚡ JavaScript Modules

Available via `window.ClinicalPro`:

```javascript
// Initialize charts
window.ClinicalPro.initCharts();

// Initialize data tables
window.ClinicalPro.initDataTables('[data-table]');

// Toggle dark mode
window.ClinicalPro.initDarkMode();

// Manage sidebar
window.ClinicalPro.initSidebar();
```

## Pages Redesigned

✅ **Dashboard** (`/dashboard`)
- KPI bar with 4 metrics
- 2-column chart grid
- Recent metrics table

✅ **Health Metrics** (`/health-metrics`)
- Advanced DataTable with sorting/filtering
- Responsive columns
- Action buttons per row

✅ **Meals** (`/meals`)
- Color-coded meal types (breakfast, lunch, dinner, snack)
- Macro tracking (protein, carbs, fat)
- Calories display

✅ **Exercises** (`/exercises`)
- Duration and calories display
- Intensity level badges
- Sortable table

✅ **Profile** (`/profile`)
- Account information section
- Health profile section
- Clean layout with metrics display

## Customization

### Change Primary Color

Edit `resources/sass/_clinical-variables.scss`:

```scss
$navy-900: #1e293b;  // Change this to your brand color
$blue-500: #3b82f6;  // Change accent color
```

Then rebuild:
```bash
npm run build
```

### Add New Chart

1. **Create chart config in controller:**
```php
$myChart = [
    'type' => 'line',
    'data' => [
        'labels' => ['Jan', 'Feb', 'Mar'],
        'datasets' => [[
            'label' => 'My Data',
            'data' => [10, 20, 30]
        ]]
    ]
];
```

2. **Use in Blade:**
```blade
@component('components.clinical-chart-card', [
    'title' => 'My Chart',
    'chart_id' => 'my-chart',
    'chart_config' => $myChart
])
@endcomponent
```

### Modify Table Styling

Edit table CSS in individual page files:

```scss
.table {
    font-size: 0.9375rem;
}

.table thead {
    background: #f1f5f9;
}

.table tbody tr:hover {
    background: #f8fafc;
}
```

## Performance

**Bundle Sizes (Estimated):**
- CSS: ~80KB compiled (including Bootstrap + Tailwind)
- JavaScript: ~125KB (Chart.js + DataTables + Alpine.js)
- Total gzipped: ~85KB

**Optimization Tips:**
1. Use lazy loading for charts on large dashboards
2. Implement code splitting for page-specific JavaScript
3. Minify and gzip assets (Vite does this automatically)
4. Cache static assets with long expiration headers

## Browser Support

- Chrome/Edge: Latest 2 versions
- Firefox: Latest 2 versions
- Safari: Latest 2 versions
- Mobile browsers: iOS Safari 12+, Chrome Mobile

## Accessibility

All components follow WCAG 2.1 AA standards:
- ✅ Semantic HTML structure
- ✅ Keyboard navigation support
- ✅ ARIA labels where needed
- ✅ Color contrast ratios ≥ 4.5:1
- ✅ Focus indicators on interactive elements

## Troubleshooting

### Charts not showing?

1. Ensure Chart.js is loaded: `npm run dev` and check console
2. Verify chart config is passed correctly
3. Check browser console for errors

### DataTables not working?

1. Ensure table has `data-table` class
2. Verify jQuery is loaded (DataTables requires it)
3. Check for JavaScript errors in console

### Dark mode not persisting?

1. Check localStorage in DevTools
2. Verify `dark-mode.js` module is loaded
3. Clear browser cache and try again

### Styling issues?

1. Clear browser cache
2. Run `npm run build` and restart dev server
3. Check for CSS conflicts in browser DevTools

## Deployment Checklist

Before deploying to production:

- [ ] Run `npm run build` successfully
- [ ] All pages render without errors
- [ ] Dark mode works correctly
- [ ] Tables and charts display properly
- [ ] Mobile responsive (test on phone)
- [ ] Lighthouse score ≥ 85 (desktop)
- [ ] No console errors or warnings
- [ ] Form validation working
- [ ] Links and navigation functional
- [ ] API calls working correctly

## Maintenance

### Update Dependencies

```bash
npm update
```

### Add New Package

```bash
npm install <package-name>
npm run build
```

### Monitor Bundle Size

```bash
npm run build -- --analyze
```

## Support & Documentation

- **Bootstrap 5**: https://getbootstrap.com/docs/5.0/
- **Tailwind CSS**: https://tailwindcss.com/docs
- **Chart.js**: https://www.chartjs.org/docs/latest/
- **DataTables**: https://datatables.net/
- **Alpine.js**: https://alpinejs.dev/

## License

This Clinical Pro design system is part of the Health Management App project.

---

**Last Updated**: January 2026
**Design System Version**: 1.0.0
**Laravel Version**: Required (check `composer.json`)
**Node Version**: 16+ recommended
