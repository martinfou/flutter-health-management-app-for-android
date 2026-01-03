#!/bin/bash

# Start script for mock server
echo "🚀 Starting Mock API Server..."
echo ""

# Check if node_modules exists
if [ ! -d "node_modules" ]; then
  echo "📦 Installing dependencies..."
  npm install
  echo ""
fi

# Start the server
echo "✅ Starting server on http://localhost:3000"
npm start




