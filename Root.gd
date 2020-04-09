extends Node2D

# Variables
var hrm_manager
var scan_gui
var indicator : Node2D
var device_list : ItemList
var select_button : Button
var conn_status : Label
var conn_init_text : String 
var conn_pos : Position2D
var hr_received : bool
var scan_pos : Position2D
var devices : Array
var start_menu : Control
var hrm_graph : Control
var server_pid : int
var valence_enabled : bool

# Called when the node enters the scene tree for the first time.
func _ready():
	# Start HRM server
	# server_pid = OS.execute(".\\assets\\HRM.exe", [], false)
	conn_status = $Screen/ConnStatus
	conn_init_text = conn_status.get_text()
	conn_status.set_text(conn_init_text + "Waiting for server.")
	hrm_manager = $HrmManager
	scan_gui = $Screen/StartMenu/ScanGUI
	start_menu = $Screen/StartMenu
	hrm_graph = $Screen/HrmGraph
	indicator = $Screen/StartMenu/Indicator
	conn_pos = $Screen/Positions/ConnectPos
	scan_pos = $Screen/Positions/ScanPos
	indicator.position = conn_pos.position
	device_list = $Screen/StartMenu/ItemList
	devices = Array()
	select_button = $Screen/StartMenu/SelectButton
	valence_enabled = false
	hr_received = false
	$ServerStartUpTimer.start(8)

# Delays the beginning of the program to allow the HRM Server to start
func _on_server_startup_timeout():
	print("Attempt connection")
	hrm_manager.start_connection()

# Enables the scan button and enables the selection display
func _on_client_ready():
	scan_gui.enable()
	conn_status.set_text(conn_init_text + "Connected.")
	indicator.position = scan_pos.position
	indicator.set_visible(false)

# Starts a ble scan
func _start_scan(secs) -> void:
	indicator.set_visible(true)
	indicator.position = scan_pos.position
	select_button.set_disabled(true)
	select_button.set_visible(false)
	scan_gui.disable()
	device_list.clear()
	devices.clear()
	hrm_manager.start_ble_scan(secs)
	conn_status.set_text(
		conn_init_text + "Scanning for " + str(secs) + " seconds.")

# Enable buttons after scan
func _on_scan_end():
	conn_status.set_text(conn_init_text + "Connected.")
	select_button.set_disabled(false)
	select_button.set_visible(true)
	scan_gui.enable()
	indicator.set_visible(false)

# Handles a new device scanned
func _on_message_received(word):
	var device = word
	if not devices.has(word):
		devices.append(device)
		device_list.add_item("Device: " + device)

# Adds a new HR measure to the graph
func _on_new_hr(new_hr):
	if not hr_received:
		hr_received = true
		conn_status.set_text(conn_init_text + "\nReceiving HR\nmeasurements.")
		indicator.hide()
		hrm_manager.message_miband3("Connected")
	hrm_graph.new_hr(new_hr)

# Handles the selection of a device
func _select_device():
	if device_list.is_anything_selected():
		start_menu.hide()
		hrm_graph.show()
		var selected := device_list.get_selected_items()[0]
		print("Device selected: " + devices[selected])
		conn_status.set_text(conn_init_text + "\nWaiting MiBand3\nAuthentication.")
		indicator.position = conn_pos.position
		indicator.show()
		hrm_manager.connect_miband3(devices[selected])
		valence_enabled = true

# Handles the ending of authentication
func _on_auth_end(status):
	if status:
		conn_status.set_text(conn_init_text + "\nWaiting to receive HR.")
	else:
		conn_status.set_text(conn_init_text + "\nAuthentication Failed.")

# Manages the vibrate_by signal
func _on_vibrate_by(secs) -> void:
	hrm_manager.vibrate_ms(secs * 1000)

# Manages the send_msg signal
func _on_send_msg(msg) -> void:
	hrm_manager.message_miband3(msg)

func _input(event):
	if valence_enabled:
		if event.is_action_pressed("ui_left"):
			hrm_graph.down_valence()
		if event.is_action_pressed("ui_right"):
			hrm_graph.up_valence()
