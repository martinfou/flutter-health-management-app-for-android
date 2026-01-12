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

                    <!-- Email/Password Login Form -->
                    <form method="POST" action="{{ route('login') }}" class="mb-4">
                        @csrf

                        <div class="mb-3">
                            <label for="email" class="form-label">Email Address</label>
                            <input type="email" class="form-control @error('email') is-invalid @enderror"
                                   id="email" name="email" value="{{ old('email') }}" required autofocus>
                            @error('email')
                                <div class="invalid-feedback">{{ $message }}</div>
                            @enderror
                        </div>

                        <div class="mb-3">
                            <label for="password" class="form-label">Password</label>
                            <input type="password" class="form-control @error('password') is-invalid @enderror"
                                   id="password" name="password" required>
                            @error('password')
                                <div class="invalid-feedback">{{ $message }}</div>
                            @enderror
                        </div>

                        <button type="submit" class="btn btn-primary w-100 mb-3">
                            Sign In
                        </button>
                    </form>

                    <div class="text-center mb-3">
                        <small class="text-muted">or continue with</small>
                    </div>

                    <!-- Google Sign-In Button -->
                    <div class="d-grid gap-2 mb-3">
                        <a href="{{ route('google.login') }}" class="btn btn-outline-danger btn-lg">
                            <i class="fab fa-google me-2"></i>
                            Sign in with Google
                        </a>
                    </div>

                    <!-- Register Link -->
                    <p class="text-center mt-4">
                        Don't have an account? <a href="{{ route('register') }}">Register here</a>
                    </p>
                </div>
            </div>
        </div>
    </div>
</div>
@endsection
