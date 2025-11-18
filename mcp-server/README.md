# Godot MCP Server

Python-based Model Context Protocol server for Godot game engine automation.

## Installation

```bash
pip install -r requirements.txt
```

## Running

The MCP server communicates with Claude via stdio:

```bash
python server.py
```

**Note:** The Godot Bridge Server must be running before starting the MCP server.

## Configuration

The server connects to the Godot Bridge Server at:
```python
BRIDGE_HOST = "http://127.0.0.1:8765"
REQUEST_TIMEOUT = 30.0
```

Modify these constants in `server.py` if needed.

## Integration with Claude

### Claude Desktop

Add to your Claude Desktop configuration file:

**macOS:** `~/Library/Application Support/Claude/claude_desktop_config.json`
**Windows:** `%APPDATA%\Claude\claude_desktop_config.json`

```json
{
  "mcpServers": {
    "godot": {
      "command": "python",
      "args": ["/absolute/path/to/Godot-MCP/mcp-server/server.py"]
    }
  }
}
```

### Claude Code

Run the MCP server in your development environment and it will be auto-detected.

## Available Tools

The server exposes 20+ tools for game development:

### Scene Management (4 tools)
- `create_scene` - Create new scene
- `load_scene` - Load existing scene
- `save_scene` - Save scene to file
- `get_scene_tree` - Get scene hierarchy

### Node Management (7 tools)
- `create_node` - Create any node type
- `delete_node` - Delete a node
- `set_node_property` - Set node property
- `get_node_property` - Get property value
- `move_node` - Move to new parent
- `set_node_transform` - Set position/rotation/scale
- `list_available_nodes` - List all available nodes

### Script Management (3 tools)
- `create_script` - Create GDScript file
- `attach_script` - Attach to node
- `update_script` - Update script content

### CSG Tools (2 tools)
- `create_csg_shape` - Create 3D CSG shape
- `set_csg_operation` - Set boolean operation

### Execution Tools (3 tools)
- `run_scene` - Run scene in play mode
- `stop_scene` - Stop running scene
- `send_input` - Simulate input events

### Capture Tools (1 tool)
- `capture_screenshot` - Capture viewport screenshot

## Usage Examples

### Ask Claude to create a simple game:

> "Create a 2D platformer with a player character that can move left and right using arrow keys"

Claude will use these tools:
1. `create_scene` - Create main scene
2. `create_node` - Create CharacterBody2D for player
3. `create_script` - Create movement script
4. `attach_script` - Attach to player
5. `save_scene` - Save the scene
6. `run_scene` - Test the game
7. `capture_screenshot` - Show the result

### Ask Claude to create a 3D environment:

> "Create a simple 3D room using CSG shapes"

Claude will use:
1. `create_scene` - Create 3D scene
2. `create_csg_shape` - Create floor, walls, ceiling
3. `set_csg_operation` - Set operations for complex geometry
4. `create_node` - Add camera and lighting
5. `save_scene` - Save the scene

## Development

### Adding New Tools

1. Add tool definition in `list_tools()`:
```python
Tool(
    name="my_new_tool",
    description="Description of the tool",
    inputSchema={
        "type": "object",
        "properties": {
            "param1": {
                "type": "string",
                "description": "Parameter description"
            }
        },
        "required": ["param1"]
    }
)
```

2. Add endpoint mapping in `call_tool()`:
```python
endpoint_map = {
    # ...
    "my_new_tool": "/my/endpoint",
}
```

3. Implement the corresponding endpoint in Godot Bridge Server

### Error Handling

All errors from the Godot Bridge are formatted and returned to Claude:

```python
if result.get("status") == "success":
    # Return success response
else:
    # Return formatted error
    error_msg = result.get("error", "Unknown error")
    return [TextContent(text=f"Error: {error_msg}")]
```

### Response Types

The server can return:
- **Text**: JSON data, messages, errors
- **Images**: Screenshots (base64-encoded PNG)
- **Resources**: Files, assets (future feature)

## Dependencies

- `mcp>=1.0.0` - Model Context Protocol SDK
- `httpx>=0.27.0` - Async HTTP client
- `pydantic>=2.0.0` - Data validation

## Troubleshooting

### "Connection refused" errors

- Ensure Godot Bridge Server is running
- Check that it's listening on `http://127.0.0.1:8765`
- Verify firewall settings

### Tool execution timeouts

- Increase `REQUEST_TIMEOUT` for complex operations
- Check Godot Bridge Server logs for errors
- Ensure the operation is valid

### Import errors

- Verify all dependencies are installed: `pip install -r requirements.txt`
- Use Python 3.8 or higher
- Consider using a virtual environment

## Testing

Test the server manually:

```bash
# Start Godot Bridge first
cd ../godot-bridge
godot --headless --path . bridge_server.tscn

# In another terminal, start MCP server
cd mcp-server
python server.py

# The server will wait for stdin input from Claude
```

## License

Part of the Godot MCP Server project.
