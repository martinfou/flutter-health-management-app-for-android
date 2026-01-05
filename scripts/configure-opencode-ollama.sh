#!/usr/bin/env bash
# Configure OpenCode to use local Ollama instance
# This script sets up the OpenCode configuration to connect to your local Ollama service

set -euo pipefail

CONFIG_DIR="$HOME/.config/opencode"
CONFIG_FILE="$CONFIG_DIR/config.json"
OLLAMA_PORT="${OLLAMA_PORT:-11434}"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_message() {
    local level=$1
    shift
    case $level in
        info)
            echo -e "${GREEN}[INFO]${NC} $*"
            ;;
        warning)
            echo -e "${YELLOW}[WARNING]${NC} $*"
            ;;
        step)
            echo -e "${BLUE}[STEP]${NC} $*"
            ;;
    esac
}

# Check if Ollama is running
print_message step "Checking if Ollama is running..."
if ! curl -s "http://localhost:${OLLAMA_PORT}/api/tags" > /dev/null 2>&1; then
    print_message warning "Ollama doesn't appear to be running on localhost:${OLLAMA_PORT}"
    print_message info "Start Ollama with: ollama serve"
    print_message info "Or launch the Ollama.app from /Volumes/T7/Applications/"
    exit 1
fi

print_message info "Ollama is running ✓"

# Get available models from Ollama
print_message step "Fetching available Ollama models..."
models=$(curl -s "http://localhost:${OLLAMA_PORT}/api/tags" | python3 -c "
import sys, json
data = json.load(sys.stdin)
models = [model['name'] for model in data.get('models', [])]
for model in models:
    print(model)
" 2>/dev/null || echo "")

if [ -z "$models" ]; then
    print_message warning "No models found in Ollama. Pull a model first:"
    print_message info "  ollama pull llama3"
    exit 1
fi

print_message info "Found models:"
echo "$models" | while read -r model; do
    echo "  - $model"
done

# Create config directory
mkdir -p "$CONFIG_DIR"

# Create configuration JSON
print_message step "Creating OpenCode configuration..."

# Generate models section
models_json=""
first=true
echo "$models" | while read -r model; do
    if [ -n "$model" ]; then
        if [ "$first" = true ]; then
            models_json="        \"ollama/$model\": {\n          \"name\": \"$model\",\n          \"tools\": true\n        }"
            first=false
        else
            models_json="$models_json,\n        \"ollama/$model\": {\n          \"name\": \"$model\",\n          \"tools\": true\n        }"
        fi
    fi
done

# Create the config file using a Python script for proper JSON formatting
python3 << EOF > "$CONFIG_FILE"
import json
import sys

models = """$models""".strip().split('\n')
models = [m for m in models if m.strip()]

models_config = {}
for model in models:
    if model:
        # Model keys should NOT include the ollama/ prefix - OpenCode adds it automatically
        models_config[model] = {
            "name": model,
            "tools": True
        }

config = {
    "\$schema": "https://opencode.ai/config.json",
    "provider": {
        "ollama": {
            "npm": "@ai-sdk/openai-compatible",
            "name": "Ollama (local)",
            "options": {
                "baseURL": "http://localhost:${OLLAMA_PORT}/v1"
            },
            "models": models_config
        }
    }
}

print(json.dumps(config, indent=2))
EOF

print_message info "Configuration file created at: $CONFIG_FILE"
print_message info "Configuration:"
cat "$CONFIG_FILE"

echo ""
print_message info "═══════════════════════════════════════════════════════════"
print_message info "OpenCode is now configured to use your local Ollama!"
print_message info "═══════════════════════════════════════════════════════════"
echo ""
print_message info "To use a specific model with OpenCode:"
print_message step "  opencode --model ollama/llama3:latest"
echo ""
print_message info "Or simply:"
print_message step "  opencode"
echo ""
print_message info "OpenCode will use your local Ollama models for code assistance."

