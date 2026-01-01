#!/bin/bash

# Script to find Mac's local IP address for phone testing

echo "🔍 Finding your Mac's IP address..."
echo ""

# Try to find IP address on local network
IP=$(ifconfig | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}' | head -1)

if [ -z "$IP" ]; then
  echo "❌ Could not find IP address automatically"
  echo ""
  echo "Please find your IP address manually:"
  echo "1. Open System Settings → Network"
  echo "2. Select your WiFi connection"
  echo "3. Note the IP address (usually starts with 192.168. or 10.)"
  echo ""
  echo "Then update authentication_service.dart with:"
  echo "  static const String _baseUrl = 'http://YOUR_IP:3000/api';"
else
  echo "✅ Found IP address: $IP"
  echo ""
  echo "📝 Update authentication_service.dart with:"
  echo ""
  echo "  static const String _baseUrl = 'http://$IP:3000/api';"
  echo ""
  echo "🧪 Test connection from your phone:"
  echo "  http://$IP:3000/health"
  echo ""
fi


