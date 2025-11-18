# Godot MCP Server Architecture

## Overview

This MCP server enables Claude to create, manipulate, and test Godot games (both 2D and 3D) through a programmatic interface.

## Architecture Components

### 1. Python MCP Server (`mcp-server/`)
- **Technology**: Python with Anthropic's MCP SDK
- **Protocol**: JSON-RPC 2.0 over stdio/HTTP
- **Role**: Exposes tools for Claude to interact with Godot
- **Communication**: HTTP requests to Godot Bridge Server

### 2. Godot Bridge Server (`godot-bridge/`)
- **Technology**: GDScript running in headless Godot engine
- **Protocol**: HTTP REST API (using Godot's HTTPServer or TCPServer)
- **Role**: Executes commands in Godot engine and returns results
- **Capabilities**:
  - Scene management (create, load, save, delete)
  - Node manipulation (create, configure, move, parent)
  - Script generation and attachment
  - CSG shape creation for 3D
  - Game execution (play, pause, stop)
  - Input simulation
  - Screenshot/video capture
  - Resource management

### 3. Godot Engine (Headless Mode)
- **Mode**: `--headless --display-driver headless --audio-driver Dummy`
- **Entry Point**: Custom script that launches the Bridge Server
- **Editor Interface**: Access to EditorInterface for advanced automation

## Communication Flow

```
Claude ←→ MCP Server ←→ Godot Bridge Server ←→ Godot Engine (Headless)
         (JSON-RPC)      (HTTP/JSON)           (GDScript API)
```

## MCP Tools Specification

### Scene Management Tools

1. **create_scene**
   - Input: `scene_name` (string), `scene_type` ("2D"|"3D")
   - Output: Scene path
   - Description: Creates a new empty scene

2. **load_scene**
   - Input: `scene_path` (string)
   - Output: Scene structure (JSON)
   - Description: Loads an existing scene

3. **save_scene**
   - Input: `scene_path` (string)
   - Output: Success status
   - Description: Saves current scene

4. **get_scene_tree**
   - Input: None
   - Output: Scene tree structure (JSON)
   - Description: Returns current scene hierarchy

### Node Manipulation Tools

5. **create_node**
   - Input: `node_type` (string), `node_name` (string), `parent_path` (string, optional)
   - Output: Node path
   - Description: Creates a new node of specified type

6. **delete_node**
   - Input: `node_path` (string)
   - Output: Success status
   - Description: Deletes a node

7. **set_node_property**
   - Input: `node_path` (string), `property` (string), `value` (any)
   - Output: Success status
   - Description: Sets a property on a node

8. **get_node_property**
   - Input: `node_path` (string), `property` (string)
   - Output: Property value
   - Description: Gets a property from a node

9. **move_node**
   - Input: `node_path` (string), `new_parent` (string)
   - Output: Success status
   - Description: Moves a node to a new parent

10. **set_node_transform**
    - Input: `node_path` (string), `position` (Vector2/Vector3), `rotation` (float/Vector3), `scale` (Vector2/Vector3)
    - Output: Success status
    - Description: Sets node's transform (position, rotation, scale)

### Script Management Tools

11. **create_script**
    - Input: `script_path` (string), `script_content` (string), `template` (optional)
    - Output: Script path
    - Description: Creates a new GDScript file

12. **attach_script**
    - Input: `node_path` (string), `script_path` (string)
    - Output: Success status
    - Description: Attaches a script to a node

13. **update_script**
    - Input: `script_path` (string), `script_content` (string)
    - Output: Success status
    - Description: Updates an existing script

### CSG Tools (3D)

14. **create_csg_shape**
    - Input: `shape_type` ("box"|"sphere"|"cylinder"|"polygon"), `properties` (dict), `parent_path` (string, optional)
    - Output: Node path
    - Description: Creates a CSG shape

15. **set_csg_operation**
    - Input: `node_path` (string), `operation` ("union"|"intersection"|"subtraction")
    - Output: Success status
    - Description: Sets CSG boolean operation

### Game Execution Tools

16. **run_scene**
    - Input: `scene_path` (string, optional - runs current if not specified)
    - Output: Success status, process ID
    - Description: Runs a scene in play mode

17. **stop_scene**
    - Input: None
    - Output: Success status
    - Description: Stops the currently running scene

18. **send_input**
    - Input: `input_type` ("key"|"mouse_button"|"mouse_motion"), `input_data` (dict)
    - Output: Success status
    - Description: Sends input events to the running game

### Capture Tools

19. **capture_screenshot**
    - Input: `output_path` (string, optional)
    - Output: Image data (base64) or file path
    - Description: Captures current viewport

20. **start_video_capture**
    - Input: `output_path` (string), `fps` (int, default 30)
    - Output: Success status
    - Description: Starts recording video

21. **stop_video_capture**
    - Input: None
    - Output: Video file path
    - Description: Stops video recording

### Resource Tools

22. **list_available_nodes**
    - Input: `filter` (string, optional - "2D"|"3D"|"Control"|all)
    - Output: List of available node types
    - Description: Lists all available node types in Godot

23. **get_node_documentation**
    - Input: `node_type` (string)
    - Output: Documentation string
    - Description: Gets documentation for a node type

24. **import_resource**
    - Input: `resource_path` (string), `resource_type` (string)
    - Output: Resource path
    - Description: Imports external resources (images, models, audio)

## Godot Bridge Server API Endpoints

All endpoints accept and return JSON.

### Scene Endpoints
- `POST /scene/create` - Create scene
- `GET /scene/load` - Load scene
- `POST /scene/save` - Save scene
- `GET /scene/tree` - Get scene tree

### Node Endpoints
- `POST /node/create` - Create node
- `DELETE /node/delete` - Delete node
- `PUT /node/property` - Set property
- `GET /node/property` - Get property
- `POST /node/move` - Move node
- `PUT /node/transform` - Set transform

### Script Endpoints
- `POST /script/create` - Create script
- `POST /script/attach` - Attach script
- `PUT /script/update` - Update script

### CSG Endpoints
- `POST /csg/create` - Create CSG shape
- `PUT /csg/operation` - Set CSG operation

### Execution Endpoints
- `POST /game/run` - Run scene
- `POST /game/stop` - Stop scene
- `POST /game/input` - Send input

### Capture Endpoints
- `GET /capture/screenshot` - Capture screenshot
- `POST /capture/video/start` - Start video
- `POST /capture/video/stop` - Stop video

### Resource Endpoints
- `GET /resource/nodes` - List available nodes
- `GET /resource/docs` - Get node docs
- `POST /resource/import` - Import resource

## Implementation Plan

### Phase 1: Core Infrastructure
1. Set up Godot Bridge Server (GDScript HTTP server)
2. Set up Python MCP Server skeleton
3. Implement basic communication

### Phase 2: Scene & Node Management
1. Implement scene creation/loading/saving
2. Implement node creation/deletion
3. Implement property get/set
4. Implement node hierarchy manipulation

### Phase 3: Scripting
1. Implement script creation
2. Implement script attachment
3. Add GDScript templates

### Phase 4: 3D & CSG
1. Implement CSG shape creation
2. Implement CSG operations
3. Add 3D-specific tools

### Phase 5: Execution & Testing
1. Implement game execution
2. Implement input simulation
3. Implement screenshot capture
4. Add video capture (optional)

### Phase 6: Polish & Testing
1. Add error handling
2. Add comprehensive logging
3. Create example workflows
4. Write documentation

## File Structure

```
Godot-MCP/
├── godot/                      # Cloned Godot repository
├── godot-bridge/               # Godot Bridge Server
│   ├── bridge_server.gd        # Main HTTP server script
│   ├── scene_manager.gd        # Scene management
│   ├── node_manager.gd         # Node manipulation
│   ├── script_manager.gd       # Script handling
│   ├── csg_manager.gd          # CSG operations
│   ├── game_executor.gd        # Game execution
│   ├── input_simulator.gd      # Input simulation
│   ├── capture_manager.gd      # Screenshots/video
│   ├── project.godot           # Godot project file
│   └── README.md               # Bridge server docs
├── mcp-server/                 # Python MCP Server
│   ├── server.py               # Main MCP server
│   ├── godot_client.py         # HTTP client for Godot Bridge
│   ├── tools/                  # MCP tool implementations
│   │   ├── scene_tools.py
│   │   ├── node_tools.py
│   │   ├── script_tools.py
│   │   ├── csg_tools.py
│   │   ├── execution_tools.py
│   │   └── capture_tools.py
│   ├── requirements.txt
│   └── README.md
├── docs/                       # Documentation
│   ├── ARCHITECTURE.md         # This file
│   ├── API.md                  # API reference
│   └── EXAMPLES.md             # Usage examples
├── examples/                   # Example games
└── README.md                   # Project README
```

## Technical Considerations

### Godot Bridge Server Implementation

**Option 1: HTTPServer (Godot 4.x)**
- Use Godot's built-in HTTPServer class
- Simple request/response handling
- Good for REST API

**Option 2: TCPServer with custom HTTP parsing**
- Lower level but more control
- Can handle WebSocket upgrades
- More complex implementation

**Recommendation**: Start with HTTPServer for simplicity, can upgrade to TCPServer if needed.

### Scene State Management

- The bridge server maintains the currently active scene
- EditorInterface provides access to edited scene root
- Can switch between scenes as needed
- Save/load operations use PackedScene

### Input Simulation

- Use `Input.parse_input_event()` to inject events
- Create InputEvent objects (InputEventKey, InputEventMouseButton, etc.)
- Events are processed in the next frame

### Screenshot Capture

- Get Viewport texture: `get_viewport().get_texture()`
- Convert to Image: `texture.get_image()`
- Save as PNG: `image.save_png(path)`
- Return as base64 for remote display

### Error Handling

- All Bridge API endpoints return structured JSON with status
- Errors include error code, message, and stack trace (if applicable)
- MCP server wraps errors in user-friendly messages

## Security Considerations

1. **Local Only**: Bridge server should only listen on localhost
2. **No Authentication**: Assumes trusted local environment
3. **File System Access**: Limited to project directory
4. **Resource Limits**: Implement timeouts and size limits
5. **Input Validation**: Validate all inputs before passing to Godot

## Performance Considerations

1. **Headless Mode**: Runs without rendering overhead (except when capturing)
2. **HTTP Overhead**: Minimal for local communication
3. **Scene Complexity**: Large scenes may slow down operations
4. **Screenshot Capture**: Requires enabling rendering temporarily
5. **Async Operations**: Use async for long-running tasks

## Future Enhancements

1. **WebSocket Support**: Real-time updates and streaming
2. **Multi-Project Support**: Handle multiple Godot projects
3. **Asset Library Integration**: Download assets from Godot Asset Library
4. **GDNative/GDExtension Support**: Work with native plugins
5. **Multiplayer Testing**: Simulate multiple players
6. **Performance Profiling**: Expose Godot's profiler data
7. **Visual Shader Editor**: Create visual shaders programmatically
8. **Animation Tools**: Create and edit animations
9. **Physics Simulation**: Step physics and query results
10. **AI Navigation**: NavMesh generation and pathfinding
