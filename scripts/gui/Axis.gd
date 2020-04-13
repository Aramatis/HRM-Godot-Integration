extends ColorRect

# Signals
signal name_resized

# Variables
var begin_label : Label
var end_label : Label
var name_label : Label
var vertical : bool

# Called when the node enters the scene tree for the first time.
func _ready():
	begin_label = $Begin
	end_label = $End
	name_label = $Name
	vertical = false

# Sets the axis as vertical
func set_vertical():
	if vertical:
		return
	self.set_rotation(PI/2)
	name_label.set_rotation(-PI/2)
	begin_label.set_rotation(-PI/2)
	end_label.set_rotation(-PI/2)
	name_label.rect_position[1] += name_label.rect_size[1]
	name_label.rect_position[1] += name_label.rect_size[0]
	end_label.rect_position[0] += end_label.rect_size[1]
	vertical = true

# Sets the axis as horizontal
func set_horizontal():
	if not vertical:
		return
	end_label.rect_position[0] -= end_label.rect_size[1]
	name_label.rect_position[1] -= name_label.rect_size[0]
	name_label.rect_position[1] -= name_label.rect_size[1]
	end_label.set_rotation(0)
	begin_label.set_rotation(0)
	name_label.set_rotation(0)
	self.set_rotation(0)
	vertical = false

# Sets the text of the labels for beginning and end:
func set_labels(name, begin, end):
	name_label.set_text(str(name))
	begin_label.set_text(str(begin))
	end_label.set_text(str(end))

# Propagates the resized signal of the name label
func _on_name_resized():
	emit_signal("name_resized")
