# Godot MCP Server

A Model Context Protocol (MCP) server that enables Claude to create, manipulate, and test Godot games (both 2D and 3D) programmatically.

## Overview

This project provides a complete solution for AI-powered Godot game development:

- **MCP Server**: Python-based MCP server exposing tools for game creation
- **Godot Bridge Server**: GDScript HTTP server running in headless Godot
- **Full Game Creation**: Create scenes, nodes, scripts, CSG shapes, and more
- **Testing & Capture**: Run games, simulate input, capture screenshots

## Architecture

```
Claude ←→ MCP Server ←→ Godot Bridge Server ←→ Godot Engine (Headless)
         (JSON-RPC)      (HTTP/JSON)           (GDScript API)
```

## Features

### Scene Management
- Create new 2D/3D scenes
- Load and save scenes
- Get scene tree structure

### Node Manipulation
- Create any Godot node type
- Set properties (position, scale, rotation, etc.)
- Move nodes in hierarchy
- Delete nodes
- Query node information

### Script Management
- Create GDScript files from templates
- Attach scripts to nodes
- Update script content
- Multiple templates (Node, CharacterBody2D/3D, RigidBody2D/3D, etc.)

### CSG Tools (3D)
- Create CSG shapes (box, sphere, cylinder, torus, etc.)
- Set CSG operations (union, intersection, subtraction)
- Build complex 3D geometry programmatically

### Game Execution
- Run scenes in play mode
- Stop running scenes
- Simulate keyboard/mouse/controller input
- Test game behavior

### Capture & Analysis
- Capture screenshots
- Get base64-encoded images for visual feedback
- Video capture (frame sequence)

## Installation

### Prerequisites

1. **Godot Engine 4.x** - Download from https://godotengine.org/
2. **Python 3.8+**
3. **pip** (Python package manager)

### Setup

