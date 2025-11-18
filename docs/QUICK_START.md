# Quick Start Guide

Get up and running with Godot MCP Server in minutes!

## Prerequisites

- ✅ Godot 4.x installed (download from https://godotengine.org/)
- ✅ Python 3.8+ installed
- ✅ Claude Desktop or Claude Code

## Step-by-Step Setup

### 1. Install Python Dependencies

```bash
cd mcp-server
pip install -r requirements.txt
```

### 2. Configure Claude

**For Claude Desktop:**

Edit your configuration file:
- **macOS:** `~/Library/Application Support/Claude/claude_desktop_config.json`
- **Windows:** `%APPDATA%\Claude\claude_desktop_config.json`
- **Linux:** `~/.config/Claude/claude_desktop_config.json`

Add this configuration:

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

**Important:** Replace `/absolute/path/to/` with the actual path!

**For Claude Code:**

The MCP server will be auto-detected when you work in this directory.

### 3. Start the Godot Bridge Server

Open a terminal and run:

```bash
# From the project root
./start-bridge.sh          # Linux/Mac
start-bridge.bat           # Windows
```

You should see:
```
=== Godot MCP Bridge Server ===
Initializing managers...
SceneManager initialized
NodeManager initialized
...
Server started on 127.0.0.1:8765
Waiting for connections...
```

**Keep this terminal open!**

### 4. Restart Claude Desktop

If using Claude Desktop, restart the application to load the new MCP server.

### 5. Start Creating Games!

Open Claude and try these examples:

#### Example 1: Create a Simple 2D Scene

> "Create a 2D scene called 'TestScene' with a Node2D root. Add a Sprite2D node called 'Player' at position (400, 300). Save the scene as res://scenes/test.tscn"

#### Example 2: Create a 3D Room

> "Create a 3D scene. Use CSG shapes to build a simple room with a floor (10x10), four walls, and add a Camera3D. Save it as res://scenes/room.tscn"

#### Example 3: Create a Player Character with Script

> "Create a 2D scene with a CharacterBody2D named 'Player'. Create a movement script using the CharacterBody2D template and attach it to the player. Save everything."

#### Example 4: Test Your Game

> "Run the current scene and take a screenshot so I can see it"

## Verify Everything Works

### Test 1: Check Server Connection

Ask Claude:
> "List all available 2D node types"

Claude should return a list of Godot nodes like Sprite2D, Node2D, CharacterBody2D, etc.

### Test 2: Create a Simple Scene

Ask Claude:
> "Create a new 2D scene called 'Hello' and save it as res://hello.tscn"

You should see a success message with the scene path.

### Test 3: Get Scene Tree

Ask Claude:
> "Show me the current scene tree"

You should see the scene hierarchy in JSON format.

## Common Issues

### Issue: "Connection refused"

**Solution:** Make sure the Godot Bridge Server is running.

```bash
./start-bridge.sh
```

### Issue: "godot command not found"

**Solution:** Install Godot or add it to your PATH.

**macOS/Linux:**
```bash
export PATH="/path/to/godot:$PATH"
```

**Windows:**
Add Godot to your System Environment Variables.

### Issue: MCP server not appearing in Claude

**Solution:**
1. Check the configuration file path is correct
2. Verify the Python script path is absolute
3. Restart Claude Desktop
4. Check Claude logs for errors

### Issue: Scene not saving

**Solution:**
- Make sure you're using Godot resource paths (res://...)
- The bridge server will create directories automatically
- Check file permissions

## Next Steps

1. **Read the Full Documentation:** Check [README.md](../README.md) and [ARCHITECTURE.md](ARCHITECTURE.md)

2. **Explore Examples:** Try the example workflows in this guide

3. **Create Your First Game:** Start with a simple game idea and let Claude help you build it!

4. **Learn GDScript:** Understanding GDScript will help you create better scripts

5. **Experiment:** Try different node types, CSG shapes, and game mechanics

## Tips for Working with Claude

### Be Specific

Instead of:
> "Create a game"

Try:
> "Create a 2D platformer scene with a CharacterBody2D player that can move left/right and jump"

### Break Down Complex Tasks

Instead of:
> "Create a complete RPG"

Try:
> 1. "Create a 2D scene with a player character"
> 2. "Add movement controls to the player"
> 3. "Create an enemy character"
> 4. "Add collision detection"
> etc.

### Ask for Screenshots

After creating or running a scene:
> "Run this scene and take a screenshot"

This helps you verify the visual result.

### Iterate

Build your game incrementally:
1. Create basic structure
2. Add functionality
3. Test
4. Refine
5. Repeat

## Example Workflow: Creating a Simple Game

Here's a complete workflow for creating a basic 2D game:

**Step 1:** Create the Scene
> "Create a new 2D scene called 'Game' and save it as res://scenes/game.tscn"

**Step 2:** Add the Player
> "Create a CharacterBody2D node called 'Player' with a Sprite2D child called 'PlayerSprite'"

**Step 3:** Add Player Script
> "Create a player movement script using the CharacterBody2D template and attach it to the Player node. The script should handle WASD movement."

**Step 4:** Add Ground
> "Create a StaticBody2D called 'Ground' with a ColorRect child for visualization. Position it at the bottom of the screen."

**Step 5:** Test
> "Run the scene and capture a screenshot"

**Step 6:** Iterate
> "Modify the player script to add jump functionality when Space is pressed"

## Resources

- **Godot Documentation:** https://docs.godotengine.org/
- **GDScript Tutorial:** https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/
- **MCP Documentation:** https://modelcontextprotocol.io/
- **Claude Documentation:** https://docs.claude.ai/

## Getting Help

1. Check the documentation in the `docs/` folder
2. Review error messages from the Godot Bridge Server
3. Look at the example workflows
4. Open an issue on GitHub if you encounter bugs

---

**Happy game development! 🎮**
