/**
 * Dark Mode Module
 * Handles dark mode toggle with localStorage persistence and system preference detection
 */

export function initDarkMode() {
    const htmlElement = document.documentElement;
    const darkModeToggle = document.querySelector('[data-dark-mode-toggle]');
    const THEME_KEY = 'clinical-theme';
    const LIGHT_THEME = 'light';
    const DARK_THEME = 'dark';

    /**
     * Get the current theme preference
     * Priority: localStorage > system preference > light (default)
     */
    function getThemePreference() {
        const stored = localStorage.getItem(THEME_KEY);
        if (stored) {
            return stored;
        }

        // Check system preference
        if (window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches) {
            return DARK_THEME;
        }

        return LIGHT_THEME;
    }

    /**
     * Set the theme
     */
    function setTheme(theme) {
        const isDark = theme === DARK_THEME;

        if (isDark) {
            htmlElement.setAttribute('data-theme', DARK_THEME);
            htmlElement.classList.add('dark');
        } else {
            htmlElement.removeAttribute('data-theme');
            htmlElement.classList.remove('dark');
        }

        localStorage.setItem(THEME_KEY, theme);

        // Update toggle button state if it exists
        if (darkModeToggle) {
            darkModeToggle.setAttribute('aria-pressed', isDark);
            updateToggleIcon(isDark);
        }

        // Dispatch custom event for other components
        window.dispatchEvent(new CustomEvent('themechange', { detail: { theme } }));
    }

    /**
     * Toggle between light and dark theme
     */
    function toggleTheme() {
        const current = htmlElement.getAttribute('data-theme') || LIGHT_THEME;
        const next = current === DARK_THEME ? LIGHT_THEME : DARK_THEME;
        setTheme(next);
    }

    /**
     * Update toggle button icon
     */
    function updateToggleIcon(isDark) {
        const icon = darkModeToggle?.querySelector('i');
        if (!icon) return;

        if (isDark) {
            icon.classList.remove('fa-moon');
            icon.classList.add('fa-sun');
            darkModeToggle.title = 'Switch to light mode';
        } else {
            icon.classList.remove('fa-sun');
            icon.classList.add('fa-moon');
            darkModeToggle.title = 'Switch to dark mode';
        }
    }

    /**
     * Listen for system theme preference changes
     */
    function watchSystemPreference() {
        if (!window.matchMedia) return;

        const mediaQuery = window.matchMedia('(prefers-color-scheme: dark)');

        // Modern browsers: addEventListener
        if (mediaQuery.addEventListener) {
            mediaQuery.addEventListener('change', (e) => {
                const stored = localStorage.getItem(THEME_KEY);
                // Only apply system preference if user hasn't set a manual preference
                if (!stored) {
                    setTheme(e.matches ? DARK_THEME : LIGHT_THEME);
                }
            });
        }
    }

    // Initialize theme
    const theme = getThemePreference();
    setTheme(theme);

    // Add toggle event listener
    if (darkModeToggle) {
        darkModeToggle.addEventListener('click', toggleTheme);
    }

    // Watch for system preference changes
    watchSystemPreference();

    // Expose functions for external use
    return {
        toggleTheme,
        setTheme,
        getThemePreference,
    };
}

/**
 * Alpine.js component for dark mode toggle
 * Usage: <button x-data="darkModeComponent()">Toggle</button>
 */
export function darkModeComponent() {
    return {
        isDark: false,
        init() {
            this.isDark = document.documentElement.getAttribute('data-theme') === 'dark';
            window.addEventListener('themechange', (e) => {
                this.isDark = e.detail.theme === 'dark';
            });
        },
        toggle() {
            this.isDark = !this.isDark;
            const theme = this.isDark ? 'dark' : 'light';
            const htmlElement = document.documentElement;

            if (this.isDark) {
                htmlElement.setAttribute('data-theme', 'dark');
                htmlElement.classList.add('dark');
            } else {
                htmlElement.removeAttribute('data-theme');
                htmlElement.classList.remove('dark');
            }

            localStorage.setItem('clinical-theme', theme);
            window.dispatchEvent(new CustomEvent('themechange', { detail: { theme } }));
        },
    };
}
