extends Node

var host: bool = false setget set_host
var connected:bool = false setget set_connected

func set_host(val):
	_log("set host "+ str(val))
	host = val

func set_connected(val):
	_log("set connected "+str(val))
	connected = val


onready var client = $Client

signal created_game
signal joined_game
signal left_game

func _ready():
	client.connect("lobby_joined", self, "_lobby_joined")
	client.connect("lobby_sealed", self, "_lobby_sealed")
	client.connect("connected", self, "_connected")
	client.connect("disconnected", self, "_disconnected")
	client.rtc_mp.connect("peer_connected", self, "_mp_peer_connected")
	client.rtc_mp.connect("peer_disconnected", self, "_mp_peer_disconnected")
	client.rtc_mp.connect("server_disconnected", self, "_mp_server_disconnect")
	client.rtc_mp.connect("connection_succeeded", self, "_mp_connected")


func _physics_process(delta):
	client.rtc_mp.poll()
	while client.rtc_mp.get_available_packet_count() > 0:
#		var sender_id = client.rtc_mp.get_packet_peer()
		var packet = client.rtc_mp.get_packet().get_string_from_utf8()
		var code = packet.left(1)
		var message = packet.right(1)
		
		# REMOVE
		_log(packet)
		if code == "H":
			Global.world.read_hit_message(JSON.parse(message).result)
		
		if code == "S":
			Global.world.read_serve_message()
		
		if code == "B":
			Global.begin_new_game()
		
		if code == "I":
			Global.stop_game()
	
		if code == "R":
			if Global.is_left_side():
				Global.world.goal_right()
	
		if code == "L":
			if Global.is_right_side():
				Global.world.goal_left()


func _connected(id):
	_log("Signaling server connected with ID: %d" % id)

func _disconnected():
	_log("Signaling server disconnected")
#	if host == false:
#		Global.leave_room()
#	else:
#		Global.stop_game()

func _lobby_joined(lobby):
	Global.actually_created_room(lobby)
	_log("Signaling server lobby joined")

func _lobby_sealed():
	_log("Signaling server lobby has been sealed")




func _mp_connected():
	_log("Multiplayer is connected (I am %d)" % client.rtc_mp.get_unique_id())

func _mp_server_disconnect():
	Global.leave_room()
	_log("_mp_server_disconnect THIS")

func _mp_peer_connected(id: int):
	connected = true
	if client.rtc_mp.get_unique_id() == 1:
	# we are the host, and a client just connected to our room
		Global.found_partner()
		client.seal_lobby()
	else:
		# we are the client, and we just connected to the host's room
		Global.found_room()
		host = false
	_log("MP peer connected")


func _mp_peer_disconnected(id: int):
	Global.leave_room()
	_log("mp peer disconnected (left room)")
#	if host == false:
#		Global.leave_room()
#		_log("mp peer disconnected (left room)")
#	else:
#		Global.stop_game()
#		connected = false
#		_log("mp peer disconnected (stopped game)")


func ping():
	_log(client.rtc_mp.put_packet("ping".to_utf8()))
	_log(client.rtc_mp.get_unique_id())


func create_room(room_name):
	client.start(Global.websocket_url, room_name, true)
	host = true

func join_room(lobby_code):
	client.start(Global.websocket_url, lobby_code, false)

func leave_room():
	connected = false
	client.stop()


func stop():
	client.stop()


# REIMPLEMENT
func _log(message):
	Global.debug(message)

# REMOVE
func send_hit_message(arr):
	if connected == true:
		var jstr = JSON.print(arr)
		client.rtc_mp.put_packet(("H"+jstr).to_utf8())

func send_begin_game_message():
	if connected == true:
		client.rtc_mp.put_packet(("B").to_utf8())

func send_stop_game_message():
	if connected == true:
		client.rtc_mp.put_packet(("I").to_utf8())

func send_goal_right_message():
	if connected == true:
		client.rtc_mp.put_packet(("R").to_utf8())

func send_goal_left_message():
	if connected == true:
		client.rtc_mp.put_packet(("L").to_utf8())


