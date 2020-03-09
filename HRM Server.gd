extends Node

# SIGNALS
signal output_disconnected
signal output_connected
signal incoming_on
signal incoming_off
signal scan_on
signal mb3_conn_requested
signal message_sent
signal hrm_on
signal hrm_off
signal vibrate_ms
signal vibrate_std
signal invalid_id

# VARIBLES
var godot_out : StreamPeerTCP

# Called when the node enters the scene tree for the first time.
func _ready():
	godot_out = StreamPeerTCP.new()

# Connects to the HRM server
func start_server(host : String, port : int) -> void:
	godot_out.connect_to_host(host, port)
	godot_out.set_no_delay(true)
	emit_signal("output_connected")

# Sends a message to the HRM client listening
func message_client(id : int, payload = true) -> void:
	# Ignore when there's no peer connected
	if godot_out.get_status() != StreamPeerTCP.STATUS_CONNECTED:
		emit_signal("output_disconnected")
		return
	# Ignore invalid IDs
	if (id > 6 or id < 0):
		emit_signal("invalid_id")
		return
	# Send the instruction ID
	godot_out.put_8(id)
	# Send the payload
	match id:
		# 0 is for turning the incoming client on or off
		0:
			godot_out.put_8(payload)
			if payload:
				emit_signal("incoming_on")
			else:
				emit_signal("incoming_off")
		# 1 is turning the scanner on for 20 seconds
		1:
			emit_signal("scan_on")
		# 2 is for connecting to a MiBand3 address
		2:
			godot_out.put_utf8_string(payload)
			emit_signal("mb3_conn_requested")
		# 3 is for writing a message to the connected MiBand 3
		3:
			godot_out.put_utf8_string(payload)
			emit_signal("message_sent")
		# 4 is for turning the Heart Rate Monitoring on or off
		4:
			print("Requesting HRM")
			godot_out.put_8(payload)
			if payload:
				emit_signal("hrm_on")
			else:
				emit_signal("hrm_off")
		# 5 is for making the MiBand 3 vibrate for the given milliseconds
		5:
			godot_out.put_16(payload)
			emit_signal("vibrate_ms")
		# 6 is for making the MiBand 3 vibrate the standard amount of time 
		6:
			emit_signal("vibrate_std")
		_:
			print("Invalid ID for messaging server")
			emit_signal("invalid_id")
