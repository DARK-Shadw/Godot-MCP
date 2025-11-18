extends Node
class_name CaptureManager

## Handles screenshot and video capture

var game_executor: GameExecutor = null
var is_recording: bool = false
var video_frames: Array[Image] = []
var video_output_path: String = ""
var video_fps: int = 30
var frame_counter: int = 0

func _ready():
	print("CaptureManager initialized")
	await get_tree().process_frame
	game_executor = get_parent().game_executor

func capture_screenshot(params: Dictionary) -> Dictionary:
	"""
	Capture a screenshot of the current viewport
	Params:
		- output_path: String (optional) - if provided, saves to file
		- return_base64: bool (default: true) - return image as base64
		- viewport: String (optional) - "game" or "editor" (default: "game")
	"""
	var output_path = params.get("output_path", "")
	var return_base64 = params.get("return_base64", true)
	var viewport_type = params.get("viewport", "game")

	# Get the appropriate viewport
	var viewport: Viewport
	if viewport_type == "game" and game_executor:
		viewport = game_executor.get_game_viewport()
		if not viewport:
			viewport = get_viewport()
	else:
		viewport = get_viewport()

	# Wait for rendering to complete
	await RenderingServer.frame_post_draw

	# Get the viewport texture and convert to image
	var texture = viewport.get_texture()
	var image = texture.get_image()

	if not image:
		return _error("Failed to capture screenshot")

	var result = {
		"width": image.get_width(),
		"height": image.get_height(),
		"format": image.get_format()
	}

	# Save to file if path provided
	if output_path != "":
		# Ensure directory exists
		var dir_path = output_path.get_base_dir()
		if not DirAccess.dir_exists_absolute(dir_path):
			DirAccess.make_dir_recursive_absolute(dir_path)

		# Determine format from extension
		var extension = output_path.get_extension().to_lower()
		var save_result = OK

		match extension:
			"png":
				save_result = image.save_png(output_path)
			"jpg", "jpeg":
				save_result = image.save_jpg(output_path)
			"webp":
				save_result = image.save_webp(output_path)
			_:
				return _error("Unsupported image format: %s (use png, jpg, or webp)" % extension)

		if save_result != OK:
			return _error("Failed to save screenshot to: %s" % output_path)

		result["output_path"] = output_path

	# Return as base64 if requested
	if return_base64:
		var png_buffer = image.save_png_to_buffer()
		var base64 = Marshalls.raw_to_base64(png_buffer)
		result["base64"] = base64

	return _success(result)

func start_video_capture(params: Dictionary) -> Dictionary:
	"""
	Start recording video
	Params:
		- output_path: String (required)
		- fps: int (default: 30)
	"""
	var output_path = params.get("output_path", "")
	var fps = params.get("fps", 30)

	if output_path == "":
		return _error("output_path is required")

	if is_recording:
		return _error("Video recording already in progress")

	# Initialize recording
	video_frames.clear()
	video_output_path = output_path
	video_fps = fps
	frame_counter = 0
	is_recording = true

	# Start capturing frames
	set_process(true)

	print("Video recording started: %s @ %d fps" % [output_path, fps])

	return _success({
		"recording": true,
		"output_path": output_path,
		"fps": fps
	})

func stop_video_capture(params: Dictionary) -> Dictionary:
	"""
	Stop recording video and save to file
	"""
	if not is_recording:
		return _error("No video recording in progress")

	is_recording = false
	set_process(false)

	print("Video recording stopped. Captured %d frames" % video_frames.size())

	# Save frames as PNG sequence or animated WebP
	# Note: Godot doesn't have built-in video encoding, so we save as image sequence
	var extension = video_output_path.get_extension().to_lower()

	if extension == "webp":
		# Save as animated WebP (Godot 4.x supports this)
		# This is a simplified version - actual animated WebP saving is complex
		return _error("Animated WebP not yet implemented. Use PNG sequence instead.")

	else:
		# Save as PNG sequence
		var dir_path = video_output_path.get_base_dir()
		var base_name = video_output_path.get_basename().get_file()

		if not DirAccess.dir_exists_absolute(dir_path):
			DirAccess.make_dir_recursive_absolute(dir_path)

		var saved_count = 0
		for i in range(video_frames.size()):
			var frame_path = "%s/%s_%05d.png" % [dir_path, base_name, i]
			var result = video_frames[i].save_png(frame_path)
			if result == OK:
				saved_count += 1

		video_frames.clear()

		return _success({
			"recording": false,
			"output_dir": dir_path,
			"frame_count": saved_count,
			"fps": video_fps,
			"message": "Video saved as PNG sequence. Use ffmpeg to convert to video."
		})

func _process(_delta):
	"""Capture frames during video recording"""
	if not is_recording:
		return

	# Capture every Nth frame based on FPS
	# Assuming 60 FPS engine, capture every 2 frames for 30 FPS video
	var capture_interval = 60.0 / video_fps
	frame_counter += 1

	if frame_counter >= capture_interval:
		frame_counter = 0
		_capture_frame()

func _capture_frame():
	"""Capture a single frame"""
	var viewport = game_executor.get_game_viewport() if game_executor else get_viewport()

	var texture = viewport.get_texture()
	var image = texture.get_image()

	if image:
		# Store a copy of the image
		video_frames.append(image)

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
