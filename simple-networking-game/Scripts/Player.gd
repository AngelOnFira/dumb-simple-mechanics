extends Node2D

var PLAYER_SPEED = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	var world = Node2D.new()
	get_node("/root/Main").add_child(world)
	
	prepare_network_update()
	
func _process(delta):
	update_player(delta)
	
master func prepare_network_update():
	var network_timer = Timer.new()
	network_timer.connect("timeout", self, "send_network_update")
	get_node("/root/Main").add_child(network_timer)
	network_timer.start()
	
master func send_network_update():
	if Globals.current_state == Globals.STATE.CONNECTED:
		rpc("recv_network_update", $".".position)
	else:
		get_node("/root/Main/network_timer").queue_free()
	
puppet func recv_network_update(position):
	$".".position = position
	
master func update_player(delta):
	var velocity = Vector2(0,0)
	
	if Input.is_action_pressed("ui_right"):
		velocity.x += delta
	if Input.is_action_pressed("ui_left"):
		velocity.x -= delta
	if Input.is_action_pressed("ui_up"):
		velocity.y -= delta
	if Input.is_action_pressed("ui_down"):
		velocity.y += delta
		
	velocity /= PLAYER_SPEED
	
	$".".position += velocity
