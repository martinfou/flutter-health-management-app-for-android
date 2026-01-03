#!/bin/bash

# start_ollama.sh - Script to start Ollama service and check for required models

# Check if ollama is installed
if ! command -v ollama &> /dev/null
then
    echo "Error: ollama could not be found. Please install it from https://ollama.com/"
    exit 1
fi

echo "Starting Ollama service..."

# Configure Ollama to listen on all network interfaces (0.0.0.0)
# This allows access from physical devices on the same network
export OLLAMA_HOST=0.0.0.0:11434

# On macOS, 'ollama serve' starts the server if it's not already running as a background app
# However, many users have the Ollama app running. We'll check if the port is busy.
if lsof -Pi :11434 -sTCP:LISTEN -t >/dev/null ; then
    echo "Ollama service is already running on port 11434."
    echo "⚠️  Note: If you need network access from other devices, you may need to:"
    echo "   1. Stop the current Ollama process"
    echo "   2. Run this script again (it will start with OLLAMA_HOST=0.0.0.0:11434)"
    echo "   3. Or set OLLAMA_HOST=0.0.0.0:11434 in your shell and restart Ollama"
else
    # Start ollama serve in the background with network access enabled
    echo "Starting Ollama with network access enabled (OLLAMA_HOST=0.0.0.0:11434)..."
    ollama serve &
    echo "Waiting for Ollama to initialize..."
    sleep 5
fi

# Ensure default models are available (optional, but helpful for this app)
# We prioritize llama3 as it's the default in our OllamaAdapter
DEFAULT_MODEL="llama3"

echo "Checking for $DEFAULT_MODEL..."
if ! ollama list | grep -q "$DEFAULT_MODEL"; then
    echo "$DEFAULT_MODEL not found. Pulling it now (this may take a few minutes)..."
    ollama pull "$DEFAULT_MODEL"
else
    echo "$DEFAULT_MODEL is ready."
fi

# Verify Ollama is listening on all interfaces (for network access)
echo ""
echo "Verifying Ollama network configuration..."
if lsof -Pi :11434 -sTCP:LISTEN | grep -q ":11434 (LISTEN)"; then
    LISTEN_ADDR=$(lsof -Pi :11434 -sTCP:LISTEN | awk 'NR>1 {print $9}' | cut -d: -f1)
    if [ "$LISTEN_ADDR" = "*" ] || [ "$LISTEN_ADDR" = "0.0.0.0" ]; then
        echo "✅ Ollama is listening on all network interfaces (accessible from other devices)"
        echo "   Your Mac's IP: $(ifconfig | grep 'inet ' | grep -v 127.0.0.1 | awk '{print $2}' | head -1)"
    else
        echo "⚠️  Ollama is only listening on $LISTEN_ADDR (localhost only)"
        echo "   To enable network access, stop Ollama and run this script again"
    fi
fi

echo ""
echo "Ollama is ready to use with the Health Management App!"
