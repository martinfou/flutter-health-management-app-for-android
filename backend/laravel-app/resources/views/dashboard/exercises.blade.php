@extends('layouts.app')

@section('content')
<div class="container">
    <h2><i class="fas fa-dumbbell"></i> Exercises</h2>

    <div class="card">
        <div class="card-body">
            @if($exercises->count() > 0)
                <div class="table-responsive">
                    <table class="table table-striped">
                        <thead>
                            <tr>
                                <th>Date</th>
                                <th>Name</th>
                                <th>Type</th>
                                <th>Duration</th>
                                <th>Calories</th>
                            </tr>
                        </thead>
                        <tbody>
                            @foreach($exercises as $exercise)
                            <tr>
                                <td>{{ $exercise->date ? $exercise->date->format('M d, Y') : '-' }}</td>
                                <td>{{ $exercise->name }}</td>
                                <td><span class="badge bg-info">{{ $exercise->type }}</span></td>
                                <td>{{ $exercise->duration_minutes ? $exercise->duration_minutes . ' min' : '-' }}</td>
                                <td>{{ $exercise->calories_burned ?? '-' }}</td>
                            </tr>
                            @endforeach
                        </tbody>
                    </table>
                </div>

                {{ $exercises->links() }}
            @else
                <p class="text-center text-muted">No exercises logged yet.</p>
            @endif
        </div>
    </div>
</div>
@endsection
