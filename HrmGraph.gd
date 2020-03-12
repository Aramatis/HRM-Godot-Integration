extends Control

# Variables
var mean_hr : float
var hr_ticks : int
var x_axis
var y_axis
var current_hr
var current_valence
var x_scale : Vector2
var y_scale : Vector2
var indicator

# Called when the node enters the scene tree for the first time.
func _ready():
	mean_hr = 0
	hr_ticks = 0
	current_hr = 0
	current_valence = 0
	x_scale = Vector2(0, 10)
	y_scale = Vector2(120, 60)
	x_axis = $xAxis
	y_axis = $yAxis
	indicator = $HRIndicator
	indicator.position = Vector2(300, 300)
	y_axis.connect("name_resized", self, "_on_y_axis_name_change_size")
	x_axis.set_labels("Valence", x_scale[0], x_scale[1])
	y_axis.set_labels("Heart Rate (bpm) ", y_scale[0], y_scale[1])

# Auto rotates the y_axis after its name changes size
func _on_y_axis_name_change_size():
	y_axis.set_vertical()

# Updates the median hr with a new measure
func _update_hr(new_hr : int):
	var new_hr_f = float(new_hr)
	mean_hr = (mean_hr * hr_ticks) / (hr_ticks + 1)
	mean_hr += new_hr_f / (hr_ticks + 1)
	hr_ticks += 1

# Returns the position as text
func _get_as_text(x : int, y : int):
	return "(" + str(x) + ", " + str(y) + ")"

# Updates the graph with a new HR measure
func new_hr(hr : int):
	_update_hr(hr)
	current_hr = hr
	var text = _get_as_text(current_valence, hr)
	indicator.move_y(600 - _transform_by_scale(1, y_scale, hr), text)

# Updates the graph with a new valence
func new_valence(val : int):
	current_valence = val
	var text = _get_as_text(val, current_hr)
	indicator.move_x(_transform_by_scale(0, x_scale, val), text)

# Transforms a position (in a dimention) from the given scale 
# to the corresponding graph position
func _transform_by_scale(dimention : int, scale : Vector2, pos : int) -> float:
	var result = float(pos)
	var real_scale = Vector2(scale[0], scale[1])
	if (scale[0] > scale[1]):
		real_scale[0] = scale[1]
		real_scale[1] = scale[0]
	var graph_scale = Vector2(0, self.rect_size[dimention])
	result -= real_scale[0]
	var scale_size = real_scale[1] - real_scale[0]
	result *= (graph_scale.length() / scale_size)
	return result
