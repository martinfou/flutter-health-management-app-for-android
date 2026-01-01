#!/bin/bash

# Script to fix Flutter startup lock issue

echo "🔧 Fixing Flutter startup lock..."

# Kill any Flutter processes
echo "1. Killing Flutter processes..."
pkill -f "flutter" 2>/dev/null
pkill -f "dart" 2>/dev/null
sleep 1

# Remove lock files
echo "2. Removing lock files..."
find .dart_tool -name "*.lock" -delete 2>/dev/null
find build -name "*.lock" -delete 2>/dev/null
rm -f .dart_tool/flutter_build/*.lock 2>/dev/null
rm -f .dart_tool/package_config_subset*.lock 2>/dev/null

# Clean Flutter build
echo "3. Cleaning Flutter build..."
flutter clean > /dev/null 2>&1

echo "✅ Done! Try running 'flutter run' again."


