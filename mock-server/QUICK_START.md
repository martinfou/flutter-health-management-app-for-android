# Quick Start Guide

## 1. Install Dependencies

```bash
cd mock-server
npm install
```

## 2. Start the Server

```bash
npm start
```

Or use the start script:
```bash
./start.sh
```

The server will start on `http://localhost:3000`

## 3. Test the Server

Open your browser and visit:
```
http://localhost:3000/health
```

You should see:
```json
{
  "status": "ok",
  "message": "Mock API server is running"
}
```

## 4. Update Flutter App

The Flutter app is already configured to use:
- **Android Emulator**: `http://10.0.2.2:3000/api` ✅ (already set)
- **iOS Simulator**: Change to `http://localhost:3000/api`
- **Physical Device**: Use your computer's IP (e.g., `http://192.168.1.100:3000/api`)

To change the URL, edit:
```
app/lib/core/network/authentication_service.dart
```

Change line:
```dart
static const String _baseUrl = 'http://10.0.2.2:3000/api';
```

## 5. Test Authentication Flow

1. Start the mock server
2. Run your Flutter app
3. Try registering a new user
4. Try logging in
5. Check your profile

## Troubleshooting

### Port 3000 Already in Use

Edit `server.js` and change:
```javascript
const PORT = 3000; // Change to another port
```

### Android Emulator Can't Connect

Make sure you're using `10.0.2.2` (not `localhost`) for Android emulator.

### iOS Simulator Can't Connect

Use `localhost` (not `10.0.2.2`) for iOS simulator.

### Physical Device Can't Connect

1. Find your computer's IP address:
   - Mac/Linux: `ifconfig` or `ip addr`
   - Windows: `ipconfig`
2. Make sure your device and computer are on the same network
3. Update the base URL in `authentication_service.dart` to use your IP


