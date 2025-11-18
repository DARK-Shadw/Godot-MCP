# Example Game Workflows

Complete examples of creating different types of games with the Godot MCP Server.

## Example 1: Simple 2D Platformer

### Goal
Create a basic platformer with a player character that can move and jump.

### Prompt for Claude:

```
I want to create a 2D platformer game. Please:

1. Create a new 2D scene called "Platformer"
2. Add a CharacterBody2D node named "Player"
3. Add a Sprite2D child to the Player for visualization (use a colored rectangle)
4. Create a movement script with:
   - WASD or Arrow key movement
   - Jump with Space
   - Gravity
5. Add a StaticBody2D ground platform at the bottom
6. Save the scene as res://scenes/platformer.tscn
7. Run the scene and capture a screenshot
```

### Expected Tools Used:
1. `create_scene(scene_name="Platformer", scene_type="2D")`
2. `create_node(node_type="CharacterBody2D", node_name="Player")`
3. `create_node(node_type="Sprite2D", node_name="PlayerSprite", parent_path="Player")`
4. `create_script(script_path="res://scripts/player.gd", template="characterbody2d")`
5. `attach_script(node_path="Player", script_path="res://scripts/player.gd")`
6. `create_node(node_type="StaticBody2D", node_name="Ground")`
7. `save_scene(scene_path="res://scenes/platformer.tscn")`
8. `run_scene()`
9. `capture_screenshot()`

## Example 2: 3D Room with CSG

### Goal
Create a 3D room using CSG shapes.

### Prompt for Claude:

```
Create a 3D scene with a room made from CSG shapes:

1. Create a new 3D scene called "Room"
2. Create a CSG box for the floor (10x1x10 units)
3. Create 4 CSG boxes for the walls
4. Create a CSG box for the ceiling
5. Add a DirectionalLight3D for lighting
6. Add a Camera3D positioned to view the room
7. Give the floor a different color than the walls
8. Save as res://scenes/room.tscn
```

### Expected Tools Used:
1. `create_scene(scene_name="Room", scene_type="3D")`
2. `create_csg_shape(shape_type="box", properties={size: {x:10,y:1,z:10}, name:"Floor", material:{color:{r:0.3,g:0.3,b:0.3}}})`
3. `create_csg_shape(...)` x4 for walls
4. `create_csg_shape(...)` for ceiling
5. `create_node(node_type="DirectionalLight3D", node_name="Sun")`
6. `create_node(node_type="Camera3D", node_name="Camera")`
7. `set_node_transform(node_path="Camera", position={x:0,y:5,z:10})`
8. `save_scene(scene_path="res://scenes/room.tscn")`

## Example 3: Top-Down Shooter

### Goal
Create a top-down view game with a player that rotates to face the mouse.

### Prompt for Claude:

```
Create a top-down shooter game:

1. Create a new 2D scene called "Shooter"
2. Add a CharacterBody2D for the player
3. Add a Sprite2D for the player (triangle shape pointing up)
4. Create a script that:
   - Moves the player with WASD
   - Rotates to face the mouse cursor
   - Has smooth movement
5. Add a Camera2D that follows the player
6. Save as res://scenes/shooter.tscn
```

### Script Example:

```gdscript
extends CharacterBody2D

const SPEED = 300.0

func _physics_process(delta):
    # Get movement direction
    var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
    velocity = direction * SPEED

    # Rotate to face mouse
    var mouse_pos = get_global_mouse_position()
    look_at(mouse_pos)

    move_and_slide()
```

## Example 4: 3D First-Person Controller

### Goal
Create a first-person controller that can walk around.

### Prompt for Claude:

```
Create a 3D first-person game:

1. Create a new 3D scene called "FPS"
2. Add a CharacterBody3D for the player
3. Add a Camera3D as a child of the player (positioned at head height)
4. Create a script for first-person movement:
   - WASD movement
   - Mouse look (rotate camera)
   - Jump with Space
   - Gravity
5. Create a CSG box floor (20x1x20)
6. Add some CSG boxes as obstacles
7. Save as res://scenes/fps.tscn
```

## Example 5: Puzzle Game

### Goal
Create a simple grid-based puzzle game.

### Prompt for Claude:

```
Create a tile-based puzzle game:

1. Create a 2D scene called "Puzzle"
2. Create a grid of Sprite2D nodes (5x5) representing tiles
3. Each tile should be a colored square
4. Create a player sprite that can move between tiles
5. Create a script that:
   - Handles arrow key input to move between tiles
   - Snaps movement to grid positions
   - Prevents moving off the grid
6. Save as res://scenes/puzzle.tscn
```

## Example 6: Racing Game (Top-Down)

### Goal
Create a simple top-down racing game.

### Prompt for Claude:

