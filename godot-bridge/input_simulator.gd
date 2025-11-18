extends Node

## Handles input simulation (keyboard, mouse, controller)

var game_executor = null

func _ready():
	print("InputSimulator initialized")
	await get_tree().process_frame
	game_executor = get_parent().game_executor

func send_input(params: Dictionary) -> Dictionary:
	"""
	Send input event to the running game
	Params:
		- input_type: String (required) - "key", "mouse_button", "mouse_motion", "action"
		- input_data: Dictionary (required) - type-specific data
	"""
	var input_type = params.get("input_type", "")
	var input_data = params.get("input_data", {})

	if input_type == "":
		return _error("input_type is required")

	# Check if a scene is running
	if not game_executor.is_scene_running():
		return _error("No scene is currently running")

	var event: InputEvent = null

	match input_type.to_lower():
		"key":
			event = _create_key_event(input_data)
		"mouse_button":
			event = _create_mouse_button_event(input_data)
		"mouse_motion":
			event = _create_mouse_motion_event(input_data)
		"action":
			event = _create_action_event(input_data)
		_:
			return _error("Unknown input type: %s" % input_type)

	if not event:
		return _error("Failed to create input event")

	# Send the event
	Input.parse_input_event(event)

	return _success({
		"input_type": input_type,
		"sent": true
	})

func _create_key_event(data: Dictionary) -> InputEventKey:
	"""
	Create keyboard event
	Data:
		- keycode: int (required) - KEY_* constant or use 'key' string
		- key: String (optional) - alternative to keycode, e.g., "W", "Space", "Escape"
		- pressed: bool (default: true)
		- shift: bool (default: false)
		- ctrl: bool (default: false)
		- alt: bool (default: false)
	"""
	var event = InputEventKey.new()

	# Get keycode from either 'keycode' or 'key' field
	var keycode = 0
	if "keycode" in data:
		keycode = int(data.keycode)
	elif "key" in data:
		keycode = _get_keycode_from_string(data.key)
	else:
		push_error("Either 'keycode' or 'key' must be provided")
		return null

	event.keycode = keycode
	event.pressed = data.get("pressed", true)
	event.shift_pressed = data.get("shift", false)
	event.ctrl_pressed = data.get("ctrl", false)
	event.alt_pressed = data.get("alt", false)

	return event

func _create_mouse_button_event(data: Dictionary) -> InputEventMouseButton:
	"""
	Create mouse button event
	Data:
		- button_index: int (required) - MOUSE_BUTTON_* constant or 1-5
		- pressed: bool (default: true)
		- position: Vector2 or {x, y} (optional)
		- double_click: bool (default: false)
	"""
	var event = InputEventMouseButton.new()

	if not "button_index" in data:
		push_error("button_index is required")
		return null

	event.button_index = int(data.button_index)
	event.pressed = data.get("pressed", true)
	event.double_click = data.get("double_click", false)

	if "position" in data:
		var pos = data.position
		if typeof(pos) == TYPE_DICTIONARY:
			event.position = Vector2(pos.get("x", 0), pos.get("y", 0))
		elif typeof(pos) == TYPE_ARRAY and pos.size() >= 2:
			event.position = Vector2(pos[0], pos[1])

	return event

func _create_mouse_motion_event(data: Dictionary) -> InputEventMouseMotion:
	"""
	Create mouse motion event
	Data:
		- position: Vector2 or {x, y} (required)
		- relative: Vector2 or {x, y} (optional)
		- velocity: Vector2 or {x, y} (optional)
	"""
	var event = InputEventMouseMotion.new()

	if not "position" in data:
		push_error("position is required")
		return null

	var pos = data.position
	if typeof(pos) == TYPE_DICTIONARY:
		event.position = Vector2(pos.get("x", 0), pos.get("y", 0))
	elif typeof(pos) == TYPE_ARRAY and pos.size() >= 2:
		event.position = Vector2(pos[0], pos[1])

	if "relative" in data:
		var rel = data.relative
		if typeof(rel) == TYPE_DICTIONARY:
			event.relative = Vector2(rel.get("x", 0), rel.get("y", 0))
		elif typeof(rel) == TYPE_ARRAY and rel.size() >= 2:
			event.relative = Vector2(rel[0], rel[1])

	if "velocity" in data:
		var vel = data.velocity
		if typeof(vel) == TYPE_DICTIONARY:
			event.velocity = Vector2(vel.get("x", 0), vel.get("y", 0))
		elif typeof(vel) == TYPE_ARRAY and vel.size() >= 2:
			event.velocity = Vector2(vel[0], vel[1])

	return event

func _create_action_event(data: Dictionary) -> InputEventAction:
	"""
	Create action event (for InputMap actions like "ui_accept")
	Data:
		- action: String (required) - action name
		- pressed: bool (default: true)
		- strength: float (default: 1.0)
	"""
	var event = InputEventAction.new()

	if not "action" in data:
		push_error("action is required")
		return null

	event.action = data.action
	event.pressed = data.get("pressed", true)
	event.strength = data.get("strength", 1.0)

	return event

func _get_keycode_from_string(key: String) -> int:
	"""Convert key string to keycode"""
	match key.to_upper():
		"A": return KEY_A
		"B": return KEY_B
		"C": return KEY_C
		"D": return KEY_D
		"E": return KEY_E
		"F": return KEY_F
		"G": return KEY_G
		"H": return KEY_H
		"I": return KEY_I
		"J": return KEY_J
		"K": return KEY_K
		"L": return KEY_L
		"M": return KEY_M
		"N": return KEY_N
		"O": return KEY_O
		"P": return KEY_P
		"Q": return KEY_Q
		"R": return KEY_R
		"S": return KEY_S
		"T": return KEY_T
		"U": return KEY_U
		"V": return KEY_V
		"W": return KEY_W
		"X": return KEY_X
		"Y": return KEY_Y
		"Z": return KEY_Z
		"0": return KEY_0
		"1": return KEY_1
		"2": return KEY_2
		"3": return KEY_3
		"4": return KEY_4
		"5": return KEY_5
		"6": return KEY_6
		"7": return KEY_7
		"8": return KEY_8
		"9": return KEY_9
		"SPACE": return KEY_SPACE
		"ENTER": return KEY_ENTER
		"ESCAPE": return KEY_ESCAPE
		"ESC": return KEY_ESCAPE
		"BACKSPACE": return KEY_BACKSPACE
		"TAB": return KEY_TAB
		"SHIFT": return KEY_SHIFT
		"CTRL": return KEY_CTRL
		"ALT": return KEY_ALT
		"UP": return KEY_UP
		"DOWN": return KEY_DOWN
		"LEFT": return KEY_LEFT
		"RIGHT": return KEY_RIGHT
		_:
			push_warning("Unknown key: %s" % key)
			return 0

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
