extends Node

var NETWORK_UPDATES_PER_SECOND = 15
var local_id
var player = preload("res://Scenes/Player.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	var arguments = {}
	for argument in OS.get_cmdline_args():
		# Parse valid command-line arguments into a dictionary
		if argument.find("=") > -1:
			var key_value = argument.split("=")
			arguments[key_value[0].lstrip("--")] = key_value[1]
	
	print(OS.get_cmdline_args())
	
	if 'server' in arguments.keys():
		var peer = NetworkedMultiplayerENet.new()
		peer.create_server(5050, 20)
		get_tree().network_peer = peer
		
		Globals.is_server = true
		
	else:
		var peer = NetworkedMultiplayerENet.new()
		peer.create_client(Globals.SERVER_IP, 5050)
		get_tree().network_peer = peer
		Globals.current_state = Globals.STATE.CONNECTING

		get_tree().connect("network_peer_connected", self, "_player_connected")
		get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
		get_tree().connect("connected_to_server", self, "_connected_ok")
		get_tree().connect("connection_failed", self, "_connected_fail")
		get_tree().connect("server_disconnected", self, "_server_disconnected")
		
		Globals.is_server = false

# Called on both clients and server when a peer connects. Send my info to it.
func _player_connected(id):
	print("Client %d connected" % id)
	rpc_id(id, "register_player")

func _player_disconnected(id):
	print("Client %d disconnected" % id)
	get_node("/root/Main/Players/%s" % id).queue_free()

# We connected ok
func _connected_ok():
	print("Connected to server")
	Globals.current_state = Globals.STATE.CONNECTED
	local_id = get_tree().get_network_unique_id()
	
	$Loading.hide()

# Server kicked us
func _server_disconnected():
	print("Kicked from server")
	Globals.current_state = Globals.STATE.DISCONNECTED

# Could not connect to the server
func _connected_fail():
	print("Could not connect to server")
	Globals.current_state = Globals.STATE.DISCONNECTED

remote func register_player():
	# Get the id of the RPC sender.
	var id = get_tree().get_rpc_sender_id()
		
	print("Registering client %d" % id)
	# Store the info
	
	if not Globals.is_server:
		var new_player = player.instance()
		new_player.set_name(str(id))
		new_player.set_network_master(id) # Will be explained later
		get_node("/root/Main/Players").add_child(new_player)
