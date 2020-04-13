extends Control

# Signals
signal scan_start(secs)

# Variables
var time : LineEdit
var warn : Label
var scan_text : Label
var scan_button : Button
var placeholder : ColorRect
var default_color : Color
var red : Color
var default_text : String
var scanning_text : String


# Called when the node enters the scene tree for the first time.
func _ready():
	time = $Scan/Time
	warn = $Warn
	scan_text = $Scan/ScanText
	scan_button = $Scan/ScanButton
	placeholder = $Scan/Placeholder
	default_color = warn.get_color("font_color")
	red = Color.red
	default_text = scan_text.get_text()
	scanning_text = "Scanning for"
	self.set_modulate(Color(1, 1, 1, 0.5))
	time.set_editable(false)
	scan_button.set_disabled(true)

# Handles button pressing
func _on_button_press() -> void:
	var seconds = time.get_text()
	if seconds.is_valid_integer():
		var n := int(seconds)
		if (n > 0 and n < 301):
			self.disable()
			emit_signal("scan_start", n)
			return
	warn.add_color_override("font_color", red)

# Handles disabling
func disable():
	scan_button.set_disabled(true)
	time.set_editable(false)
	warn.add_color_override("font_color", default_color)
	placeholder.set_visible(true)
	scan_text.set_text(scanning_text)

# Handles enabling
func enable():
	scan_button.set_disabled(false)
	time.set_editable(true)
	warn.add_color_override("font_color", default_color)
	placeholder.set_visible(false)
	scan_text.set_text(default_text)
	self.set_modulate(Color(1, 1, 1, 1))
