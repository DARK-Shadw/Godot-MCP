extends Node
class_name NodeManager

## Handles node creation, deletion, property manipulation, and hierarchy management

var scene_manager = null

func _ready():
	print("NodeManager initialized")
	# Get reference to SceneManager
	await get_tree().process_frame  # Wait for parent to finish setup
	scene_manager = get_parent().scene_manager

func create_node(params: Dictionary) -> Dictionary:
	"""
	Create a new node
	Params:
		- node_type: String (required) - e.g., "Node2D", "Sprite2D", "Node3D", etc.
		- node_name: String (required)
		- parent_path: String (optional) - path to parent node, defaults to scene root
	"""
	var node_type = params.get("node_type", "")
	var node_name = params.get("node_name", "")
	var parent_path = params.get("parent_path", "")

	if node_type == "":
		return _error("node_type is required")
	if node_name == "":
		return _error("node_name is required")

	# Get parent node
	var parent_node = _get_parent_node(parent_path)
	if not parent_node:
		return _error("Parent node not found: %s" % parent_path)

	# Check if ClassDB has this type
	if not ClassDB.class_exists(node_type):
		return _error("Unknown node type: %s" % node_type)

	# Check if type is a Node subclass
	if not ClassDB.is_parent_class(node_type, "Node"):
		return _error("Type %s is not a Node subclass" % node_type)

	# Create the node
	var new_node = ClassDB.instantiate(node_type) as Node
	if not new_node:
		return _error("Failed to instantiate node of type: %s" % node_type)

	new_node.name = node_name

	# Add to parent
	parent_node.add_child(new_node)
	new_node.owner = parent_node.get_tree().edited_scene_root if parent_node.get_tree().edited_scene_root else parent_node

	return _success({
		"node_path": str(new_node.get_path()),
		"node_type": node_type,
		"node_name": node_name,
		"parent": str(parent_node.get_path())
	})

func delete_node(params: Dictionary) -> Dictionary:
	"""
	Delete a node
	Params:
		- node_path: String (required)
	"""
	var node_path = params.get("node_path", "")

	if node_path == "":
		return _error("node_path is required")

	var node = _get_node(node_path)
	if not node:
		return _error("Node not found: %s" % node_path)

	# Don't allow deleting the scene root
	if node == scene_manager.get_current_scene_root():
		return _error("Cannot delete scene root")

	var parent_path = str(node.get_parent().get_path())
	node.queue_free()

	return _success({
		"message": "Node deleted",
		"deleted_path": node_path,
		"parent": parent_path
	})

func set_node_property(params: Dictionary) -> Dictionary:
	"""
	Set a property on a node
	Params:
		- node_path: String (required)
		- property: String (required)
		- value: Any (required)
	"""
	var node_path = params.get("node_path", "")
	var property = params.get("property", "")
	var value = params.get("value")

	if node_path == "":
		return _error("node_path is required")
	if property == "":
		return _error("property is required")
	if value == null:
		return _error("value is required")

	var node = _get_node(node_path)
	if not node:
		return _error("Node not found: %s" % node_path)

	# Check if property exists
	if not property in node:
		return _error("Property '%s' does not exist on node of type %s" % [property, node.get_class()])

	# Convert value if needed
	var converted_value = _convert_value(value, node.get(property))

	# Set the property
	node.set(property, converted_value)

	return _success({
		"node_path": node_path,
		"property": property,
		"value": var_to_str(converted_value)
	})

func get_node_property(params: Dictionary) -> Dictionary:
	"""
	Get a property from a node
	Params:
		- node_path: String (required)
		- property: String (required)
	"""
	var node_path = params.get("node_path", "")
	var property = params.get("property", "")

	if node_path == "":
		return _error("node_path is required")
	if property == "":
		return _error("property is required")

	var node = _get_node(node_path)
	if not node:
		return _error("Node not found: %s" % node_path)

	# Check if property exists
	if not property in node:
		return _error("Property '%s' does not exist on node" % property)

	var value = node.get(property)

	return _success({
		"node_path": node_path,
		"property": property,
		"value": var_to_str(value),
		"type": typeof(value)
	})

