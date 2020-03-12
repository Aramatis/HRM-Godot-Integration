extends Node

signal hrm_connected
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
	client.connect("client_started", self, "_on_client_started")
	client.connect("input_connected", self, "_clean_threads")
	server.connect("output_connected", self, "_on_output_connected")

# Starts the manager and assures incoming and outgoing connection
func start_connection() -> void:
	start_client()

# Starts a TCP client to receive data from the HRM server 
func start_client() -> void:
	client.start_client(host, in_port)

# Manages the client_started signal from the client
func _on_client_started():
	_get_connection()

# Starts a thread for waiting for connections
func _get_connection() -> void:
	client.accept_input()
	start_server()

# Starts a TCP server to output data to the HRM server 
func start_server()-> void:
	server.start_server(host, out_port)

# Manages the output_connected signal from the server
func _on_output_connected():
	start_incoming_server()

# Starts the HRM server to get input data
func start_incoming_server() -> void:
	server.message_client(0, true)

# Handles the incoming_on signal
func _on_incoming_on():
	pass

# Manages the input_connected signal and buries the thread 
# for waiting for connections
func _clean_threads() -> void:
	print("Connected to HRM server in port " + str(in_port))
	emit_signal("hrm_connected")

# Saves read devices
func _on_read_message(word):
	emit_signal("message_ready", word)

# Starts scanning for new MiBand 3 peripherals
func start_ble_scan() -> void:
	client.set_mode(1)
	server.message_client(1)
	$ScanTimer.start(20)

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

# Signals the end of a scan
func _on_scan_end():
	client.set_mode(0)
	emit_signal("scan_end")

# Handle hr data
func _on_hr_read(hr):
	emit_signal("new_hr", hr)

# Handle mb3_conn_requested signal
func _on_mb3_conn_requested():
	$AuthTimer.start(10)

# Handle AuthTimer timeout
func _on_auth_timer_end():
	start_hrm()
	emit_signal("auth_end")
