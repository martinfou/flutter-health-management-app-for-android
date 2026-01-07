// API Configuration
const API_BASE_URL = 'https://healthapp.compica.com/api/v1';

// State Management
let accessToken = localStorage.getItem('access_token');
let refreshToken = localStorage.getItem('refresh_token');
let currentUser = null;

// Initialize App
document.addEventListener('DOMContentLoaded', () => {
    if (accessToken) {
        loadDashboard();
    } else {
        showLogin();
    }

    // Form Event Listeners
    document.getElementById('loginForm').addEventListener('submit', handleLogin);
    document.getElementById('registerForm').addEventListener('submit', handleRegister);
    document.getElementById('metricForm').addEventListener('submit', handleAddMetric);

    // Set today's date as default
    document.getElementById('metricDate').valueAsDate = new Date();

    // Initialize Google Sign-In
    initializeGoogleSignIn();
});

// Initialize Google Sign-In
function initializeGoogleSignIn() {
    if (typeof google !== 'undefined') {
        google.accounts.id.initialize({
            client_id: '741266813874-275q1r6aug39onitf95lepsh02msg2s7.apps.googleusercontent.com',
            callback: handleGoogleSignIn
        });
        google.accounts.id.renderButton(
            document.getElementById('googleSignInButton'),
            {
                theme: 'outline',
                size: 'large',
                width: 350,
                text: 'signin_with'
            }
        );
    } else {
        setTimeout(initializeGoogleSignIn, 100);
    }
}

// Handle Google Sign-In
async function handleGoogleSignIn(response) {
    try {
        const apiResponse = await fetch(`${API_BASE_URL}/auth/verify-google`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ id_token: response.credential })
        });

        const data = await apiResponse.json();

        if (apiResponse.ok && data.success) {
            accessToken = data.data.access_token;
            refreshToken = data.data.refresh_token;
            localStorage.setItem('access_token', accessToken);
            localStorage.setItem('refresh_token', refreshToken);
            loadDashboard();
        } else {
            const errorDiv = document.getElementById('loginError');
            showError(errorDiv, data.message || 'Google sign-in failed');
        }
    } catch (error) {
        const errorDiv = document.getElementById('loginError');
        showError(errorDiv, 'Network error. Please try again.');
    }
}

// Tab Switching
function switchTab(tab) {
    const loginForm = document.getElementById('loginForm');
    const registerForm = document.getElementById('registerForm');
    const tabs = document.querySelectorAll('.tab-btn');

    tabs.forEach(t => t.classList.remove('active'));

    if (tab === 'email') {
        loginForm.style.display = 'block';
        registerForm.style.display = 'none';
        tabs[0].classList.add('active');
    } else {
        loginForm.style.display = 'none';
        registerForm.style.display = 'block';
        tabs[1].classList.add('active');
    }
}

// Authentication Functions
async function handleLogin(e) {
    e.preventDefault();
    const email = document.getElementById('loginEmail').value;
    const password = document.getElementById('loginPassword').value;
    const errorDiv = document.getElementById('loginError');

    try {
        const response = await fetch(`${API_BASE_URL}/auth/login`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ email, password })
        });

        const data = await response.json();

        if (response.ok && data.success) {
            accessToken = data.data.access_token;
            refreshToken = data.data.refresh_token;
            localStorage.setItem('access_token', accessToken);
            localStorage.setItem('refresh_token', refreshToken);
            loadDashboard();
        } else {
            showError(errorDiv, data.message || 'Login failed');
        }
    } catch (error) {
        showError(errorDiv, 'Network error. Please try again.');
    }
}

async function handleRegister(e) {
    e.preventDefault();
    const name = document.getElementById('registerName').value;
    const email = document.getElementById('registerEmail').value;
    const password = document.getElementById('registerPassword').value;
    const errorDiv = document.getElementById('registerError');

    if (password.length < 8) {
        showError(errorDiv, 'Password must be at least 8 characters');
        return;
    }

    try {
        const response = await fetch(`${API_BASE_URL}/auth/register`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ email, password, name })
        });

        const data = await response.json();

        if (response.ok && data.success) {
            accessToken = data.data.access_token;
            refreshToken = data.data.refresh_token;
            localStorage.setItem('access_token', accessToken);
            localStorage.setItem('refresh_token', refreshToken);
            loadDashboard();
        } else {
            showError(errorDiv, data.message || 'Registration failed');
        }
    } catch (error) {
        showError(errorDiv, 'Network error. Please try again.');
    }
}

function logout() {
    localStorage.removeItem('access_token');
    localStorage.removeItem('refresh_token');
    accessToken = null;
    refreshToken = null;
    currentUser = null;
    showLogin();
}

// Screen Management
function showLogin() {
    document.getElementById('loginScreen').style.display = 'flex';
    document.getElementById('dashboardScreen').style.display = 'none';
}

function showDashboard() {
    document.getElementById('loginScreen').style.display = 'none';
    document.getElementById('dashboardScreen').style.display = 'block';
}

// Dashboard Functions
async function loadDashboard() {
    showDashboard();
    await loadProfile();
    await loadMetrics();
}

async function loadProfile() {
    const profileDiv = document.getElementById('profileInfo');
    profileDiv.innerHTML = '<div class="loading">Loading profile...</div>';

    // Validate token exists
    if (!accessToken) {
        logout();
        return;
    }

    try {
        const response = await fetch(`${API_BASE_URL}/user/profile`, {
            headers: {
                'Authorization': `Bearer ${accessToken}`
            }
        });

        const data = await response.json();

        if (response.ok && data.success) {
            currentUser = data.data;
            displayProfile(data.data);
            document.getElementById('userEmail').textContent = data.data.email;
        } else if (response.status === 401) {
            // Token expired or invalid - clear and show login
            console.log('Token invalid or expired, logging out');
            logout();
        } else {
            profileDiv.innerHTML = '<div class="error-message show">Failed to load profile</div>';
        }
    } catch (error) {
        console.error('Profile load error:', error);
        profileDiv.innerHTML = '<div class="error-message show">Network error</div>';
    }
}