func move_node(params: Dictionary) -> Dictionary:
	"""
	Move a node to a new parent
	Params:
		- node_path: String (required)
		- new_parent: String (required)
	"""
	var node_path = params.get("node_path", "")
	var new_parent_path = params.get("new_parent", "")

	if node_path == "":
		return _error("node_path is required")
	if new_parent_path == "":
		return _error("new_parent is required")

	var node = _get_node(node_path)
	if not node:
		return _error("Node not found: %s" % node_path)

	var new_parent = _get_node(new_parent_path)
	if not new_parent:
		return _error("New parent not found: %s" % new_parent_path)

	# Remove from old parent
	var old_parent = node.get_parent()
	old_parent.remove_child(node)

	# Add to new parent
	new_parent.add_child(node)
	node.owner = new_parent.get_tree().edited_scene_root if new_parent.get_tree().edited_scene_root else new_parent

	return _success({
		"node_path": str(node.get_path()),
		"old_parent": str(old_parent.get_path()),
		"new_parent": str(new_parent.get_path())
	})

func set_node_transform(params: Dictionary) -> Dictionary:
	"""
	Set node transform (position, rotation, scale)
	Params:
		- node_path: String (required)
		- position: Vector2/Vector3 (optional)
		- rotation: float/Vector3 (optional)
		- scale: Vector2/Vector3 (optional)
	"""
	var node_path = params.get("node_path", "")

	if node_path == "":
		return _error("node_path is required")

	var node = _get_node(node_path)
	if not node:
		return _error("Node not found: %s" % node_path)

	# Check node type
	if node is Node2D:
		if "position" in params:
			var pos = params.position
			if typeof(pos) == TYPE_DICTIONARY:
				node.position = Vector2(pos.get("x", 0), pos.get("y", 0))
			elif typeof(pos) == TYPE_ARRAY and pos.size() >= 2:
				node.position = Vector2(pos[0], pos[1])

		if "rotation" in params:
			node.rotation = float(params.rotation)

		if "scale" in params:
			var scl = params.scale
			if typeof(scl) == TYPE_DICTIONARY:
				node.scale = Vector2(scl.get("x", 1), scl.get("y", 1))
			elif typeof(scl) == TYPE_ARRAY and scl.size() >= 2:
				node.scale = Vector2(scl[0], scl[1])

	elif node is Node3D:
		if "position" in params:
			var pos = params.position
			if typeof(pos) == TYPE_DICTIONARY:
				node.position = Vector3(pos.get("x", 0), pos.get("y", 0), pos.get("z", 0))
			elif typeof(pos) == TYPE_ARRAY and pos.size() >= 3:
				node.position = Vector3(pos[0], pos[1], pos[2])

		if "rotation" in params:
			var rot = params.rotation
			if typeof(rot) == TYPE_DICTIONARY:
				node.rotation = Vector3(rot.get("x", 0), rot.get("y", 0), rot.get("z", 0))
			elif typeof(rot) == TYPE_ARRAY and rot.size() >= 3:
				node.rotation = Vector3(rot[0], rot[1], rot[2])
			elif typeof(rot) == TYPE_FLOAT or typeof(rot) == TYPE_INT:
				# Single rotation value - apply to Y axis
				node.rotation.y = float(rot)

		if "scale" in params:
			var scl = params.scale
			if typeof(scl) == TYPE_DICTIONARY:
				node.scale = Vector3(scl.get("x", 1), scl.get("y", 1), scl.get("z", 1))
			elif typeof(scl) == TYPE_ARRAY and scl.size() >= 3:
				node.scale = Vector3(scl[0], scl[1], scl[2])

	else:
		return _error("Node is not Node2D or Node3D, cannot set transform")

	return _success({
		"node_path": node_path,
		"transform_set": true
	})

