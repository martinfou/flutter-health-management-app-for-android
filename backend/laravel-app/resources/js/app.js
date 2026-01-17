import './bootstrap';

// ========== CLINICAL PRO DESIGN SYSTEM ==========
// Import Alpine.js for lightweight interactivity
import Alpine from 'alpinejs';

// Import Clinical Pro modules
import { initDarkMode, darkModeComponent } from './modules/dark-mode';
import { initSidebar, sidebarComponent } from './modules/sidebar';
import { initCharts, createLineChart, createBarChart } from './modules/charts';
import { initDataTables, initSimpleTable } from './modules/tables';

// Make Alpine available globally
window.Alpine = Alpine;

// Define Alpine components
Alpine.data('darkModeComponent', darkModeComponent);
Alpine.data('sidebarComponent', sidebarComponent);

// Initialize Alpine.js
Alpine.start();

// Initialize Clinical Pro modules on DOMContentLoaded
document.addEventListener('DOMContentLoaded', () => {
    // Initialize dark mode toggle
    initDarkMode();

    // Initialize sidebar collapse
    initSidebar();

    // Initialize charts (if any exist on the page)
    if (document.querySelector('[data-chart]')) {
        initCharts();
    }

    // Initialize DataTables (if any exist on the page)
    if (document.querySelector('[data-table]')) {
        initDataTables();
    }
});

// Expose utilities globally for use in console/external scripts
window.ClinicalPro = {
    initCharts,
    createLineChart,
    createBarChart,
    initDataTables,
    initSimpleTable,
    initDarkMode,
    initSidebar,
};
