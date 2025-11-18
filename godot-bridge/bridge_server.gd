extends Node

## Godot MCP Bridge Server
## This script creates an HTTP server that listens for commands from the MCP server
## and executes them in the Godot engine.

const PORT = 8765
const HOST = "127.0.0.1"

var server: TCPServer
var clients: Array[StreamPeerTCP] = []
var scene_manager: SceneManager
var node_manager: NodeManager
var script_manager: ScriptManager
var csg_manager: CSGManager
var game_executor: GameExecutor
var input_simulator: InputSimulator
var capture_manager: CaptureManager

func _ready():
	print("=== Godot MCP Bridge Server ===")
	print("Initializing managers...")

	# Initialize all manager components
	scene_manager = SceneManager.new()
	add_child(scene_manager)

	node_manager = NodeManager.new()
	add_child(node_manager)

	script_manager = ScriptManager.new()
	add_child(script_manager)

	csg_manager = CSGManager.new()
	add_child(csg_manager)

	game_executor = GameExecutor.new()
	add_child(game_executor)

	input_simulator = InputSimulator.new()
	add_child(input_simulator)

	capture_manager = CaptureManager.new()
	add_child(capture_manager)

	# Start TCP server
	server = TCPServer.new()
	var err = server.listen(PORT, HOST)
	if err != OK:
		push_error("Failed to start server on %s:%d - Error: %d" % [HOST, PORT, err])
		get_tree().quit()
		return

	print("Server started on %s:%d" % [HOST, PORT])
	print("Waiting for connections...")

func _process(_delta):
	# Accept new connections
	if server.is_connection_available():
		var client = server.take_connection()
		clients.append(client)
		print("New client connected from: ", client.get_connected_host())

	# Process existing clients
	var i = 0
	while i < clients.size():
		var client = clients[i]

		# Check if client is still connected
		if client.get_status() != StreamPeerTCP.STATUS_CONNECTED:
			print("Client disconnected")
			clients.remove_at(i)
			continue

		# Check if client has data
		if client.get_available_bytes() > 0:
			var request_data = client.get_utf8_string(client.get_available_bytes())
			handle_request(client, request_data)

		i += 1

func handle_request(client: StreamPeerTCP, request_data: String):
	"""Handle incoming HTTP request"""
	print("\n--- Incoming Request ---")
	print(request_data.substr(0, min(500, request_data.length())))  # Print first 500 chars

	# Parse HTTP request
	var lines = request_data.split("\r\n")
	if lines.size() == 0:
		send_error_response(client, 400, "Bad Request")
		return

	# Parse request line (e.g., "POST /scene/create HTTP/1.1")
	var request_line = lines[0].split(" ")
	if request_line.size() < 3:
		send_error_response(client, 400, "Invalid Request Line")
		return

	var method = request_line[0]
	var path = request_line[1]

	# Find body (after blank line)
	var body = ""
	var body_start = false
	for line in lines:
		if body_start:
			body += line
		elif line == "":
			body_start = true

	# Parse JSON body if present
	var json_body = {}
	if body != "":
		var json = JSON.new()
		var parse_result = json.parse(body)
		if parse_result == OK:
			json_body = json.data
		else:
			print("Warning: Failed to parse JSON body: ", json.get_error_message())

	# Route request
	var response = route_request(method, path, json_body)

	# Send response
	send_json_response(client, response)

func route_request(method: String, path: String, body: Dictionary) -> Dictionary:
	"""Route request to appropriate handler"""
	print("Routing: %s %s" % [method, path])

	# Scene endpoints
	if path == "/scene/create":
		return scene_manager.create_scene(body)
	elif path == "/scene/load":
		return scene_manager.load_scene(body)
	elif path == "/scene/save":
		return scene_manager.save_scene(body)
	elif path == "/scene/tree":
		return scene_manager.get_scene_tree(body)

	# Node endpoints
	elif path == "/node/create":
		return node_manager.create_node(body)
	elif path == "/node/delete":
		return node_manager.delete_node(body)
	elif path == "/node/property/set":
		return node_manager.set_node_property(body)
	elif path == "/node/property/get":
		return node_manager.get_node_property(body)
	elif path == "/node/move":
		return node_manager.move_node(body)
	elif path == "/node/transform":
		return node_manager.set_node_transform(body)

	# Script endpoints
	elif path == "/script/create":
		return script_manager.create_script(body)
	elif path == "/script/attach":
		return script_manager.attach_script(body)
	elif path == "/script/update":
		return script_manager.update_script(body)

	# CSG endpoints
	elif path == "/csg/create":
		return csg_manager.create_csg_shape(body)
	elif path == "/csg/operation":
		return csg_manager.set_csg_operation(body)

	# Execution endpoints
	elif path == "/game/run":
		return game_executor.run_scene(body)
	elif path == "/game/stop":
		return game_executor.stop_scene(body)
	elif path == "/game/input":
		return input_simulator.send_input(body)

	# Capture endpoints
	elif path == "/capture/screenshot":
		return capture_manager.capture_screenshot(body)
	elif path == "/capture/video/start":
		return capture_manager.start_video_capture(body)
	elif path == "/capture/video/stop":
		return capture_manager.stop_video_capture(body)

	# Resource endpoints
	elif path == "/resource/nodes":
		return node_manager.list_available_nodes(body)
	elif path == "/resource/docs":
		return node_manager.get_node_documentation(body)

	# Health check
	elif path == "/health":
		return {"status": "success", "message": "Bridge server is running"}

	# Unknown endpoint
	else:
		return {
			"status": "error",
			"error": "Unknown endpoint: %s" % path,
			"code": 404
		}

func send_json_response(client: StreamPeerTCP, response: Dictionary):
	"""Send JSON response with HTTP headers"""
	var json_string = JSON.stringify(response)
	var status_code = response.get("code", 200 if response.get("status") == "success" else 500)
	var status_text = get_status_text(status_code)

	var http_response = ""
	http_response += "HTTP/1.1 %d %s\r\n" % [status_code, status_text]
	http_response += "Content-Type: application/json\r\n"
	http_response += "Content-Length: %d\r\n" % json_string.length()
	http_response += "Access-Control-Allow-Origin: *\r\n"
	http_response += "Connection: close\r\n"
	http_response += "\r\n"
	http_response += json_string

	client.put_data(http_response.to_utf8_buffer())
	print("Response sent: %d bytes" % http_response.length())

func send_error_response(client: StreamPeerTCP, code: int, message: String):
	"""Send error response"""
	send_json_response(client, {
		"status": "error",
		"error": message,
		"code": code
	})

func get_status_text(code: int) -> String:
	"""Get HTTP status text for code"""
	match code:
		200: return "OK"
		400: return "Bad Request"
		404: return "Not Found"
		500: return "Internal Server Error"
		_: return "Unknown"

func _exit_tree():
	"""Cleanup on exit"""
	print("\nShutting down server...")
	for client in clients:
		client.disconnect_from_host()
	if server:
		server.stop()
	print("Server stopped")
