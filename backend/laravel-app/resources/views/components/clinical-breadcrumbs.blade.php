<!-- Clinical Pro Breadcrumbs Component -->
@if($items && count($items) > 0)
<nav aria-label="breadcrumb" class="clinical-breadcrumbs mb-3">
    <ol class="breadcrumb">
        @foreach($items as $key => $item)
            @if($item['url'] ?? null)
                <li class="breadcrumb-item">
                    <a href="{{ $item['url'] }}">
                        @if($item['icon'] ?? null)
                            <i class="fas fa-{{ $item['icon'] }} me-1"></i>
                        @endif
                        {{ $item['label'] }}
                    </a>
                </li>
            @else
                <li class="breadcrumb-item active" aria-current="page">
                    @if($item['icon'] ?? null)
                        <i class="fas fa-{{ $item['icon'] }} me-1"></i>
                    @endif
                    {{ $item['label'] }}
                </li>
            @endif
        @endforeach
    </ol>
</nav>
@endif

<style>
/* Clinical Pro Breadcrumbs Styles */
.clinical-breadcrumbs {
    padding: 0.5rem 0;
}

.breadcrumb {
    background-color: transparent;
    padding: 0;
    margin: 0;
    flex-wrap: wrap;
    gap: 0;
}

.breadcrumb-item {
    font-size: 0.9375rem;
    color: #64748b;
}

.breadcrumb-item + .breadcrumb-item::before {
    display: inline-block;
    padding: 0 0.5rem;
    color: #cbd5e1;
    content: '/';
}

.breadcrumb-item a {
    color: #3b82f6;
    text-decoration: none;
    transition: color 0.15s cubic-bezier(0.4, 0, 0.2, 1);
}

.breadcrumb-item a:hover {
    color: #2563eb;
    text-decoration: underline;
}

.breadcrumb-item.active {
    color: #1e293b;
    font-weight: 500;
}

.breadcrumb-item i {
    margin-right: 0.25rem;
    font-size: 0.875rem;
}

/* Dark Mode */
@media (prefers-color-scheme: dark),
[data-theme="dark"] {
    .breadcrumb-item {
        color: #94a3b8;
    }

    .breadcrumb-item + .breadcrumb-item::before {
        color: #475569;
    }

    .breadcrumb-item a {
        color: #60a5fa;
    }

    .breadcrumb-item a:hover {
        color: #93c5fd;
    }

    .breadcrumb-item.active {
        color: #f1f5f9;
    }
}
</style>
