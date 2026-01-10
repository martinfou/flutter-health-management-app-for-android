@extends('layouts.app')

@section('content')
<div class="container">
    <h2><i class="fas fa-utensils"></i> Meals</h2>

    <div class="card">
        <div class="card-body">
            @if($meals->count() > 0)
                <div class="table-responsive">
                    <table class="table table-striped">
                        <thead>
                            <tr>
                                <th>Date</th>
                                <th>Name</th>
                                <th>Type</th>
                                <th>Calories</th>
                                <th>Protein (g)</th>
                            </tr>
                        </thead>
                        <tbody>
                            @foreach($meals as $meal)
                            <tr>
                                <td>{{ $meal->date->format('M d, Y') }}</td>
                                <td>{{ $meal->name }}</td>
                                <td><span class="badge bg-secondary">{{ $meal->meal_type }}</span></td>
                                <td>{{ $meal->calories ?? '-' }}</td>
                                <td>{{ $meal->protein_g ?? '-' }}</td>
                            </tr>
                            @endforeach
                        </tbody>
                    </table>
                </div>

                {{ $meals->links() }}
            @else
                <p class="text-center text-muted">No meals logged yet.</p>
            @endif
        </div>
    </div>
</div>
@endsection
