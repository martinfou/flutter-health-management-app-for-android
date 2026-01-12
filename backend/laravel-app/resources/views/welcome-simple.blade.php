<!DOCTYPE html>
<html>
<head>
    <title>Health Management App</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif; margin: 0; padding: 0; background: #f5f5f5; }
        .container { max-width: 800px; margin: 0 auto; padding: 40px 20px; }
        .header { text-align: center; margin-bottom: 40px; }
        h1 { color: #333; margin: 0 0 10px 0; }
        .subtitle { color: #666; margin: 0; }
        .features { display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 20px; margin: 40px 0; }
        .feature { background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .feature h3 { margin: 0 0 10px 0; color: #333; }
        .feature p { margin: 0; color: #666; font-size: 14px; }
        .buttons { display: grid; grid-template-columns: 1fr 1fr; gap: 10px; margin: 40px 0; }
        a { display: block; padding: 12px 20px; text-align: center; border-radius: 4px; text-decoration: none; font-weight: 500; transition: all 0.3s; }
        .btn-primary { background: #007bff; color: white; }
        .btn-primary:hover { background: #0056b3; }
        .btn-outline { border: 2px solid #007bff; color: #007bff; }
        .btn-outline:hover { background: #007bff; color: white; }
        .api-status { text-align: center; margin: 30px 0; padding: 20px; background: white; border-radius: 8px; }
        .status-badge { display: inline-block; background: #28a745; color: white; padding: 5px 15px; border-radius: 20px; font-size: 14px; }
        code { background: #f4f4f4; padding: 2px 6px; border-radius: 3px; font-family: 'Courier New', monospace; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>❤️ Health Management App</h1>
            <p class="subtitle">Track your health, manage your wellness</p>
        </div>

        <div class="features">
            <div class="feature">
                <h3>🍽️ Nutrition</h3>
                <p>Track meals, calories, and nutrients to maintain a healthy diet.</p>
            </div>
            <div class="feature">
                <h3>💪 Exercise</h3>
                <p>Log workouts and track your fitness progress over time.</p>
            </div>
            <div class="feature">
                <h3>❤️ Health Metrics</h3>
                <p>Monitor vital signs and track your health data.</p>
            </div>
            <div class="feature">
                <h3>💊 Medications</h3>
                <p>Manage prescriptions and set medication reminders.</p>
            </div>
        </div>

        <div class="api-status">
            <p><strong>API Status:</strong> <span class="status-badge">Operational</span></p>
            <p style="color: #666; font-size: 14px;">Check <code>/api/v1/health</code> for API health status</p>
        </div>

        <div class="buttons">
            <a href="/login" class="btn-primary">Sign In</a>
            <a href="/register" class="btn-outline">Create Account</a>
        </div>

        <div style="text-align: center; color: #999; font-size: 13px; margin-top: 40px;">
            <p>🔒 Your data is secure and encrypted</p>
            <p style="margin-top: 10px;">
                <a href="/api/v1" style="color: #007bff; text-decoration: none;">API Documentation</a> •
                <a href="/dashboard" style="color: #007bff; text-decoration: none;">Dashboard</a>
            </p>
        </div>
    </div>
</body>
</html>
