# Godot Bridge Server

This is the GDScript-based HTTP server that runs inside Godot and executes commands from the MCP server.

## Components

- **bridge_server.gd** - Main HTTP server that listens on port 8765
- **scene_manager.gd** - Handles scene creation, loading, and saving
- **node_manager.gd** - Handles node creation, deletion, and property manipulation
- **script_manager.gd** - Handles GDScript creation and attachment
- **csg_manager.gd** - Handles CSG shape creation and operations
- **game_executor.gd** - Handles running and stopping scenes
- **input_simulator.gd** - Handles input event simulation
- **capture_manager.gd** - Handles screenshot and video capture

## Running the Server

### Option 1: Using the startup script (recommended)

From the project root:
```bash
./start-bridge.sh          # Linux/Mac
start-bridge.bat           # Windows
```

### Option 2: Manually with Godot

```bash
cd godot-bridge
godot --headless --path . bridge_server.tscn
```

### Option 3: With Godot Editor (for debugging)

```bash
cd godot-bridge
godot --path . bridge_server.tscn
```

This will open the Godot editor and you can run the scene from there.

## API Endpoints

All endpoints accept and return JSON.

### Scene Management

- **POST /scene/create** - Create a new scene
  ```json
  {
    "scene_name": "MainScene",
    "scene_type": "2D"  // or "3D"
  }
  ```

- **GET /scene/load** - Load a scene
  ```json
  {
    "scene_path": "res://scenes/main.tscn"
  }
  ```

- **POST /scene/save** - Save current scene
  ```json
  {
    "scene_path": "res://scenes/main.tscn"  // optional
  }
  ```

- **GET /scene/tree** - Get scene tree structure
  ```json
  {}
  ```

### Node Management

- **POST /node/create** - Create a node
  ```json
  {
    "node_type": "Sprite2D",
    "node_name": "PlayerSprite",
    "parent_path": ""  // optional, defaults to scene root
  }
  ```

- **DELETE /node/delete** - Delete a node
  ```json
  {
    "node_path": "PlayerSprite"
  }
  ```

- **PUT /node/property/set** - Set node property
  ```json
  {
    "node_path": "PlayerSprite",
    "property": "texture",
    "value": "res://sprites/player.png"
  }
  ```

- **GET /node/property/get** - Get node property
  ```json
  {
    "node_path": "PlayerSprite",
    "property": "position"
  }
  ```

- **POST /node/move** - Move node to new parent
  ```json
  {
    "node_path": "PlayerSprite",
    "new_parent": "Player"
  }
  ```

- **PUT /node/transform** - Set node transform
  ```json
  {
    "node_path": "Player",
    "position": {"x": 100, "y": 200},
    "rotation": 0,
    "scale": {"x": 1, "y": 1}
  }
  ```

- **GET /resource/nodes** - List available node types
  ```json
  {
    "filter": "2D"  // optional: "", "2D", "3D", "Control"
  }
  ```

### Script Management

- **POST /script/create** - Create a script
  ```json
  {
    "script_path": "res://scripts/player.gd",
    "script_content": "extends Node\n\nfunc _ready():\n\tpass",
    "template": "node2d"  // optional
  }
  ```

- **POST /script/attach** - Attach script to node
  ```json
  {
    "node_path": "Player",
    "script_path": "res://scripts/player.gd"
  }
  ```

- **PUT /script/update** - Update script content
  ```json
  {
    "script_path": "res://scripts/player.gd",
    "script_content": "extends Node2D\n\nfunc _process(delta):\n\tpass"
  }
  ```

### CSG Tools

- **POST /csg/create** - Create CSG shape
  ```json
  {
    "shape_type": "box",
    "properties": {
      "name": "Floor",
      "size": {"x": 10, "y": 1, "z": 10},
      "position": {"x": 0, "y": 0, "z": 0},
      "material": {
        "color": {"r": 0.5, "g": 0.5, "b": 0.5, "a": 1.0}
      }
    },
    "parent_path": ""  // optional
  }
  ```

- **PUT /csg/operation** - Set CSG operation
  ```json
  {
    "node_path": "CSGBox",
    "operation": "union"  // or "intersection", "subtraction"
  }
  ```

### Game Execution

- **POST /game/run** - Run a scene
  ```json
  {
    "scene_path": "res://scenes/main.tscn"  // optional, runs current if not specified
  }
  ```

- **POST /game/stop** - Stop running scene
  ```json
  {}
  ```

- **POST /game/input** - Send input event
  ```json
  {
    "input_type": "key",
    "input_data": {
      "key": "W",
      "pressed": true
    }
  }
  ```

### Capture

- **GET /capture/screenshot** - Capture screenshot
  ```json
  {
    "output_path": "res://screenshots/test.png",  // optional
    "return_base64": true  // optional, default true
  }
  ```

- **POST /capture/video/start** - Start video recording
  ```json
  {
    "output_path": "res://videos/gameplay.png",
    "fps": 30
  }
  ```

- **POST /capture/video/stop** - Stop video recording
  ```json
  {}
  ```

### Health Check

- **GET /health** - Server health check
  ```json
  {}
  ```

## Response Format

All responses follow this format:

**Success:**
```json
{
  "status": "success",
  "code": 200,
  // ... additional data
}
```

**Error:**
```json
{
  "status": "error",
  "code": 400,  // or other error code
  "error": "Error message here"
}
```

## Configuration

The server is configured in `bridge_server.gd`:

```gdscript
const PORT = 8765
const HOST = "127.0.0.1"
```

Change these if you need to use a different port or host.

## Troubleshooting

### Server won't start

- Check if port 8765 is already in use
- Ensure Godot 4.x is installed
- Look for error messages in the console

### Requests timing out

- Ensure the server is running
- Check firewall settings
- Verify the URL is correct (http://127.0.0.1:8765)

### Script errors

- GDScript errors will be printed to the console
- Run with `--path . bridge_server.tscn` (without --headless) to see the Godot editor

### Scene saving issues

- Ensure the target directory exists or will be created
- Check file permissions
- Verify the path uses the Godot resource format (res://)

## Development

To add new endpoints:

1. Add the endpoint handler in `bridge_server.gd` `route_request()` function
2. Create or update the appropriate manager class
3. Add the corresponding tool in the MCP server (`mcp-server/server.py`)

## License

This component is part of the Godot MCP Server project.
