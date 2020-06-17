extends Node

var SERVER_IP = "174.116.24.161"
enum STATE{
	DISCONNECTED,
	CONNECTING,
	CONNECTED,
}
var current_state = STATE.DISCONNECTED
var is_server
