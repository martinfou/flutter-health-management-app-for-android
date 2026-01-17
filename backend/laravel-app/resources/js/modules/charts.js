/**
 * Charts Module
 * Wrapper for Chart.js initialization and configuration
 */

import Chart from 'chart.js/auto';
import ChartDataLabels from 'chartjs-plugin-datalabels';

// Register plugins
Chart.register(ChartDataLabels);

/**
 * Initialize all charts on the page
 * Usage: Add data-chart attribute to canvas elements with JSON config
 * Example: <canvas data-chart='{"type":"line","data":{...}}'></canvas>
 */
export function initCharts() {
    const chartElements = document.querySelectorAll('[data-chart]');
    const charts = {};

    chartElements.forEach((element) => {
        try {
            const config = JSON.parse(element.dataset.chart);
            const chartId = element.id || `chart-${Math.random().toString(36).substr(2, 9)}`;

            // Apply Clinical Pro styling
            const mergedConfig = applyClinicalpStyle(config);

            // Create chart instance
            charts[chartId] = new Chart(element, mergedConfig);
        } catch (error) {
            console.error('Error initializing chart:', error, element);
        }
    });

    return charts;
}

/**
 * Apply Clinical Pro styling to chart configuration
 */
function applyClinicalpStyle(config) {
    const isDarkMode = document.documentElement.getAttribute('data-theme') === 'dark';

    // Base colors
    const textColor = isDarkMode ? '#cbd5e1' : '#64748b';
    const gridColor = isDarkMode ? '#334155' : '#e2e8f0';
    const primaryColor = '#1e293b';
    const accentColor = '#3b82f6';
    const successColor = '#10b981';
    const warningColor = '#f59e0b';
    const dangerColor = '#ef4444';

    return {
        ...config,
        options: {
            ...config.options,
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                ...config.options?.plugins,
                legend: {
                    ...config.options?.plugins?.legend,
                    labels: {
                        font: {
                            family: "'Inter', sans-serif",
                            size: 12,
                            weight: 500,
                        },
                        color: textColor,
                        padding: 16,
                        usePointStyle: true,
                        pointStyle: 'circle',
                    },
                },
                tooltip: {
                    ...config.options?.plugins?.tooltip,
                    backgroundColor: isDarkMode ? '#1e293b' : '#ffffff',
                    titleFont: {
                        family: "'Manrope', sans-serif",
                        size: 13,
                        weight: 600,
                    },
                    bodyFont: {
                        family: "'Inter', sans-serif",
                        size: 12,
                    },
                    bodyColor: textColor,
                    titleColor: primaryColor,
                    borderColor: gridColor,
                    borderWidth: 1,
                    padding: 12,
                    displayColors: true,
                    callbacks: {
                        labelColor: (context) => ({
                            borderColor: context.dataset.borderColor || accentColor,
                            backgroundColor: context.dataset.backgroundColor || accentColor,
                        }),
                    },
                },
                datalabels: {
                    ...config.options?.plugins?.datalabels,
                    color: isDarkMode ? '#e2e8f0' : '#64748b',
                    font: {
                        family: "'JetBrains Mono', monospace",
                        weight: 600,
                        size: 11,
                    },
                },
            },
            scales: {
                ...config.options?.scales,
                x: {
                    ...config.options?.scales?.x,
                    ticks: {
                        ...config.options?.scales?.x?.ticks,
                        color: textColor,
                        font: {
                            family: "'Inter', sans-serif",
                            size: 11,
                        },
                    },
                    grid: {
                        ...config.options?.scales?.x?.grid,
                        color: gridColor,
                        drawBorder: false,
                    },
                },
                y: {
                    ...config.options?.scales?.y,
                    ticks: {
                        ...config.options?.scales?.y?.ticks,
                        color: textColor,
                        font: {
                            family: "'Inter', sans-serif",
                            size: 11,
                        },
                    },
                    grid: {
                        ...config.options?.scales?.y?.grid,
                        color: gridColor,
                        drawBorder: false,
                    },
                },
            },
        },
        data: {
            ...config.data,
            datasets: (config.data?.datasets || []).map((dataset, index) => ({
                ...dataset,
                borderColor: dataset.borderColor || accentColor,
                backgroundColor: dataset.backgroundColor || '#3b82f626',
                borderWidth: dataset.borderWidth ?? 2,
                tension: dataset.tension ?? 0.4,
                fill: dataset.fill ?? false,
                pointRadius: dataset.pointRadius ?? 4,
                pointHoverRadius: dataset.pointHoverRadius ?? 6,
                pointBackgroundColor: dataset.pointBackgroundColor || '#ffffff',
                pointBorderColor: dataset.pointBorderColor || accentColor,
                pointBorderWidth: dataset.pointBorderWidth ?? 2,
            })),
        },
    };
}

/**
 * Create a line chart
 */
export function createLineChart(canvasId, labels, datasets) {
    const element = document.getElementById(canvasId);
    if (!element) return null;

    const config = {
        type: 'line',
        data: {
            labels,
            datasets: datasets.map((dataset) => ({
                label: dataset.label,
                data: dataset.data,
                borderColor: dataset.color || '#3b82f6',
                backgroundColor: (dataset.color || '#3b82f6') + '26',
                ...dataset,
            })),
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: { display: true },
            },
        },
    };

    const mergedConfig = applyClinicalpStyle(config);
    return new Chart(element, mergedConfig);
}

/**
 * Create a bar chart
 */
export function createBarChart(canvasId, labels, datasets) {
    const element = document.getElementById(canvasId);
    if (!element) return null;

    const config = {
        type: 'bar',
        data: {
            labels,
            datasets: datasets.map((dataset) => ({
                label: dataset.label,
                data: dataset.data,
                backgroundColor: dataset.color || '#3b82f6',
                borderColor: dataset.borderColor || '#2563eb',
                borderWidth: 1,
                borderRadius: 4,
                ...dataset,
            })),
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: { display: true },
            },
        },
    };

    const mergedConfig = applyClinicalpStyle(config);
    return new Chart(element, mergedConfig);
}

/**
 * Listen for theme changes and update all charts
 */
export function watchThemeChanges() {
    window.addEventListener('themechange', () => {
        // In a real implementation, you'd want to update all existing charts
        // This is a simple approach that destroys and recreates them
        // For now, we'll just log the theme change
        console.log('Theme changed - charts will refresh on page reload');
    });
}

// Initialize on DOM ready
document.addEventListener('DOMContentLoaded', () => {
    initCharts();
    watchThemeChanges();
});
