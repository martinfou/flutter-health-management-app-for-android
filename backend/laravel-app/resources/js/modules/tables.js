/**
 * DataTables Module
 * Wrapper for DataTables.js initialization with Clinical Pro styling
 */

import DataTable from 'datatables.net-bs5';

/**
 * Initialize DataTables on elements with data-table attribute
 * Usage: <table data-table></table>
 */
export function initDataTables(selector = '[data-table]') {
    const tableElements = document.querySelectorAll(selector);
    const tables = {};

    tableElements.forEach((element) => {
        const tableId = element.id || `table-${Math.random().toString(36).substr(2, 9)}`;

        try {
            const config = getTableConfig(element);
            tables[tableId] = new DataTable(element, config);
        } catch (error) {
            console.error('Error initializing DataTable:', error, element);
        }
    });

    return tables;
}

/**
 * Get DataTable configuration with Clinical Pro styling
 */
function getTableConfig(element) {
    const isDarkMode = document.documentElement.getAttribute('data-theme') === 'dark';

    return {
        responsive: true,
        pageLength: 20,
        pagingType: 'full_numbers',
        lengthMenu: [
            [10, 20, 50, 100, -1],
            [10, 20, 50, 100, 'All'],
        ],
        language: {
            search: '<i class="fas fa-search"></i> Filter results:',
            searchPlaceholder: 'Search...',
            lengthMenu: 'Show _MENU_ entries',
            info: 'Showing _START_ to _END_ of _TOTAL_ entries',
            infoEmpty: 'Showing 0 to 0 of 0 entries',
            infoFiltered: '(filtered from _MAX_ total entries)',
            paginate: {
                first: '<i class="fas fa-chevron-double-left"></i>',
                last: '<i class="fas fa-chevron-double-right"></i>',
                next: '<i class="fas fa-chevron-right"></i>',
                previous: '<i class="fas fa-chevron-left"></i>',
            },
        },
        columnDefs: [
            {
                targets: 'no-sort',
                orderable: false,
            },
        ],
        dom: '<"row table-controls"<"col-md-6"l><"col-md-6"f>>' +
            't' +
            '<"row table-footer"<"col-md-6"i><"col-md-6"p>>',
        initComplete: function (settings, json) {
            applyClinicalpStyling(element, isDarkMode);
        },
    };
}

/**
 * Apply Clinical Pro styling to DataTable
 */
function applyClinicalpStyling(element, isDarkMode) {
    const wrapper = element.closest('.dataTables_wrapper');
    if (!wrapper) return;

    // Add Clinical Pro classes to wrapper
    wrapper.classList.add('clinical-datatable');
    if (isDarkMode) {
        wrapper.classList.add('dark');
    }

    // Style the search input
    const searchInput = wrapper.querySelector('.dataTables_filter input');
    if (searchInput) {
        searchInput.classList.add('form-control', 'form-control-sm', 'clinical-search');
        searchInput.placeholder = 'Search...';
    }

    // Style the length select
    const lengthSelect = wrapper.querySelector('.dataTables_length select');
    if (lengthSelect) {
        lengthSelect.classList.add('form-select', 'form-select-sm', 'clinical-select');
    }

    // Style pagination buttons
    const paginationButtons = wrapper.querySelectorAll('.paginate_button');
    paginationButtons.forEach((btn) => {
        if (!btn.classList.contains('previous') && !btn.classList.contains('next')) {
            btn.classList.add('btn', 'btn-sm');
        }
    });
}

/**
 * Initialize a simple DataTable with custom config
 */
export function initSimpleTable(tableSelector, customConfig = {}) {
    const element = document.querySelector(tableSelector);
    if (!element) return null;

    const defaultConfig = getTableConfig(element);
    const mergedConfig = { ...defaultConfig, ...customConfig };

    return new DataTable(element, mergedConfig);
}

/**
 * Add class to rows based on condition
 */
export function highlightRows(tableId, condition, className) {
    const table = jQuery(`#${tableId}`).DataTable();
    const rows = table.rows().nodes();

    rows.forEach((row) => {
        if (condition(row)) {
            row.classList.add(className);
        }
    });
}

/**
 * Search DataTable programmatically
 */
export function searchTable(tableId, term) {
    const table = jQuery(`#${tableId}`).DataTable();
    table.search(term).draw();
}

/**
 * Filter DataTable by column
 */
export function filterByColumn(tableId, columnIndex, term) {
    const table = jQuery(`#${tableId}`).DataTable();
    table.column(columnIndex).search(term).draw();
}

/**
 * Clear all DataTable filters
 */
export function clearFilters(tableId) {
    const table = jQuery(`#${tableId}`).DataTable();
    table.search('').columns().search('').draw();
}

/**
 * Listen for theme changes and update table styling
 */
export function watchThemeChanges() {
    window.addEventListener('themechange', (e) => {
        const isDarkMode = e.detail.theme === 'dark';
        const wrappers = document.querySelectorAll('.clinical-datatable');

        wrappers.forEach((wrapper) => {
            if (isDarkMode) {
                wrapper.classList.add('dark');
            } else {
                wrapper.classList.remove('dark');
            }
        });
    });
}

// Initialize on DOM ready
document.addEventListener('DOMContentLoaded', () => {
    initDataTables();
    watchThemeChanges();
});
