extends Control

onready var Card = preload("res://card.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	var new_card = Card.instance()
	$VBoxContainer/HBoxContainer.get_children()[0].add_child(new_card)
	new_card.init()
