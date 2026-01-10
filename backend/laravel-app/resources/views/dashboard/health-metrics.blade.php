@extends('layouts.app')

@section('content')
<div class="container">
    <h2><i class="fas fa-chart-line"></i> Health Metrics</h2>

    <div class="card">
        <div class="card-body">
            @if($metrics->count() > 0)
                <div class="table-responsive">
                    <table class="table table-striped">
                        <thead>
                            <tr>
                                <th>Date</th>
                                <th>Weight (kg)</th>
                                <th>Sleep (hrs)</th>
                                <th>Steps</th>
                                <th>Mood</th>
                            </tr>
                        </thead>
                        <tbody>
                            @foreach($metrics as $metric)
                            <tr>
                                <td>{{ $metric->date->format('M d, Y') }}</td>
                                <td>{{ $metric->weight_kg ?? '-' }}</td>
                                <td>{{ $metric->sleep_hours ?? '-' }}</td>
                                <td>{{ $metric->steps ? number_format($metric->steps) : '-' }}</td>
                                <td>{{ $metric->mood ?? '-' }}</td>
                            </tr>
                            @endforeach
                        </tbody>
                    </table>
                </div>

                {{ $metrics->links() }}
            @else
                <p class="text-center text-muted">No health metrics found.</p>
            @endif
        </div>
    </div>
</div>
@endsection
