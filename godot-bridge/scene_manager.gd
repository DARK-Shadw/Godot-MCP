extends Node
class_name SceneManager

## Handles scene creation, loading, saving, and management

var current_scene_root: Node = null
var current_scene_path: String = ""
var editor_interface: EditorInterface = null

func _ready():
	print("SceneManager initialized")
	# Try to get EditorInterface (only available when running in editor)
	if Engine.is_editor_hint():
		editor_interface = EditorScript.new().get_editor_interface()
		print("EditorInterface available")
	else:
		print("Running outside editor - EditorInterface not available")

func create_scene(params: Dictionary) -> Dictionary:
	"""
	Create a new empty scene
	Params:
		- scene_name: String (required)
		- scene_type: String "2D" or "3D" (default: "2D")
	"""
	var scene_name = params.get("scene_name", "")
	var scene_type = params.get("scene_type", "2D")

	if scene_name == "":
		return _error("scene_name is required")

	# Create root node based on type
	var root_node: Node
	if scene_type == "3D":
		root_node = Node3D.new()
		root_node.name = scene_name
	elif scene_type == "2D":
		root_node = Node2D.new()
		root_node.name = scene_name
	else:
		return _error("scene_type must be '2D' or '3D'")

	# Clear current scene if exists
	if current_scene_root:
		current_scene_root.queue_free()
		current_scene_root = null

	# Add new scene root
	add_child(root_node)
	current_scene_root = root_node
	current_scene_path = "res://scenes/%s.tscn" % scene_name

	return _success({
		"scene_path": current_scene_path,
		"scene_type": scene_type,
		"root_node": root_node.get_path()
	})

func load_scene(params: Dictionary) -> Dictionary:
	"""
	Load an existing scene
	Params:
		- scene_path: String (required)
	"""
	var scene_path = params.get("scene_path", "")

	if scene_path == "":
		return _error("scene_path is required")

	# Check if file exists
	if not FileAccess.file_exists(scene_path):
		return _error("Scene file not found: %s" % scene_path)

	# Load the scene
	var packed_scene = load(scene_path)
	if not packed_scene:
		return _error("Failed to load scene: %s" % scene_path)

	# Instantiate the scene
	var scene_instance = packed_scene.instantiate()
	if not scene_instance:
		return _error("Failed to instantiate scene")

	# Clear current scene if exists
	if current_scene_root:
		current_scene_root.queue_free()
		current_scene_root = null

	# Add new scene
	add_child(scene_instance)
	current_scene_root = scene_instance
	current_scene_path = scene_path

	return _success({
		"scene_path": scene_path,
		"root_node": scene_instance.get_path(),
		"tree": _get_node_tree(scene_instance)
	})

func save_scene(params: Dictionary) -> Dictionary:
	"""
	Save current scene
	Params:
		- scene_path: String (optional - uses current path if not specified)
	"""
	var scene_path = params.get("scene_path", current_scene_path)

	if scene_path == "":
		return _error("No scene path specified and no current scene")

	if not current_scene_root:
		return _error("No scene to save")

	# Ensure directory exists
	var dir_path = scene_path.get_base_dir()
	if not DirAccess.dir_exists_absolute(dir_path):
		DirAccess.make_dir_recursive_absolute(dir_path)

	# Create a PackedScene and pack the current scene
	var packed_scene = PackedScene.new()
	var result = packed_scene.pack(current_scene_root)

	if result != OK:
		return _error("Failed to pack scene: error code %d" % result)

	# Save the packed scene
	result = ResourceSaver.save(packed_scene, scene_path)

	if result != OK:
		return _error("Failed to save scene: error code %d" % result)

	current_scene_path = scene_path

	return _success({
		"scene_path": scene_path,
		"message": "Scene saved successfully"
	})

func get_scene_tree(params: Dictionary) -> Dictionary:
	"""
	Get current scene tree structure
	"""
	if not current_scene_root:
		return _error("No scene loaded")

	var tree = _get_node_tree(current_scene_root)

	return _success({
		"scene_path": current_scene_path,
		"tree": tree
	})

func _get_node_tree(node: Node) -> Dictionary:
	"""Recursively build scene tree structure"""
	var tree = {
		"name": node.name,
		"type": node.get_class(),
		"path": str(node.get_path()),
		"children": []
	}

	# Add transform info if applicable
	if node is Node2D:
		tree["position"] = var_to_str(node.position)
		tree["rotation"] = node.rotation
		tree["scale"] = var_to_str(node.scale)
	elif node is Node3D:
		tree["position"] = var_to_str(node.position)
		tree["rotation"] = var_to_str(node.rotation)
		tree["scale"] = var_to_str(node.scale)

	# Add script info if node has a script
	if node.get_script():
		tree["script"] = node.get_script().resource_path

	# Recursively add children
	for child in node.get_children():
		tree["children"].append(_get_node_tree(child))

	return tree

func get_current_scene_root() -> Node:
	"""Get the current scene root node"""
	return current_scene_root

func _success(data: Dictionary) -> Dictionary:
	"""Helper to create success response"""
	data["status"] = "success"
	data["code"] = 200
	return data

func _error(message: String, code: int = 400) -> Dictionary:
	"""Helper to create error response"""
	return {
		"status": "error",
		"error": message,
		"code": code
	}
