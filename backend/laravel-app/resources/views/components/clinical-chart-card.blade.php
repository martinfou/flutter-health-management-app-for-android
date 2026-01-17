<!-- Clinical Pro Chart Card Component -->
<div class="clinical-chart-card">
    <!-- Card Header -->
    <div class="chart-card-header">
        <div class="chart-card-title">
            <h3 class="mb-0">{{ $title }}</h3>
            @if($subtitle ?? null)
                <p class="text-muted mb-0">{{ $subtitle }}</p>
            @endif
        </div>
        @if($actions ?? null)
            <div class="chart-card-actions">
                {{ $actions }}
            </div>
        @endif
    </div>

    <!-- Card Body with Chart -->
    <div class="chart-card-body">
        @if($chart_id ?? null)
            <canvas id="{{ $chart_id }}"
                    class="clinical-chart"
                    data-chart="{{ json_encode($chart_config ?? []) }}"></canvas>
        @else
            {{ $slot }}
        @endif
    </div>

    <!-- Card Footer (optional) -->
    @if($footer ?? null)
        <div class="chart-card-footer">
            {{ $footer }}
        </div>
    @endif
</div>

<style>
/* Clinical Pro Chart Card Styles */
.clinical-chart-card {
    background: var(--bs-body-bg);
    border: 1px solid var(--bs-border-color);
    border-radius: 0.5rem;
    box-shadow: 0 1px 2px 0 rgba(0, 0, 0, 0.05);
    display: flex;
    flex-direction: column;
    height: 100%;
    overflow: hidden;
    transition: box-shadow 0.15s cubic-bezier(0.4, 0, 0.2, 1);
}

.clinical-chart-card:hover {
    box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
}

.chart-card-header {
    padding: 1.5rem;
    border-bottom: 1px solid var(--bs-border-color);
    display: flex;
    justify-content: space-between;
    align-items: flex-start;
}

.chart-card-title h3 {
    font-size: 1.125rem;
    font-weight: 700;
    color: #1e293b;
    margin-bottom: 0.25rem;
}

.chart-card-title p {
    font-size: 0.875rem;
    color: #64748b;
}

.chart-card-actions {
    display: flex;
    gap: 0.5rem;
}

.chart-card-actions button,
.chart-card-actions a {
    padding: 0.5rem 0.75rem;
    font-size: 0.875rem;
    border-radius: 0.375rem;
    border: 1px solid var(--bs-border-color);
    background: transparent;
    color: #64748b;
    cursor: pointer;
    transition: all 0.15s cubic-bezier(0.4, 0, 0.2, 1);
}

.chart-card-actions button:hover,
.chart-card-actions a:hover {
    background: #f1f5f9;
    color: #1e293b;
}

.chart-card-body {
    flex: 1;
    padding: 1.5rem;
    min-height: 300px;
    display: flex;
    align-items: center;
    justify-content: center;
    position: relative;
}

.clinical-chart {
    width: 100%;
    height: 100%;
    max-height: 400px;
}

.chart-card-footer {
    padding: 1rem 1.5rem;
    border-top: 1px solid var(--bs-border-color);
    background: #f8fafc;
    font-size: 0.875rem;
    color: #64748b;
}

/* Responsive */
@media (max-width: 768px) {
    .chart-card-header {
        flex-direction: column;
        gap: 1rem;
    }

    .chart-card-actions {
        width: 100%;
    }

    .chart-card-body {
        min-height: 250px;
        padding: 1rem;
    }
}

/* Dark Mode */
@media (prefers-color-scheme: dark),
[data-theme="dark"] {
    .clinical-chart-card {
        background: #1e293b;
        border-color: #334155;
    }

    .clinical-chart-card:hover {
        box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.3);
    }

    .chart-card-header {
        border-bottom-color: #334155;
    }

    .chart-card-title h3 {
        color: #ffffff;
    }

    .chart-card-title p {
        color: #cbd5e1;
    }

    .chart-card-actions button,
    .chart-card-actions a {
        border-color: #334155;
        color: #cbd5e1;
    }

    .chart-card-actions button:hover,
    .chart-card-actions a:hover {
        background: #334155;
        color: #ffffff;
    }

    .chart-card-footer {
        border-top-color: #334155;
        background: #0f172a;
        color: #cbd5e1;
    }
}
</style>