func list_available_nodes(params: Dictionary) -> Dictionary:
	"""
	List all available node types
	Params:
		- filter: String (optional) - "2D", "3D", "Control", or empty for all
	"""
	var filter_type = params.get("filter", "")
	var class_list = ClassDB.get_class_list()
	var node_classes = []

	for class_name in class_list:
		# Only include Node subclasses
		if not ClassDB.is_parent_class(class_name, "Node"):
			continue

		# Apply filter
		if filter_type == "2D" and not ClassDB.is_parent_class(class_name, "Node2D"):
			continue
		elif filter_type == "3D" and not ClassDB.is_parent_class(class_name, "Node3D"):
			continue
		elif filter_type == "Control" and not ClassDB.is_parent_class(class_name, "Control"):
			continue

		node_classes.append(class_name)

	node_classes.sort()

	return _success({
		"count": node_classes.size(),
		"filter": filter_type,
		"nodes": node_classes
	})

func get_node_documentation(params: Dictionary) -> Dictionary:
	"""
	Get documentation for a node type
	Params:
		- node_type: String (required)
	"""
	var node_type = params.get("node_type", "")

	if node_type == "":
		return _error("node_type is required")

	if not ClassDB.class_exists(node_type):
		return _error("Unknown class: %s" % node_type)

	# Get class info
	var parent = ClassDB.get_parent_class(node_type)
	var methods = ClassDB.class_get_method_list(node_type, true)
	var properties = ClassDB.class_get_property_list(node_type, true)

	return _success({
		"class_name": node_type,
		"parent_class": parent,
		"method_count": methods.size(),
		"property_count": properties.size()
	})

func _get_node(node_path: String) -> Node:
	"""Get node by path"""
	var scene_root = scene_manager.get_current_scene_root()
	if not scene_root:
		return null

	# If path starts with scene root name, get it directly
	if node_path.begins_with("/root/"):
		return get_tree().root.get_node_or_null(node_path)

	# Otherwise, get relative to scene root
	return scene_root.get_node_or_null(node_path)

func _get_parent_node(parent_path: String) -> Node:
	"""Get parent node, defaults to scene root if empty"""
	if parent_path == "":
		return scene_manager.get_current_scene_root()
	return _get_node(parent_path)

func _convert_value(value: Variant, target_value: Variant) -> Variant:
	"""Convert value to match target type"""
	var target_type = typeof(target_value)

	# If value is already correct type, return as-is
	if typeof(value) == target_type:
		return value

	# Handle Vector2/Vector3 from dictionary or array
	if target_type == TYPE_VECTOR2:
		if typeof(value) == TYPE_DICTIONARY:
			return Vector2(value.get("x", 0), value.get("y", 0))
		elif typeof(value) == TYPE_ARRAY and value.size() >= 2:
			return Vector2(value[0], value[1])
	elif target_type == TYPE_VECTOR3:
		if typeof(value) == TYPE_DICTIONARY:
			return Vector3(value.get("x", 0), value.get("y", 0), value.get("z", 0))
		elif typeof(value) == TYPE_ARRAY and value.size() >= 3:
			return Vector3(value[0], value[1], value[2])

	# Handle Color from dictionary or array
	elif target_type == TYPE_COLOR:
		if typeof(value) == TYPE_DICTIONARY:
			return Color(value.get("r", 0), value.get("g", 0), value.get("b", 0), value.get("a", 1))
		elif typeof(value) == TYPE_ARRAY and value.size() >= 3:
			if value.size() == 3:
				return Color(value[0], value[1], value[2])
			else:
				return Color(value[0], value[1], value[2], value[3])
		elif typeof(value) == TYPE_STRING:
			return Color(value)

	# Default: try to convert using Godot's type conversion
	return value

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
