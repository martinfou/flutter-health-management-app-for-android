@extends('layouts.app')

@section('content')
<div class="container">
    <h2><i class="fas fa-user"></i> Profile</h2>

    <div class="card">
        <div class="card-body">
            <div class="row">
                <div class="col-md-6">
                    <h5>Account Information</h5>
                    <p><strong>Name:</strong> {{ $user->name ?? 'Not set' }}</p>
                    <p><strong>Email:</strong> {{ $user->email }}</p>
                    <p><strong>Authentication:</strong>
                        @if($user->google_id)
                            <span class="badge bg-danger">Google OAuth</span>
                        @else
                            <span class="badge bg-primary">Email/Password</span>
                        @endif
                    </p>
                </div>
                <div class="col-md-6">
                    <h5>Health Profile</h5>
                    <p><strong>Height:</strong> {{ $user->height_cm ? $user->height_cm . ' cm' : 'Not set' }}</p>
                    <p><strong>Weight:</strong> {{ $user->weight_kg ? $user->weight_kg . ' kg' : 'Not set' }}</p>
                    <p><strong>Activity Level:</strong> {{ $user->activity_level ?? 'Not set' }}</p>
                </div>
            </div>
        </div>
    </div>
</div>
@endsection
