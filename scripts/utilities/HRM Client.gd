extends Node

# SIGNALS
signal client_started
signal input_connected
signal word_read(word)
signal hr_read(hr)
signal auth_ok
signal auth_error

# VARIABLES
var receiver : TCP_Server
var godot_in : StreamPeerTCP
var connection_thread : Thread
var mode : int
var acc_delta : float


# Called when the node enters the scene tree for the first time.
func _ready():
	mode = 0
	acc_delta = 0.0

# Starts the client to listen for HRM
func start_client(host : String, port : int) -> void:
	receiver = TCP_Server.new()
	godot_in = StreamPeerTCP.new()
	receiver.listen(port, host)
	emit_signal("client_started")

# Tries to establish an incoming connection
func accept_input() -> void:
	connection_thread = Thread.new()
	connection_thread.start(self, "_accept_input", connection_thread)

# Tries to establish an incoming connection asyncronously
func _accept_input(userdata) -> void:
	var status = godot_in.get_status()
	while status != StreamPeerTCP.STATUS_CONNECTED:
		if status == StreamPeerTCP.STATUS_CONNECTING:
			pass
		else:
			if receiver.is_connection_available():
				godot_in = receiver.take_connection()
		status = godot_in.get_status()
	emit_signal("input_connected")
	# Thread self-kills
	userdata.call_deferred("wait_to_finish")

# Reads a message from the HRM server
func read_message() -> String:
	var current_data := PoolByteArray()
	var last_byte := 99
	var result = ""
	var br = false
	while (godot_in.get_available_bytes() > 0 and !br):
		var data = godot_in.get_partial_data(1)
		var err = data[0]
		if err:
			print("Got error " + str(err) + ", ignoring byte.")
		else:
			last_byte = data[1][0]
			if last_byte == 0:
				result = current_data.get_string_from_utf8()
				br = true
			else:
				current_data.append(last_byte)
	return result

# Reads a HR measure sent from the HRM server and returns it as an int
func read_hr_data() -> int:
	var current_data := PoolByteArray()
	var last_byte := 99
	var result = -1
	var br = false
	while (godot_in.get_available_bytes() > 0 and !br):
		var data = godot_in.get_partial_data(1)
		var err = data[0]
		if err:
			print("Got error " + str(err) + ", ignoring byte.")
		else:
			last_byte = data[1][0]
			if last_byte == 0:
				result = int(current_data.get_string_from_utf8())
				br = true
			else:
				current_data.append(last_byte)
	return result

# Sets the mode of reading data
func set_mode(new_mode : int):
	acc_delta = 0.0
	mode = new_mode

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	match mode:
		0:
			# Idle mode
			pass
		1:
			# Read words mode
			if acc_delta > 1:
				var word = read_message()
				if word != "":
					emit_signal("word_read", word)
				acc_delta = 0.0
			else:
				acc_delta += delta
		2:
			# Wait for MiBand 3 authentication
			if acc_delta > 1:
				var code := read_hr_data()
				if code != -1:
					if (code == 200):
						emit_signal("auth_ok")
					else:
						emit_signal("auth_error")
						print("Error code: " + str(code))
				# Nothing received yet
				else:
					pass
				acc_delta = 0.0
			else:
				acc_delta += delta
		3:
			# Read HR mode
			if acc_delta > 1:
				var hr := read_hr_data()
				if hr != -1:
					emit_signal("hr_read", hr)
				acc_delta = 0.0
			else:
				acc_delta += delta
