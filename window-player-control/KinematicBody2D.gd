extends KinematicBody2D

var prev_window = OS.get_window_position()

func _ready():
	prev_window = OS.get_window_position()

func _process(delta):
	self.move_and_collide(OS.get_window_position() * 0.5 - prev_window)
	prev_window = OS.get_window_position() * 0.5
