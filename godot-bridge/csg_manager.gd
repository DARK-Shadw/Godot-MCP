extends Node
class_name CSGManager

## Handles CSG (Constructive Solid Geometry) shape creation and operations

var scene_manager: SceneManager = null

func _ready():
	print("CSGManager initialized")
	await get_tree().process_frame
	scene_manager = get_parent().scene_manager

func create_csg_shape(params: Dictionary) -> Dictionary:
	"""
	Create a CSG shape
	Params:
		- shape_type: String (required) - "box", "sphere", "cylinder", "torus", "polygon", "mesh", "combiner"
		- properties: Dictionary (optional) - shape-specific properties
		- parent_path: String (optional) - parent node path
	"""
	var shape_type = params.get("shape_type", "")
	var properties = params.get("properties", {})
	var parent_path = params.get("parent_path", "")

	if shape_type == "":
		return _error("shape_type is required")

	# Get parent node
	var parent_node = _get_parent_node(parent_path)
	if not parent_node:
		return _error("Parent node not found: %s" % parent_path)

	# Create the appropriate CSG shape
	var csg_node: Node3D
	var node_name = properties.get("name", "CSG%s" % shape_type.capitalize())

	match shape_type.to_lower():
		"box":
			csg_node = CSGBox3D.new()
			csg_node.name = node_name
			if "size" in properties:
				var size = properties.size
				if typeof(size) == TYPE_DICTIONARY:
					csg_node.size = Vector3(size.get("x", 1), size.get("y", 1), size.get("z", 1))
				elif typeof(size) == TYPE_ARRAY and size.size() >= 3:
					csg_node.size = Vector3(size[0], size[1], size[2])

		"sphere":
			csg_node = CSGSphere3D.new()
			csg_node.name = node_name
			if "radius" in properties:
				csg_node.radius = float(properties.radius)
			if "radial_segments" in properties:
				csg_node.radial_segments = int(properties.radial_segments)
			if "rings" in properties:
				csg_node.rings = int(properties.rings)

		"cylinder":
			csg_node = CSGCylinder3D.new()
			csg_node.name = node_name
			if "radius" in properties:
				csg_node.radius = float(properties.radius)
			if "height" in properties:
				csg_node.height = float(properties.height)
			if "sides" in properties:
				csg_node.sides = int(properties.sides)
			if "cone" in properties:
				csg_node.cone = bool(properties.cone)

		"torus":
			csg_node = CSGTorus3D.new()
			csg_node.name = node_name
			if "inner_radius" in properties:
				csg_node.inner_radius = float(properties.inner_radius)
			if "outer_radius" in properties:
				csg_node.outer_radius = float(properties.outer_radius)
			if "sides" in properties:
				csg_node.sides = int(properties.sides)
			if "ring_sides" in properties:
				csg_node.ring_sides = int(properties.ring_sides)

		"polygon":
			csg_node = CSGPolygon3D.new()
			csg_node.name = node_name
			# Note: Polygon requires a polygon path to be set separately
			if "depth" in properties:
				csg_node.depth = float(properties.depth)

		"mesh":
			csg_node = CSGMesh3D.new()
			csg_node.name = node_name
			# Note: Mesh requires a mesh resource to be set

		"combiner":
			csg_node = CSGCombiner3D.new()
			csg_node.name = node_name

		_:
			return _error("Unknown CSG shape type: %s" % shape_type)

	# Set common properties
	if "operation" in properties:
		_set_operation(csg_node, properties.operation)

	if "use_collision" in properties:
		csg_node.use_collision = bool(properties.use_collision)

	# Set transform if provided
	if "position" in properties:
		var pos = properties.position
		if typeof(pos) == TYPE_DICTIONARY:
			csg_node.position = Vector3(pos.get("x", 0), pos.get("y", 0), pos.get("z", 0))
		elif typeof(pos) == TYPE_ARRAY and pos.size() >= 3:
			csg_node.position = Vector3(pos[0], pos[1], pos[2])

	if "rotation" in properties:
		var rot = properties.rotation
		if typeof(rot) == TYPE_DICTIONARY:
			csg_node.rotation = Vector3(rot.get("x", 0), rot.get("y", 0), rot.get("z", 0))
		elif typeof(rot) == TYPE_ARRAY and rot.size() >= 3:
			csg_node.rotation = Vector3(rot[0], rot[1], rot[2])

	if "scale" in properties:
		var scl = properties.scale
		if typeof(scl) == TYPE_DICTIONARY:
			csg_node.scale = Vector3(scl.get("x", 1), scl.get("y", 1), scl.get("z", 1))
		elif typeof(scl) == TYPE_ARRAY and scl.size() >= 3:
			csg_node.scale = Vector3(scl[0], scl[1], scl[2])

	# Add material if provided
	if "material" in properties:
		var mat = StandardMaterial3D.new()
		if "color" in properties.material:
			var color = properties.material.color
			if typeof(color) == TYPE_DICTIONARY:
				mat.albedo_color = Color(
					color.get("r", 1),
					color.get("g", 1),
					color.get("b", 1),
					color.get("a", 1)
				)
			elif typeof(color) == TYPE_STRING:
				mat.albedo_color = Color(color)
		csg_node.material = mat

	# Add to parent
	parent_node.add_child(csg_node)
	csg_node.owner = parent_node.get_tree().edited_scene_root if parent_node.get_tree().edited_scene_root else parent_node

	return _success({
		"node_path": str(csg_node.get_path()),
		"shape_type": shape_type,
		"node_name": node_name
	})

func set_csg_operation(params: Dictionary) -> Dictionary:
	"""
	Set CSG operation (union, intersection, subtraction)
	Params:
		- node_path: String (required)
		- operation: String (required) - "union", "intersection", "subtraction"
	"""
	var node_path = params.get("node_path", "")
	var operation = params.get("operation", "")

	if node_path == "":
		return _error("node_path is required")
	if operation == "":
		return _error("operation is required")

	var node = _get_node(node_path)
	if not node:
		return _error("Node not found: %s" % node_path)

	# Check if node is a CSG shape
	if not node is CSGShape3D:
		return _error("Node is not a CSG shape")

	_set_operation(node, operation)

	return _success({
		"node_path": node_path,
		"operation": operation
	})

func _set_operation(csg_node: CSGShape3D, operation: String):
	"""Helper to set CSG operation"""
	match operation.to_lower():
		"union":
			csg_node.operation = CSGShape3D.OPERATION_UNION
		"intersection":
			csg_node.operation = CSGShape3D.OPERATION_INTERSECTION
		"subtraction":
			csg_node.operation = CSGShape3D.OPERATION_SUBTRACTION
		_:
			push_warning("Unknown CSG operation: %s" % operation)

func _get_node(node_path: String) -> Node:
	"""Get node by path"""
	var scene_root = scene_manager.get_current_scene_root()
	if not scene_root:
		return null

	if node_path.begins_with("/root/"):
		return get_tree().root.get_node_or_null(node_path)

	return scene_root.get_node_or_null(node_path)

func _get_parent_node(parent_path: String) -> Node:
	"""Get parent node, defaults to scene root if empty"""
	if parent_path == "":
		return scene_manager.get_current_scene_root()
	return _get_node(parent_path)

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
