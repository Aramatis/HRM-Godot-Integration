extends Node

# SIGNALS
signal hrm_status(stat)
signal incoming(stat)
signal invalid_id(inv_id)
signal mb3_conn(addr)
signal message_sent(msg)
signal output_status(stat)
signal scan(secs)
signal vibrate_ms(ms)
signal vibrate_std

# VARIBLES
var godot_out : StreamPeerTCP

# Called when the node enters the scene tree for the first time.
func _ready():
	godot_out = StreamPeerTCP.new()

# Connects to the HRM server
func start_server(host : String, port : int) -> void:
	godot_out.connect_to_host(host, port)
	godot_out.set_no_delay(true)
	emit_signal("output_status", true)

# Sends a message to the HRM client listening
func message_client(id : int, payload = true) -> void:
	# Declare valid IDs
	var valid_id_range := [0, 6]
	# Ignore when there's no peer connected
	if godot_out.get_status() != StreamPeerTCP.STATUS_CONNECTED:
		emit_signal("output_status", false)
		return
	# Ignore invalid IDs
	if (id >= valid_id_range[0] and id <= valid_id_range[1]):
		godot_out.put_8(id)
	# Send the payload
	match id:
		# 0 is for turning the incoming client on or off
		0:
			godot_out.put_8(payload)
			emit_signal("incoming", payload)
		# 1 is turning the scanner on for the given seconds
		1:
			godot_out.put_16(payload)
			emit_signal("scan", payload)
		# 2 is for connecting to a MiBand3 address
		2:
			godot_out.put_utf8_string(payload)
			emit_signal("mb3_conn", payload)
		# 3 is for writing a message to the connected MiBand 3
		3:
			godot_out.put_utf8_string(payload)
			emit_signal("message_sent", payload)
		# 4 is for turning the Heart Rate Monitoring on or off
		4:
			print("Requesting HRM status change")
			godot_out.put_8(payload)
			emit_signal("hrm_status", payload)
		# 5 is for making the MiBand 3 vibrate for the given milliseconds
		5:
			godot_out.put_16(payload)
			emit_signal("vibrate_ms", payload)
		# 6 is for making the MiBand 3 vibrate the standard amount of time 
		6:
			emit_signal("vibrate_std")
		_:
			print("Invalid ID for messaging server")
			emit_signal("invalid_id", id)
