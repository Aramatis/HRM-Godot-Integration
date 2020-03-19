extends Node

signal connected_to_server
signal scan_end
signal auth_end
signal message_ready(word)
signal hr_ready(hr)
signal new_hr(hr)

# VARIABLES
export var host := "127.0.0.1"
export var in_port := 1242
export var out_port := 1243
var client : Node
var server : Node

# Called when the node enters the scene tree for the first time.
func _ready():
	client = $HrmClient
	server = $HrmServer
	# Register client signals
	client.connect("client_started", self, "_on_client_started")
	client.connect("hr_read", self, "_on_hr_read")
	client.connect("input_connected", self, "_on_input_connected")
	client.connect("word_read", self, "_on_word_read")
	# Register server signals
	server.connect("hrm_status", self, "_on_hrm_status")
	server.connect("incoming", self, "_on_incoming")
	server.connect("invalid_id", self, "_on_invalid_id")
	server.connect("mb3_conn", self, "_on_mb3_conn")
	server.connect("message_sent", self, "_on_message_sent")
	server.connect("output_status", self, "_on_output_status")
	server.connect("scan", self, "_on_scan")
	server.connect("vibrate_ms", self, "_on_vibrate_ms")
	server.connect("vibrate_std", self, "_on_vibrate_std")

# Starts the manager and assures incoming and outgoing connection
func start_connection() -> void:
	start_client()

# Starts a TCP client to receive data from the HRM server 
func start_client() -> void:
	client.start_client(host, in_port)

# Starts a thread for waiting for connections
func _get_connection() -> void:
	client.accept_input()
	start_server()

# Starts a TCP server to output data to the HRM server 
func start_server()-> void:
	server.start_server(host, out_port)

# Starts the HRM client to get input data
func _start_incoming_client() -> void:
	server.message_client(0, true)

# Starts scanning for new MiBand 3 peripherals
func start_ble_scan(secs) -> void:
	client.set_mode(1)
	server.message_client(1, secs)
	$ScanTimer.start(secs)

# Connects the HRM server to the MiBand 3 with the given address
func connect_miband3(address : String) -> void:
	server.message_client(2, address)

# Sends a message to be shown on the MiBand 3
func message_miband3(message : String) -> void:
	server.message_client(3, message)

# Starts the HRM monitoring
func start_hrm() -> void:
	server.message_client(4, true)
	client.set_mode(2)

# Makes the connected MiBand 3 vibrate for the given amount of milliseconds
func vibrate_ms(ms : int) -> void:
	server.message_client(5, ms)

# Makes the connected MiBand 3 vibrate for the default amount of milliseconds
func vibrate_default() -> void:
	server.message_client(6)

# Signals the end of a scan
func _on_scan_end():
	client.set_mode(0)
	emit_signal("scan_end")

# Handle AuthTimer timeout
func _on_auth_timer_end():
	start_hrm()
	emit_signal("auth_end")

#### CLIENT SIGNALS MANAGEMENT ####

# # Handles the client_started signal
func _on_client_started():
	_get_connection()

# Handles the hr_read signal
func _on_hr_read(hr):
	emit_signal("new_hr", hr)

# Handles the input_connected signal 
func _on_input_connected() -> void:
	print("Connected to HRM server in port " + str(in_port))
	emit_signal("connected_to_server")

# Saves read devices
func _on_word_read(word):
	emit_signal("message_ready", word)


#### SERVER SIGNALS MANAGEMENT ####

# Handles the hrm_status signal
func _on_hrm_status(stat):
	if stat:
		pass

# Handles the incoming signal
func _on_incoming(stat):
	if stat:
		pass

# Handles the incoming signal
func _on_invalid_id():
	pass

# Handles the mb3_conn signal
func _on_mb3_conn(_addr):
	$AuthTimer.start(10)

# Handles the message_sent signal
func _on_message_sent():
	pass

# Handles the output_status signal
func _on_output_status(stat) -> void:
	if stat:
		_start_incoming_client()
	else:
		print("Server disconnected")

# Handles the scan signal
func _on_scan():
	pass

# Handles the vibrate_ms signal
func _on_vibrate_ms(_ms):
	pass

# Handles the vibrate_std signal
func _on_vibrate_std():
	pass
