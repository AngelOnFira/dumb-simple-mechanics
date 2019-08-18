extends Node2D

var selected = false
var last_mouse = Vector2()
var new_mouse = Vector2()

func _ready():
	pass

func _process(_delta):
	if selected:
		new_mouse = get_viewport().get_mouse_position()
		position -= (last_mouse - new_mouse)
		last_mouse = new_mouse
	
func init():
	randomize()
	$Area2D/ColorRect.color = Color(rand_range(0.0, 1.0), rand_range(0.0, 1.0), rand_range(0.0, 1.0))
	set_position(get_parent().get_node("Area2D").position + Vector2(10, 10))

func _on_Area2D_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton:
		if event.is_pressed():
			selected = true
			last_mouse = get_viewport().get_mouse_position()
		else:
			selected = false
			var collisions = $Area2D.get_overlapping_areas()
			if collisions.size():
				get_parent().remove_child(self)
				collisions[0].get_parent().add_child(self)
			set_position(get_parent().get_node("Area2D").position + Vector2(10, 10))
