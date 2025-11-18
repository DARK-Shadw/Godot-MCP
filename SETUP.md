# Godot MCP Server - Setup Guide

Complete step-by-step instructions to get the Godot MCP Server running.

## ⚡ Quick Setup (5 minutes)

### Step 1: Install Godot Engine

Download and install Godot 4.x from https://godotengine.org/download

**Option A: Add to PATH (Recommended)**
- Extract Godot to a folder (e.g., `C:\Godot\` or `~/Applications/Godot/`)
- Add the folder to your system PATH

**Option B: Direct Installation**
- On Linux: `sudo apt install godot` (or your package manager)
- On macOS: Use Homebrew: `brew install godot`
- On Windows: Download and extract the executable

**Verify Installation:**
```bash
godot --version
```

You should see something like: `Godot Engine v4.3.stable.official`

### Step 2: Install Python Dependencies

```bash
cd mcp-server
pip install -r requirements.txt
```

**If you get errors, try:**
```bash
pip install --upgrade pip
pip install mcp httpx pydantic
```

### Step 3: Test the Godot Bridge Server

```bash
# From the project root directory
./start-bridge.sh          # Linux/Mac
start-bridge.bat           # Windows
```

**Expected Output:**
```
=== Godot MCP Bridge Server ===
Initializing managers...
SceneManager initialized
NodeManager initialized
ScriptManager initialized
CSGManager initialized
GameExecutor initialized
InputSimulator initialized
CaptureManager initialized
Server started on 127.0.0.1:8765
Waiting for connections...
```

**Keep this terminal open!** The server must run while using the MCP server.

### Step 4: Configure Claude

#### For Claude Desktop:

1. **Find your configuration file:**
   - **macOS:** `~/Library/Application Support/Claude/claude_desktop_config.json`
   - **Windows:** `%APPDATA%\Claude\claude_desktop_config.json`
   - **Linux:** `~/.config/Claude/claude_desktop_config.json`

2. **Create/edit the file with this content:**

```json
{
  "mcpServers": {
    "godot": {
      "command": "python",
      "args": [
        "/absolute/path/to/Godot-MCP/mcp-server/server.py"
      ]
    }
  }
}
```

**⚠️ IMPORTANT:** Replace `/absolute/path/to/` with the actual path!

**Example paths:**
- Windows: `"C:\\Users\\YourName\\Documents\\Godot-MCP\\mcp-server\\server.py"`
- macOS: `"/Users/YourName/Projects/Godot-MCP/mcp-server/server.py"`
- Linux: `"/home/username/Godot-MCP/mcp-server/server.py"`

**Find the absolute path:**
```bash
# On Linux/Mac:
cd /home/user/Godot-MCP/mcp-server
pwd
# Copy the output and add /server.py

# On Windows (in PowerShell):
cd C:\path\to\Godot-MCP\mcp-server
(Get-Location).Path
# Copy the output and add \server.py
```

3. **Restart Claude Desktop**

#### For Claude Code:

The MCP server will be auto-detected when you work in this directory. No configuration needed!

### Step 5: Test the Setup

1. **Ensure Godot Bridge is running** (from Step 3)

2. **Open Claude Desktop or Claude Code**

3. **Verify the MCP server is connected:**
   - Look for a tools/MCP indicator in Claude
   - You should see "godot" server listed

4. **Test with a simple command:**

Ask Claude:
```
List all available 2D node types in Godot
```

**Expected Response:**
Claude should return a list of node types like:
- AnimatedSprite2D
- CharacterBody2D
- Node2D
- Sprite2D
- etc.

5. **Create your first scene:**

Ask Claude:
```
Create a new 2D scene called "TestScene" with a Node2D root node,
and save it as res://test.tscn. Then show me the scene tree.
```

**Success!** If you see a scene tree in JSON format, everything is working! 🎉

---

## 📋 Detailed Setup Instructions

### Installing Godot 4.x

#### Windows:
1. Go to https://godotengine.org/download
2. Download "Godot Engine - .NET or Standard version"
3. Extract the ZIP file to `C:\Godot\`
4. Rename the executable to `godot.exe`
5. Add to PATH:
   - Open "Environment Variables" in Windows Settings
   - Edit "Path" variable
   - Add `C:\Godot\`
   - Click OK

#### macOS:
```bash
# Using Homebrew (recommended)
brew install godot

# Or download from website
# Move Godot.app to /Applications/
# Create a symlink:
sudo ln -s /Applications/Godot.app/Contents/MacOS/Godot /usr/local/bin/godot
```

#### Linux (Ubuntu/Debian):
```bash
# Option 1: Official repository
sudo apt install godot

# Option 2: Download from website
wget https://downloads.tuxfamily.org/godotengine/4.3/Godot_v4.3-stable_linux.x86_64.zip
unzip Godot_v4.3-stable_linux.x86_64.zip
sudo mv Godot_v4.3-stable_linux.x86_64 /usr/local/bin/godot
sudo chmod +x /usr/local/bin/godot
```

### Installing Python Dependencies

#### Windows:
```bash
cd C:\path\to\Godot-MCP\mcp-server
python -m pip install --upgrade pip
pip install -r requirements.txt
```

#### macOS/Linux:
```bash
cd /path/to/Godot-MCP/mcp-server
python3 -m pip install --upgrade pip
pip3 install -r requirements.txt
```

**If you have multiple Python versions:**
```bash
# Use Python 3.8 or higher
python3.9 -m pip install -r requirements.txt
```

**Using a virtual environment (recommended):**
```bash
# Create virtual environment
python -m venv venv

# Activate it
source venv/bin/activate  # Linux/Mac
venv\Scripts\activate     # Windows

# Install dependencies
pip install -r requirements.txt
```

---

## 🔧 Troubleshooting

### Problem: "godot command not found"

**Solution:**
1. Verify Godot is installed: `which godot` (Linux/Mac) or `where godot` (Windows)
2. If not found, add Godot to your PATH (see installation steps above)
3. Or use the full path in start script:
   ```bash
   # Edit start-bridge.sh
   /full/path/to/godot --headless --path ./godot-bridge bridge_server.tscn
   ```

### Problem: "Port 8765 already in use"

**Solution:**
1. Find what's using the port:
   ```bash
   # Linux/Mac
   lsof -i :8765

   # Windows
   netstat -ano | findstr :8765
   ```
2. Kill the process or change the port in `godot-bridge/bridge_server.gd`:
   ```gdscript
   const PORT = 8766  # Change to different port
   ```

### Problem: "Module 'mcp' not found"

**Solution:**
```bash
pip install mcp
# or
pip install --upgrade mcp
```

### Problem: Claude doesn't see the MCP server

**Solution:**
1. Check the configuration file path is correct
2. Verify the absolute path in the config is correct
3. Make sure there are no syntax errors in the JSON
4. Restart Claude Desktop completely (not just the window)
5. Check Claude's logs for errors:
   - macOS: `~/Library/Logs/Claude/`
   - Windows: `%APPDATA%\Claude\logs\`

### Problem: Godot Bridge won't start

**Solution:**
1. Check for errors in the console output
2. Try running without `--headless` to see GUI errors:
   ```bash
   cd godot-bridge
   godot --path . bridge_server.tscn
   ```
3. Verify all `.gd` files are present
4. Check `project.godot` exists

### Problem: "Connection refused" from MCP server

**Solution:**
1. Ensure Godot Bridge is running first
2. Test the connection manually:
   ```bash
   curl http://127.0.0.1:8765/health
   ```
3. Check firewall settings
4. Verify the port number matches

### Problem: Scenes not saving

**Solution:**
1. Use Godot resource paths: `res://path/to/file.tscn`
2. Check file permissions
3. Ensure the directory exists (it should be created automatically)
4. Try saving to a simpler path: `res://test.tscn`

---

## ✅ Verification Checklist

Before using the MCP server, verify:

- [ ] Godot 4.x is installed and in PATH
- [ ] Python 3.8+ is installed
- [ ] Python dependencies are installed (mcp, httpx, pydantic)
- [ ] Godot Bridge Server starts without errors
- [ ] Server shows "Waiting for connections..." message
- [ ] Claude configuration file has correct absolute path
- [ ] Claude Desktop has been restarted
- [ ] MCP server appears in Claude's tools/server list
- [ ] Test command returns expected results

---

## 🎮 First Game Tutorial

Once setup is complete, try this tutorial:

### Create a Simple 2D Platformer

**Step 1:** Ask Claude:
```
Create a new 2D scene called "Platformer" and save it as res://platformer.tscn
```

**Step 2:** Add a player:
```
Create a CharacterBody2D node called "Player" in the Platformer scene
```

**Step 3:** Add a sprite:
```
Create a Sprite2D node called "PlayerSprite" as a child of Player
```

**Step 4:** Create movement script:
```
Create a GDScript file at res://player.gd using the CharacterBody2D template,
then attach it to the Player node
```

**Step 5:** Add ground:
```
Create a StaticBody2D called "Ground" with position at y=500
```

**Step 6:** Save everything:
```
Save the current scene
```

**Step 7:** Test it:
```
Run the scene and capture a screenshot
```

---

## 🆘 Getting Help

If you're still having issues:

1. **Check the documentation:**
   - README.md - Project overview
   - docs/ARCHITECTURE.md - Technical details
   - docs/QUICK_START.md - Quick reference
   - docs/EXAMPLES.md - Game examples

2. **Review error messages:**
   - Godot Bridge: Check terminal output
   - MCP Server: Check Claude logs
   - Python: Check pip install output

3. **Test components individually:**
   - Test Godot: `godot --version`
   - Test Python: `python --version`
   - Test dependencies: `pip list`
   - Test Bridge: `curl http://127.0.0.1:8765/health`

4. **Common issues:**
   - Wrong Python version (need 3.8+)
   - Wrong Godot version (need 4.x)
   - Incorrect absolute paths in config
   - Bridge server not running
   - Firewall blocking connections

---

## 🎉 You're Ready!

If all verification steps passed, you're ready to create games with Claude!

Try asking Claude:
- "Create a 2D platformer game"
- "Build a 3D room with CSG shapes"
- "Make a top-down shooter"
- "Create a simple puzzle game"

Check out **docs/EXAMPLES.md** for 10+ complete game examples!

**Happy game development! 🎮**
