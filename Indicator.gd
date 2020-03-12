extends Node2D

var cab : Tween
var moving : bool
var trans_type : int
var ease_type : int
var dest_queue : Array
var trans_time : float
var pos_label : Label


# Called when the node enters the scene tree for the first time.
func _ready():
	cab = $CabTween
	trans_type = cab.TRANS_CUBIC
	ease_type = cab.EASE_IN_OUT
	dest_queue = []
	trans_time = 5
	pos_label = $PosLabel
	cab.connect("tween_completed", self, "_on_tween_completed")

func move_y(dest : float, text := ""):
	_move_smooth(1, dest, text)

func move_x(dest : float, text := ""):
	_move_smooth(0, dest, text)

# Moves the indicator smoothly to the given destination
func _move_smooth(axis : int, dest : float, text : String):
	if moving:
		dest_queue.append({"axis": axis, "dest" : dest, "text": text})
	else:
		var dest_pos : Vector2
		if axis > 0:
			dest_pos = Vector2(self.position[0], dest)
		else:
			dest_pos = Vector2(dest, self.position[1])
		moving = true
		pos_label.set_text(text)
		cab.interpolate_property(
			self, "position", null, dest_pos,
			trans_time, trans_type, ease_type, 0)
		cab.start()

# Sets the moving value to false again
func _on_tween_completed(_object, _node_path):
	moving = false
	print("tween completed")
	if not dest_queue.empty():
		var dest_dict = dest_queue.pop_front()
		var axis = dest_dict
		_move_smooth(dest_dict.get("axis"), dest_dict.get("dest"), dest_dict.get("text"))