function displayProfile(user) {
    const profileDiv = document.getElementById('profileInfo');
    profileDiv.innerHTML = `
        <div class="profile-item">
            <label>Name</label>
            <div class="value">${user.name || 'Not set'}</div>
        </div>
        <div class="profile-item">
            <label>Email</label>
            <div class="value">${user.email}</div>
        </div>
        <div class="profile-item">
            <label>Account Type</label>
            <div class="value">${user.id ? (user.id.includes('google') ? 'Google' : 'Email') : 'Email'}</div>
        </div>
    `;
}

async function loadMetrics() {
    const metricsDiv = document.getElementById('metricsTable');
    metricsDiv.innerHTML = '<div class="loading">Loading health metrics...</div>';

    try {
        const response = await fetch(`${API_BASE_URL}/health-metrics`, {
            headers: {
                'Authorization': `Bearer ${accessToken}`
            }
        });

        const data = await response.json();

        if (response.ok && data.success) {
            displayMetrics(data.data || []);
        } else {
            metricsDiv.innerHTML = '<div class="error-message show">Failed to load metrics</div>';
        }
    } catch (error) {
        metricsDiv.innerHTML = '<div class="error-message show">Network error</div>';
    }
}

function displayMetrics(metrics) {
    const metricsDiv = document.getElementById('metricsTable');

    if (!metrics || metrics.length === 0) {
        metricsDiv.innerHTML = `
            <div class="empty-state">
                <div class="empty-state-icon">📊</div>
                <p>No health metrics yet. Click "Add Metric" to get started!</p>
            </div>
        `;
        return;
    }

    // Sort metrics by date (newest first)
    metrics.sort((a, b) => new Date(b.date) - new Date(a.date));

    const metricsHTML = metrics.map(metric => `
        <div class="metric-card">
            <div class="metric-date">📅 ${formatDate(metric.date)}</div>
            <div class="metric-details">
                ${metric.weight_kg ? `
                    <div class="metric-detail">
                        <label>Weight</label>
                        <div class="value">${metric.weight_kg} kg</div>
                    </div>
                ` : ''}
                ${metric.sleep_hours ? `
                    <div class="metric-detail">
                        <label>Sleep</label>
                        <div class="value">${metric.sleep_hours} hrs</div>
                    </div>
                ` : ''}
                ${metric.steps ? `
                    <div class="metric-detail">
                        <label>Steps</label>
                        <div class="value">${metric.steps.toLocaleString()}</div>
                    </div>
                ` : ''}
                ${metric.sleep_quality ? `
                    <div class="metric-detail">
                        <label>Sleep Quality</label>
                        <div class="value">${metric.sleep_quality}/10</div>
                    </div>
                ` : ''}
                ${metric.energy_level ? `
                    <div class="metric-detail">
                        <label>Energy</label>
                        <div class="value">${metric.energy_level}/10</div>
                    </div>
                ` : ''}
            </div>
            ${metric.notes ? `<div class="metric-notes">"${metric.notes}"</div>` : ''}
        </div>
    `).join('');

    metricsDiv.innerHTML = `<div class="metrics-grid">${metricsHTML}</div>`;
}

// Add Metric Functions
function showAddMetricForm() {
    document.getElementById('addMetricForm').style.display = 'block';
    document.getElementById('metricDate').focus();
}

function hideAddMetricForm() {
    document.getElementById('addMetricForm').style.display = 'none';
    document.getElementById('metricForm').reset();
    document.getElementById('metricDate').valueAsDate = new Date();
    document.getElementById('metricError').classList.remove('show');
}

async function handleAddMetric(e) {
    e.preventDefault();
    const errorDiv = document.getElementById('metricError');

    const metricData = {
        date: document.getElementById('metricDate').value,
        weight_kg: parseFloat(document.getElementById('metricWeight').value) || null,
        sleep_hours: parseFloat(document.getElementById('metricSleep').value) || null,
        steps: parseInt(document.getElementById('metricSteps').value) || null,
        sleep_quality: parseInt(document.getElementById('metricSleepQuality').value) || null,
        energy_level: parseInt(document.getElementById('metricEnergy').value) || null,
        notes: document.getElementById('metricNotes').value || null
    };

    // Remove null values
    Object.keys(metricData).forEach(key => {
        if (metricData[key] === null && key !== 'notes') {
            delete metricData[key];
        }
    });

    try {
        const response = await fetch(`${API_BASE_URL}/health-metrics`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${accessToken}`
            },
            body: JSON.stringify(metricData)
        });

        const data = await response.json();

        if (response.ok && data.success) {
            hideAddMetricForm();
            await loadMetrics();
        } else {
            showError(errorDiv, data.message || 'Failed to add metric');
        }
    } catch (error) {
        showError(errorDiv, 'Network error. Please try again.');
    }
}

// Utility Functions
function showError(element, message) {
    element.textContent = message;
    element.classList.add('show');
    setTimeout(() => {
        element.classList.remove('show');
    }, 5000);
}

function formatDate(dateString) {
    const date = new Date(dateString);
    const options = { weekday: 'short', year: 'numeric', month: 'short', day: 'numeric' };
    return date.toLocaleDateString('en-US', options);
}
