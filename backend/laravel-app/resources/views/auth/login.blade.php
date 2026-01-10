@extends('layouts.app')

@section('content')
<div class="container">
    <div class="row justify-content-center">
        <div class="col-md-6">
            <div class="card shadow mt-5">
                <div class="card-body p-5">
                    <h1 class="text-center mb-4">
                        <i class="fas fa-heartbeat text-primary"></i>
                        Health Management
                    </h1>
                    <p class="text-center text-muted mb-4">
                        Track your health, manage your wellness
                    </p>

                    @if (session('error'))
                        <div class="alert alert-danger">
                            {{ session('error') }}
                        </div>
                    @endif

                    <!-- Google Sign-In Button -->
                    <div class="d-grid gap-2 mb-3">
                        <a href="{{ route('google.login') }}" class="btn btn-outline-danger btn-lg">
                            <i class="fab fa-google me-2"></i>
                            Sign in with Google
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
@endsection
