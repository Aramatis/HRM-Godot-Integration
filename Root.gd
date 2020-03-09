extends Node2D

# Variables
var hrm_manager
var indicator : Node2D
var device_list : ItemList
var scan_button : Button
var select_button : Button
var message : Label
var conn_status : Label
var conn_init_text : String 
var conn_pos : Position2D
var scan_pos : Position2D
var devices : Array
var start_menu : Control

# Called when the node enters the scene tree for the first time.
func _ready():
	message = $Screen/Message
	conn_status = $Screen/ConnStatus
	conn_init_text = conn_status.get_text()
	hrm_manager = $HrmManager
	indicator = $Screen/StartMenu/Indicator
	device_list = $Screen/StartMenu/ItemList
	devices = Array()
	scan_button = $Screen/StartMenu/ScanButton
	select_button = $Screen/StartMenu/SelectButton	
	hrm_manager.set_output_label($Screen/Message)
	conn_pos = $Screen/Positions/ConnectPos
	scan_pos = $Screen/Positions/ScanPos
	start_menu = $Screen/StartMenu
	indicator.position = conn_pos.position
	conn_status.set_text(conn_init_text + "Waiting for server.")
	hrm_manager.start_connection()

# Enables the scan button and enables the selection display
func _on_client_ready():
	scan_button.set_disabled(false)
	conn_status.set_text(conn_init_text + "Connected.")
	indicator.position = scan_pos.position
	indicator.set_visible(false)

# Starts a ble scan
func _start_scan():
	indicator.set_visible(true)
	indicator.position = scan_pos.position
	select_button.set_disabled(true)
	select_button.set_visible(false)
	scan_button.set_disabled(true)
	scan_button.set_text("Scanning...")
	device_list.clear()
	devices.clear()
	hrm_manager.start_ble_scan()

# Enable buttons after scan
func _on_scan_end():
	select_button.set_disabled(false)
	select_button.set_visible(true)
	scan_button.set_disabled(false)
	scan_button.set_text("Scan Again")
	indicator.set_visible(false)

# Handles a new device scanned
func _on_message_ready(word):
	var device = word
	if not devices.has(word):
		devices.append(device)
		device_list.add_item("Device: " + device)

# Handles the selection of a device
func _select_device():
	if device_list.is_anything_selected():
		start_menu.hide()
		var selected := device_list.get_selected_items()[0]
		print("Device selected: " + devices[selected])
		hrm_manager.connect_miband3(devices[selected])
