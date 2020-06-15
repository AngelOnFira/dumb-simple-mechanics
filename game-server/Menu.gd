extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var SERVER_IP = "174.116.24.161"
enum STATE{
	DISCONNECTED,
	CONNECTING,
	LOBBY,
}
var current_state = STATE.DISCONNECTED

# Player info, associate ID to data
var player_info = {}
# Info we send to other players
var my_info = { username = "" }
# Our local network id
var local_id = -1

# Called when the node enters the scene tree for the first time.
func _ready():
	print("test")
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

	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")

func _player_connected(id):
	print("Client %d connected" % id)
	# Called on both clients and server when a peer connects. Send my info to it.
	rpc_id(id, "register_player", my_info)

func _player_disconnected(id):
	print("Client %d disconnected" % id)
	player_info.erase(id) # Erase player from info.

# We connected ok
func _connected_ok():
	print("Connected to server")
	current_state = STATE.LOBBY
	local_id = get_tree().get_network_unique_id()

# Server kicked us
func _server_disconnected():
	print("Kicked from server")
	current_state = STATE.DISCONNECTED
	player_info = {}

# Could not connect to the server
func _connected_fail():
	print("Could not connect to server")
	current_state = STATE.DISCONNECTED

remote func register_player(info):
	# Get the id of the RPC sender.
	var id = get_tree().get_rpc_sender_id()
	if id == 1:
		id = local_id
		
	print("Registering client %d" % id)
	# Store the info
	player_info[id] = info
	
remotesync func player_username_updated(new_name):
	# Get the id of the RPC sender.
	var id = get_tree().get_rpc_sender_id()
	if id == 1:
		id = local_id
		
	# Store the info
	player_info[id]['username'] = new_name
	
	var users = "Users\n--------\n\n"
	
	for player in player_info.values():
		users += "{username}\n".format(player)
		
	$HBoxContainer/Users.text = users

func _on_username_change(new_text):
	my_info['username'] = new_text
	if current_state == STATE.LOBBY:
		rpc("player_username_updated", new_text)

func _on_Join_pressed():
	if current_state == STATE.DISCONNECTED:
		var peer = NetworkedMultiplayerENet.new()
		peer.create_client(SERVER_IP, 5050)
		get_tree().network_peer = peer
		current_state = STATE.CONNECTING

func _on_Leave_pressed():
	if current_state == STATE.LOBBY:
		get_tree().network_peer.close_connection()
		current_state = STATE.DISCONNECTED
