extends Node

## Handles game scene execution (play, pause, stop)

var scene_manager = null
var running_scene: Node = null
var is_running: bool = false
var game_viewport: SubViewport = null

func _ready():
	print("GameExecutor initialized")
	await get_tree().process_frame
	scene_manager = get_parent().scene_manager

	# Create a viewport for running the game
	game_viewport = SubViewport.new()
	game_viewport.name = "GameViewport"
	game_viewport.size = Vector2i(1920, 1080)
	game_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(game_viewport)

func run_scene(params: Dictionary) -> Dictionary:
	"""
	Run a scene
	Params:
		- scene_path: String (optional) - if not provided, runs current scene
	"""
	var scene_path = params.get("scene_path", "")

	# Stop currently running scene if any
	if is_running:
		stop_scene({})

	# Determine which scene to run
	var scene_to_run: Node = null

	if scene_path != "":
		# Load and instantiate the specified scene
		if not FileAccess.file_exists(scene_path):
			return _error("Scene file not found: %s" % scene_path)

		var packed_scene = load(scene_path)
		if not packed_scene:
			return _error("Failed to load scene: %s" % scene_path)

		scene_to_run = packed_scene.instantiate()
		if not scene_to_run:
			return _error("Failed to instantiate scene")
	else:
		# Use current scene
		var current_scene = scene_manager.get_current_scene_root()
		if not current_scene:
			return _error("No scene to run")

		# Duplicate the current scene to run it
		scene_to_run = current_scene.duplicate()
		scene_path = scene_manager.current_scene_path

	# Add scene to game viewport
	game_viewport.add_child(scene_to_run)
	running_scene = scene_to_run
	is_running = true

	print("Running scene: %s" % scene_path)

	return _success({
		"running": true,
		"scene_path": scene_path,
		"scene_root": str(scene_to_run.get_path())
	})

func stop_scene(params: Dictionary) -> Dictionary:
	"""
	Stop the currently running scene
	"""
	if not is_running:
		return _error("No scene is currently running")

	# Remove and free the running scene
	if running_scene:
		running_scene.queue_free()
		running_scene = null

	is_running = false

	print("Scene stopped")

	return _success({
		"running": false,
		"message": "Scene stopped"
	})

func get_running_scene() -> Node:
	"""Get the currently running scene"""
	return running_scene

func get_game_viewport() -> SubViewport:
	"""Get the game viewport"""
	return game_viewport

func is_scene_running() -> bool:
	"""Check if a scene is currently running"""
	return is_running

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