```
Create a top-down racing game:

1. Create a 2D scene called "Racing"
2. Add a RigidBody2D for the car (with car physics)
3. Add a Sprite2D for the car visualization
4. Create a script that:
   - Accelerates with Up arrow
   - Steers with Left/Right arrows
   - Uses physics for realistic movement
   - Has friction and drag
5. Create a simple track using StaticBody2D nodes
6. Add a Camera2D that follows the car
7. Save as res://scenes/racing.tscn
```

## Example 7: Inventory System

### Goal
Create an inventory UI system.

### Prompt for Claude:

```
Create an inventory system UI:

1. Create a 2D scene called "Inventory"
2. Add a Control node as root
3. Create a grid of TextureRect nodes for inventory slots (4x3)
4. Add labels for "Inventory" title
5. Create a script that manages:
   - Item data structure
   - Adding/removing items
   - Displaying items in slots
6. Save as res://scenes/inventory.tscn
```

## Example 8: Particle Effects Test

### Goal
Create a scene with various particle effects.

### Prompt for Claude:

```
Create a particle effects demonstration:

1. Create a 2D scene called "Particles"
2. Add several GPUParticles2D nodes with different effects:
   - Fire effect
   - Rain effect
   - Explosion effect
3. Configure each particle system's properties
4. Add buttons to trigger different effects
5. Save as res://scenes/particles.tscn
```

## Example 9: Dialogue System

### Goal
Create a simple dialogue system.

### Prompt for Claude:

```
Create a dialogue system:

1. Create a 2D scene called "Dialogue"
2. Add Control nodes for the dialogue UI:
   - Panel for dialogue box
   - RichTextLabel for text
   - Buttons for choices
3. Create a script that:
   - Displays dialogue text
   - Handles multiple choice options
   - Progresses through conversation
4. Save as res://scenes/dialogue.tscn
```

## Example 10: Tower Defense

### Goal
Create a basic tower defense game setup.

### Prompt for Claude:

```
Create a tower defense game foundation:

1. Create a 2D scene called "TowerDefense"
2. Create a path for enemies using Line2D or Path2D
3. Add a StaticBody2D as a tower placement spot
4. Create an enemy CharacterBody2D that follows the path
5. Create a tower script that:
   - Detects enemies in range
   - Rotates to face enemies
   - Shoots projectiles
6. Save as res://scenes/tower_defense.tscn
```

## Tips for Each Game Type

### 2D Platformers
- Use CharacterBody2D for the player
- Use StaticBody2D for platforms
- Add Area2D for collectibles
- Use TileMap for level design

### 3D Games
- Use Node3D hierarchy properly
- Add DirectionalLight3D for sun
- Use OmniLight3D for point lights
- Add WorldEnvironment for sky/ambient

### Physics Games
- Use RigidBody2D/3D for physics objects
- Configure mass, friction, bounce
- Use PhysicsMaterial for properties
- Apply forces, not direct movement

### UI Games
- Use Control nodes for UI
- Use Containers (VBox, HBox, Grid) for layout
- Use Anchors for responsive design
- Connect signals for interactivity

## Testing Your Games

After creating a game, always:

1. **Run the scene**
   ```
   "Run the current scene"
   ```

2. **Test input**
   ```
   "Send a key press for 'W' to test movement"
   ```

3. **Capture screenshot**
   ```
   "Take a screenshot of the running game"
   ```

4. **Iterate**
   ```
   "Modify the player script to increase movement speed"
   ```

## Advanced Techniques

### Creating Custom Node Hierarchies

```
Create a scene with this structure:
- Player (CharacterBody2D)
  - Sprite (Sprite2D)
  - CollisionShape (CollisionShape2D)
  - Camera (Camera2D)
  - Weapon (Node2D)
    - BulletSpawnPoint (Marker2D)
```

### Using Signals

```
Create a script that:
1. Defines a custom signal 'player_died'
2. Emits the signal when health reaches 0
3. Connects to show a game over screen
```

### Resource Management

```
Create a system that:
1. Loads textures dynamically
2. Creates sprite nodes from textures
3. Manages a resource pool
```

## Common Patterns

### Singleton Pattern
```gdscript
# Create an autoload script for global state
extends Node

var score: int = 0
var player_health: int = 100

func reset_game():
    score = 0
    player_health = 100
```

### Object Pooling
```gdscript
# Create a pool of reusable objects
var pool: Array[Node] = []

func get_object():
    if pool.is_empty():
        return create_new()
    return pool.pop_back()

func return_object(obj: Node):
    pool.append(obj)
```

### State Machine
```gdscript
# Create a state machine for game states
enum State { IDLE, WALKING, JUMPING, ATTACKING }
var current_state: State = State.IDLE

func change_state(new_state: State):
    current_state = new_state
```

## Next Steps

1. **Combine Examples:** Mix and match features from different examples
2. **Add Polish:** Add sounds, particles, screen shake, etc.
3. **Export Your Game:** Use Godot's export system to build your game
4. **Share:** Export for web, desktop, or mobile!

---

**Keep experimenting and have fun creating games! 🎮**
