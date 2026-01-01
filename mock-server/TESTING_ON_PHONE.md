# Testing on Physical Phone

## Prerequisites

1. **Same WiFi Network**: Your Mac and phone must be on the same WiFi network
2. **Firewall**: Make sure your Mac's firewall allows incoming connections on port 3000

## Step 1: Find Your Mac's IP Address

### Method 1: Using Terminal (Recommended)

```bash
ifconfig | grep "inet " | grep -v 127.0.0.1
```

Look for the IP address that starts with `192.168.` or `10.` (usually `192.168.1.x` or `192.168.0.x`)

### Method 2: Using System Settings

1. Open **System Settings** (or **System Preferences** on older macOS)
2. Go to **Network**
3. Select your WiFi connection
4. Your IP address will be shown (e.g., `192.168.1.100`)

### Method 3: Quick Script

Run this in the mock-server directory:
```bash
./get-ip.sh
```

## Step 2: Update Flutter App Configuration

Edit `app/lib/core/network/authentication_service.dart`:

Find this line (around line 69):
```dart
static const String _baseUrl = 'http://10.0.2.2:3000/api'; // Android emulator default
```

Replace with your Mac's IP address:
```dart
static const String _baseUrl = 'http://192.168.1.100:3000/api'; // Replace with your Mac's IP
```

**Important**: Replace `192.168.1.100` with your actual Mac IP address!

## Step 3: Configure Mac Firewall (if needed)

### Check Firewall Status

1. Open **System Settings** → **Network** → **Firewall**
2. If firewall is ON, you may need to allow incoming connections

### Allow Node.js/Port 3000

**Option A: Temporarily disable firewall** (for testing only)
- Turn off firewall in System Settings

**Option B: Allow specific port** (recommended)
- In Terminal, run:
  ```bash
  sudo /usr/libexec/ApplicationFirewall/socketfilterfw --add /usr/local/bin/node
  sudo /usr/libexec/ApplicationFirewall/socketfilterfw --unblockapp /usr/local/bin/node
  ```

**Option C: Allow all incoming connections for Node** (less secure)
- System Settings → Network → Firewall → Firewall Options
- Add Node.js and allow incoming connections

## Step 4: Start Mock Server

Make sure the server is running and accessible:

```bash
cd mock-server
npm start
```

The server should show:
```
🚀 Mock API server running on http://localhost:3000
```

## Step 5: Test Connection from Phone

### Test 1: Browser on Phone

Open your phone's browser and navigate to:
```
http://YOUR_MAC_IP:3000/health
```

For example: `http://192.168.1.100:3000/health`

You should see:
```json
{
  "status": "ok",
  "message": "Mock API server is running"
}
```

If this works, your phone can reach the server! ✅

### Test 2: Flutter App

1. Build and run the Flutter app on your phone
2. Try to register or login
3. Check the mock server terminal for incoming requests

## Troubleshooting

### Phone Can't Connect

1. **Check IP Address**: Make sure you're using the correct IP
   - Run `ifconfig` again to verify
   - IP might change if you reconnect to WiFi

2. **Check WiFi Network**: Both devices must be on the same network
   - Mac: Check WiFi name in System Settings
   - Phone: Check WiFi name in Settings

3. **Check Firewall**: Mac firewall might be blocking connections
   - Try temporarily disabling firewall
   - Or allow Node.js in firewall settings

4. **Check Server is Running**: Make sure mock server is actually running
   - Check terminal for "Mock API server running" message
   - Try accessing `http://localhost:3000/health` on Mac browser

5. **Check Port**: Make sure nothing else is using port 3000
   - Change port in `server.js` if needed
   - Update Flutter app URL accordingly

### Connection Timeout

- Make sure both devices are on the same WiFi network
- Some public WiFi networks block device-to-device communication
- Try using a mobile hotspot if your WiFi doesn't allow device communication

### CORS Errors

The mock server already has CORS enabled, but if you see CORS errors:
- Check that the server is actually running
- Verify the URL in Flutter app matches the server IP

## Quick Reference

**Mac IP Address**: `192.168.1.XXX` (find using `ifconfig`)

**Flutter App URL**: `http://YOUR_MAC_IP:3000/api`

**Test URL**: `http://YOUR_MAC_IP:3000/health`

## Security Note

⚠️ **This setup is for development/testing only!**

- The mock server is not secure for production
- It's accessible on your local network
- Don't use this setup with real user data
- Always use HTTPS in production


