#!/bin/bash
# Start the Godot Bridge Server

echo "Starting Godot MCP Bridge Server..."
echo "Server will run on http://127.0.0.1:8765"
echo ""

# Check if godot is in PATH
if ! command -v godot &> /dev/null; then
    echo "Error: 'godot' command not found!"
    echo "Please install Godot 4.x and add it to your PATH"
    echo "Or download from: https://godotengine.org/"
    exit 1
fi

# Navigate to godot-bridge directory
cd "$(dirname "$0")/godot-bridge" || exit 1

# Run Godot in headless mode
echo "Running: godot --headless --path . bridge_server.tscn"
godot --headless --path . bridge_server.tscn
