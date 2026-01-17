<!-- Clinical Pro KPI Bar Component -->
<div class="clinical-kpi-bar">
    @foreach($metrics as $metric)
        <div class="kpi-card">
            <!-- KPI Icon/Label -->
            <div class="kpi-icon">
                @if($metric['icon'] ?? null)
                    <i class="fas fa-{{ $metric['icon'] }}"></i>
                @endif
            </div>

            <!-- KPI Content -->
            <div class="kpi-content">
                <div class="kpi-label">{{ $metric['label'] }}</div>
                <div class="kpi-value">
                    <span class="value-number">{{ $metric['value'] }}</span>
                    @if($metric['unit'] ?? null)
                        <span class="value-unit">{{ $metric['unit'] }}</span>
                    @endif
                </div>

                <!-- KPI Trend (optional) -->
                @if($metric['trend'] ?? null)
                    <div class="kpi-trend trend-{{ $metric['trend'] > 0 ? 'up' : 'down' }}">
                        <i class="fas fa-arrow-{{ $metric['trend'] > 0 ? 'up' : 'down' }}"></i>
                        <span>{{ abs($metric['trend']) }}%</span>
                    </div>
                @endif
            </div>

            <!-- KPI Sparkline (optional) -->
            @if($metric['sparkline'] ?? null)
                <div class="kpi-sparkline">
                    <svg class="sparkline-svg" width="60" height="30" viewBox="0 0 60 30">
                        <!-- Simple line path - would be generated dynamically -->
                        <polyline points="{{ $metric['sparkline'] }}"
                                  fill="none"
                                  stroke="currentColor"
                                  stroke-width="2"
                                  vector-effect="non-scaling-stroke" />
                    </svg>
                </div>
            @endif
        </div>
    @endforeach
</div>

<style>
/* Clinical Pro KPI Bar Styles */
.clinical-kpi-bar {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
    gap: 1rem;
    padding: 1.5rem;
    background: var(--bs-body-bg);
    border: 1px solid var(--bs-border-color);
    border-radius: 0.5rem;
    margin-bottom: 1.5rem;
}

.kpi-card {
    display: flex;
    align-items: center;
    gap: 1rem;
    padding: 1rem;
    background: var(--bs-body-bg);
    border: 1px solid var(--bs-border-color);
    border-radius: 0.5rem;
    transition: all 0.15s cubic-bezier(0.4, 0, 0.2, 1);
}

.kpi-card:hover {
    border-color: #3b82f6;
    box-shadow: 0 4px 6px -1px rgba(59, 130, 246, 0.1);
}

.kpi-icon {
    display: flex;
    align-items: center;
    justify-content: center;
    width: 48px;
    height: 48px;
    background: linear-gradient(135deg, #3b82f6, #2563eb);
    color: #ffffff;
    border-radius: 0.5rem;
    font-size: 1.5rem;
    flex-shrink: 0;
}

.kpi-content {
    flex: 1;
    min-width: 0;
}

.kpi-label {
    font-size: 0.875rem;
    color: #64748b;
    font-weight: 500;
    text-transform: uppercase;
    letter-spacing: 0.025em;
    margin-bottom: 0.25rem;
}

.kpi-value {
    display: flex;
    align-items: baseline;
    gap: 0.5rem;
}

.value-number {
    font-family: 'JetBrains Mono', monospace;
    font-size: 1.5rem;
    font-weight: 700;
    color: #1e293b;
}

.value-unit {
    font-size: 0.875rem;
    color: #64748b;
    font-weight: 500;
}

.kpi-trend {
    display: inline-flex;
    align-items: center;
    gap: 0.25rem;
    font-size: 0.75rem;
    font-weight: 600;
    margin-top: 0.5rem;
    padding: 0.25rem 0.5rem;
    border-radius: 0.25rem;
}

.kpi-trend.trend-up {
    background: #d1fae5;
    color: #10b981;
}

.kpi-trend.trend-down {
    background: #fee2e2;
    color: #ef4444;
}

.kpi-trend i {
    font-size: 0.625rem;
}

.kpi-sparkline {
    display: flex;
    align-items: center;
    justify-content: center;
    width: 60px;
    height: 30px;
    color: #3b82f6;
    flex-shrink: 0;
}

.sparkline-svg {
    width: 100%;
    height: 100%;
}

/* Responsive */
@media (max-width: 992px) {
    .clinical-kpi-bar {
        grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
    }

    .kpi-card {
        flex-direction: column;
        align-items: flex-start;
    }

    .kpi-sparkline {
        display: none;
    }
}

@media (max-width: 768px) {
    .clinical-kpi-bar {
        grid-template-columns: repeat(2, 1fr);
        gap: 0.75rem;
        padding: 1rem;
    }

    .kpi-card {
        padding: 0.75rem;
    }

    .kpi-icon {
        width: 40px;
        height: 40px;
        font-size: 1.125rem;
    }

    .value-number {
        font-size: 1.25rem;
    }
}

/* Dark Mode */
@media (prefers-color-scheme: dark),
[data-theme="dark"] {
    .clinical-kpi-bar {
        background: #1e293b;
        border-color: #334155;
    }

    .kpi-card {
        background: #1e293b;
        border-color: #334155;
    }

    .kpi-card:hover {
        border-color: #60a5fa;
        box-shadow: 0 4px 6px -1px rgba(96, 165, 250, 0.2);
    }

    .kpi-label {
        color: #cbd5e1;
    }

    .value-number {
        color: #ffffff;
    }

    .value-unit {
        color: #94a3b8;
    }

    .kpi-trend.trend-up {
        background: #064e3b;
        color: #a7f3d0;
    }

    .kpi-trend.trend-down {
        background: #7f1d1d;
        color: #fca5a5;
    }

    .kpi-sparkline {
        color: #60a5fa;
    }
}
</style>
