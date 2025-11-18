extends Node
class_name ScriptManager

## Handles script creation, modification, and attachment to nodes

var scene_manager = null

func _ready():
	print("ScriptManager initialized")
	await get_tree().process_frame
	scene_manager = get_parent().scene_manager

func create_script(params: Dictionary) -> Dictionary:
	"""
	Create a new GDScript file
	Params:
		- script_path: String (required) - e.g., "res://scripts/player.gd"
		- script_content: String (required) - the GDScript code
		- template: String (optional) - "node", "node2d", "node3d", "resource", "custom"
	"""
	var script_path = params.get("script_path", "")
	var script_content = params.get("script_content", "")
	var template = params.get("template", "")

	if script_path == "":
		return _error("script_path is required")

	# Ensure directory exists
	var dir_path = script_path.get_base_dir()
	if not DirAccess.dir_exists_absolute(dir_path):
		DirAccess.make_dir_recursive_absolute(dir_path)

	# If no content provided, use template
	if script_content == "":
		script_content = _get_template(template)

	# Write script file
	var file = FileAccess.open(script_path, FileAccess.WRITE)
	if not file:
		return _error("Failed to create script file: %s" % script_path)

	file.store_string(script_content)
	file.close()

	return _success({
		"script_path": script_path,
		"template": template,
		"size": script_content.length()
	})

func attach_script(params: Dictionary) -> Dictionary:
	"""
	Attach a script to a node
	Params:
		- node_path: String (required)
		- script_path: String (required)
	"""
	var node_path = params.get("node_path", "")
	var script_path = params.get("script_path", "")

	if node_path == "":
		return _error("node_path is required")
	if script_path == "":
		return _error("script_path is required")

	# Get the node
	var node = _get_node(node_path)
	if not node:
		return _error("Node not found: %s" % node_path)

	# Check if script file exists
	if not FileAccess.file_exists(script_path):
		return _error("Script file not found: %s" % script_path)

	# Load the script
	var script = load(script_path)
	if not script:
		return _error("Failed to load script: %s" % script_path)

	# Attach to node
	node.set_script(script)

	return _success({
		"node_path": node_path,
		"script_path": script_path,
		"attached": true
	})

func update_script(params: Dictionary) -> Dictionary:
	"""
	Update an existing script file
	Params:
		- script_path: String (required)
		- script_content: String (required)
	"""
	var script_path = params.get("script_path", "")
	var script_content = params.get("script_content", "")

	if script_path == "":
		return _error("script_path is required")
	if script_content == "":
		return _error("script_content is required")

	# Write script file
	var file = FileAccess.open(script_path, FileAccess.WRITE)
	if not file:
		return _error("Failed to open script file: %s" % script_path)

	file.store_string(script_content)
	file.close()

	# Reload the script if it's already loaded
	var script = load(script_path)
	if script:
		script.reload()

	return _success({
		"script_path": script_path,
		"size": script_content.length(),
		"updated": true
	})

func _get_template(template_type: String) -> String:
	"""Get script template"""
	match template_type:
		"node":
			return """extends Node

func _ready():
\tpass

func _process(delta):
\tpass
"""
		"node2d":
			return """extends Node2D

func _ready():
\tpass

func _process(delta):
\tpass
"""
		"node3d":
			return """extends Node3D

func _ready():
\tpass

func _process(delta):
\tpass
"""
		"rigidbody2d":
			return """extends RigidBody2D

func _ready():
\tpass

func _process(delta):
\tpass

func _physics_process(delta):
\tpass
"""
		"rigidbody3d":
			return """extends RigidBody3D

func _ready():
\tpass

func _process(delta):
\tpass

func _physics_process(delta):
\tpass
"""
		"characterbody2d":
			return """extends CharacterBody2D

const SPEED = 300.0

func _physics_process(delta):
\tvar direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
\tvelocity = direction * SPEED
\tmove_and_slide()
"""
		"characterbody3d":
			return """extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _physics_process(delta):
\t# Add the gravity.
\tif not is_on_floor():
\t\tvelocity.y -= gravity * delta
\t
\t# Handle jump.
\tif Input.is_action_just_pressed("ui_accept") and is_on_floor():
\t\tvelocity.y = JUMP_VELOCITY
\t
\t# Get the input direction and handle the movement/deceleration.
\tvar input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
\tvar direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
\tif direction:
\t\tvelocity.x = direction.x * SPEED
\t\tvelocity.z = direction.z * SPEED
\telse:
\t\tvelocity.x = move_toward(velocity.x, 0, SPEED)
\t\tvelocity.z = move_toward(velocity.z, 0, SPEED)
\t
\tmove_and_slide()
"""
		"resource":
			return """extends Resource
class_name CustomResource

@export var value: int = 0
"""
		_:
			return """extends Node

func _ready():
\tpass
"""

func _get_node(node_path: String) -> Node:
	"""Get node by path"""
	var scene_root = scene_manager.get_current_scene_root()
	if not scene_root:
		return null

	if node_path.begins_with("/root/"):
		return get_tree().root.get_node_or_null(node_path)

	return scene_root.get_node_or_null(node_path)

func _success(data: Dictionary) -> Dictionary:
	data["status"] = "success"
	data["code"] = 200
	return data

func _error(message: String, code: int = 400) -> Dictionary:
	return {
		"status": "error",
		"error": message,
		"code": code
	}
