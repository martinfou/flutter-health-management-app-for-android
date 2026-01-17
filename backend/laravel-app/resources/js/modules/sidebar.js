/**
 * Sidebar Module
 * Handles collapsible sidebar toggle and mobile drawer behavior
 */

export function initSidebar() {
    const sidebar = document.querySelector('[data-sidebar]');
    const toggleBtn = document.querySelector('[data-sidebar-toggle]');
    const overlay = document.querySelector('[data-sidebar-overlay]');
    const SIDEBAR_STATE_KEY = 'clinical-sidebar-state';
    const EXPANDED_STATE = 'expanded';
    const COLLAPSED_STATE = 'collapsed';

    if (!sidebar) return null;

    /**
     * Get sidebar state preference from localStorage
     */
    function getSidebarState() {
        return localStorage.getItem(SIDEBAR_STATE_KEY) || EXPANDED_STATE;
    }

    /**
     * Set sidebar state
     */
    function setSidebarState(state) {
        localStorage.setItem(SIDEBAR_STATE_KEY, state);

        if (state === COLLAPSED_STATE) {
            sidebar.classList.add('sidebar-collapsed');
        } else {
            sidebar.classList.remove('sidebar-collapsed');
        }

        // Dispatch custom event
        window.dispatchEvent(new CustomEvent('sidebarchange', { detail: { state } }));
    }

    /**
     * Toggle sidebar
     */
    function toggleSidebar() {
        const isCollapsed = sidebar.classList.contains('sidebar-collapsed');
        setSidebarState(isCollapsed ? EXPANDED_STATE : COLLAPSED_STATE);
    }

    /**
     * Close sidebar (for mobile)
     */
    function closeSidebar() {
        sidebar.classList.remove('sidebar-open');
    }

    /**
     * Open sidebar (for mobile)
     */
    function openSidebar() {
        sidebar.classList.add('sidebar-open');
    }

    // Initialize sidebar state from localStorage
    const initialState = getSidebarState();
    setSidebarState(initialState);

    // Add toggle button event listener
    if (toggleBtn) {
        toggleBtn.addEventListener('click', toggleSidebar);
    }

    // Close sidebar on overlay click (mobile)
    if (overlay) {
        overlay.addEventListener('click', closeSidebar);
    }

    // Close sidebar when clicking on nav links (mobile)
    const navLinks = sidebar.querySelectorAll('a');
    navLinks.forEach((link) => {
        link.addEventListener('click', () => {
            if (window.innerWidth < 768) {
                closeSidebar();
            }
        });
    });

    // Handle window resize
    window.addEventListener('resize', () => {
        if (window.innerWidth >= 768) {
            closeSidebar();
        }
    });

    // Expose functions for external use
    return {
        toggle: toggleSidebar,
        open: openSidebar,
        close: closeSidebar,
        getSidebarState,
        setSidebarState,
    };
}

/**
 * Alpine.js component for sidebar toggle
 */
export function sidebarComponent() {
    return {
        isCollapsed: false,
        isMobileOpen: false,
        init() {
            const stored = localStorage.getItem('clinical-sidebar-state');
            this.isCollapsed = stored === 'collapsed';
        },
        toggle() {
            this.isCollapsed = !this.isCollapsed;
            localStorage.setItem('clinical-sidebar-state', this.isCollapsed ? 'collapsed' : 'expanded');
        },
        toggleMobile() {
            this.isMobileOpen = !this.isMobileOpen;
        },
        closeMobile() {
            this.isMobileOpen = false;
        },
    };
}
