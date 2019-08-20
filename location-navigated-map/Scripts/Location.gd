extends Node2D

onready var locations = get_parent()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_PinArea_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.is_pressed():
			if locations.current_dialogue:
				# If the last chosen one was itself, change state
				if locations.current_dialogue == $LocationDialogue:
					locations.current_dialogue.visible = not locations.current_dialogue.visible
					return

				locations.current_dialogue.visible = false

			locations.current_dialogue = $LocationDialogue
			$LocationDialogue.visible = true