1. **Clone the repository** (already done if you're reading this!)

2. **Install Python dependencies**:
   ```bash
   cd mcp-server
   pip install -r requirements.txt
   ```

3. **Build Godot** (optional - only if you want to modify the engine):
   ```bash
   cd godot
   scons platform=linuxbsd target=editor
   ```

   Or download a pre-built Godot editor binary.

## Usage

### Step 1: Start the Godot Bridge Server

```bash
# Navigate to godot-bridge directory
cd godot-bridge

# Run with Godot (headless mode recommended for production)
godot --headless --path . bridge_server.tscn

# Or with display for debugging:
godot --path . bridge_server.tscn
```

The bridge server will start on `http://127.0.0.1:8765`

### Step 2: Start the MCP Server

```bash
cd mcp-server
python server.py
```

### Step 3: Connect Claude

Add the MCP server to your Claude configuration:

**For Claude Desktop** - Add to `claude_desktop_config.json`:
```json
{
  "mcpServers": {
    "godot": {
      "command": "python",
      "args": ["/path/to/Godot-MCP/mcp-server/server.py"]
    }
  }
}
```

**For Claude Code** - The MCP server will be auto-detected when running in the project directory.

### Step 4: Start Creating Games!

Now you can ask Claude to create games:

> "Create a simple 2D platformer game with a player character that can move and jump"

> "Build a 3D scene with some CSG shapes to create a simple room"

> "Create a script for the player that handles WASD movement"

## Example Workflows

### Creating a Simple 2D Game

```python
# Claude will execute these tools:

1. create_scene(scene_name="Main", scene_type="2D")
2. create_node(node_type="CharacterBody2D", node_name="Player")
3. create_node(node_type="Sprite2D", node_name="PlayerSprite", parent_path="Player")
4. create_script(script_path="res://scripts/player.gd", template="characterbody2d")
5. attach_script(node_path="Player", script_path="res://scripts/player.gd")
6. save_scene(scene_path="res://scenes/main.tscn")
7. run_scene()
8. capture_screenshot()
```

### Creating a 3D Room with CSG

```python
# Claude will execute these tools:

1. create_scene(scene_name="Room", scene_type="3D")
2. create_csg_shape(shape_type="box", properties={"size": {"x": 10, "y": 5, "z": 10}, "name": "Floor"})
3. create_csg_shape(shape_type="box", properties={"size": {"x": 10, "y": 5, "z": 0.5}, "name": "Wall"})
4. set_node_transform(node_path="Wall", position={"x": 0, "y": 2.5, "z": -5})
5. create_node(node_type="Camera3D", node_name="Camera")
6. set_node_transform(node_path="Camera", position={"x": 0, "y": 2, "z": 5})
7. save_scene(scene_path="res://scenes/room.tscn")
```

## Available Tools

### Scene Tools
- `create_scene` - Create a new scene
- `load_scene` - Load existing scene
- `save_scene` - Save scene to file
- `get_scene_tree` - Get scene hierarchy

### Node Tools
- `create_node` - Create node of any type
- `delete_node` - Delete a node
- `set_node_property` - Set any node property
- `get_node_property` - Get property value
- `move_node` - Move node to new parent
- `set_node_transform` - Set position/rotation/scale
- `list_available_nodes` - List all available node types

### Script Tools
- `create_script` - Create GDScript file
- `attach_script` - Attach script to node
- `update_script` - Update script content

### CSG Tools
- `create_csg_shape` - Create CSG shape
- `set_csg_operation` - Set boolean operation

### Execution Tools
- `run_scene` - Run scene in play mode
- `stop_scene` - Stop running scene
- `send_input` - Simulate input events

### Capture Tools
- `capture_screenshot` - Take screenshot

## Project Structure

```
Godot-MCP/
├── godot/                      # Godot engine source (cloned)
├── godot-bridge/               # Godot Bridge Server
│   ├── bridge_server.gd        # Main HTTP server
│   ├── bridge_server.tscn      # Main scene
│   ├── scene_manager.gd        # Scene management
│   ├── node_manager.gd         # Node manipulation
│   ├── script_manager.gd       # Script handling
│   ├── csg_manager.gd          # CSG operations
│   ├── game_executor.gd        # Game execution
│   ├── input_simulator.gd      # Input simulation
│   ├── capture_manager.gd      # Screenshots/video
│   └── project.godot           # Godot project file
├── mcp-server/                 # Python MCP Server
│   ├── server.py               # Main MCP server
│   └── requirements.txt        # Python dependencies
├── docs/                       # Documentation
│   └── ARCHITECTURE.md         # Architecture details
└── README.md                   # This file
```

## API Reference

See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for detailed API documentation.

## Troubleshooting

### Godot Bridge Server won't start

- Ensure Godot 4.x is installed and in your PATH
- Check that port 8765 is not in use
- Try running without `--headless` to see error messages

### MCP Server connection issues

- Verify the bridge server is running
- Check that the URL `http://127.0.0.1:8765` is accessible
- Look for firewall or network issues

### Script errors in Godot

- GDScript errors will be returned in the tool response
- Check script syntax and make sure it matches the node type
- Use the provided templates as a starting point

### Performance issues

- Headless mode is much faster than rendering mode
- Large scenes may take time to load
- Screenshot capture requires rendering, which is slower

## Advanced Usage

### Custom Templates

You can create custom script templates by modifying `script_manager.gd`

### Extending the Bridge Server

Add new endpoints in `bridge_server.gd` and corresponding managers

### Video Capture

Video is currently saved as PNG sequence. Use ffmpeg to convert:
```bash
ffmpeg -framerate 30 -i frame_%05d.png -c:v libx264 output.mp4
```

## Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

This project uses:
- Godot Engine (MIT License)
- MCP SDK (MIT License)
- Python libraries (various licenses)

See individual components for their licenses.

## Credits

- **Godot Engine**: https://godotengine.org/
- **Anthropic MCP**: https://modelcontextprotocol.io/
- **Claude AI**: https://claude.ai/

## Future Enhancements

- [ ] Animation creation and editing
- [ ] Visual shader support
- [ ] Asset library integration
- [ ] Multiplayer testing
- [ ] Physics simulation control
- [ ] AI navigation/pathfinding
- [ ] Performance profiling
- [ ] WebSocket support for real-time updates
- [ ] GDExtension support
- [ ] Multiple project management

## Support

For issues and questions:
- Open an issue on GitHub
- Check the documentation in `docs/`
- Review example workflows

---

**Happy Game Development with Claude and Godot! 🎮🤖**
