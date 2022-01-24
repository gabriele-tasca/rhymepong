extends Node2D


#
## insanity looms.
## there are at least four relevant cases.
## ITCH BUILD + REMOTE SERVER: 
##         needs SSL.
##         url: "wss://frozen-woodland-25572.herokuapp.com:443" CONFIRMED
## NATIVE + REMOTE SERVER:
##         needs NO SSL. it needs SSL to NOT be used.
##         url: "ws://frozen-woodland-25572.herokuapp.com:80" ALMOST CONFIRMED
##            note that in the theoretical future people might want to have SSL 
##               working in this case (from native) as well   
## NATIVE + LOCALHOST:
##         needs NO SSL. it needs SSL to NOT be used.
##         url: "ws://localhost:9080" CONFIRMED
## ITCH BUILD + LOCALHOST:
##         don't care about this right now.
##         probably needs no SSL, but whatever.
#
#onready var localhost = decide_if_localhost()
#
#
## for HTML5, always go remote, in case I fuck up and upload 
##    a debug build. localhost from itch doesn't work anyway.
## for native, go localhost only if debugging.
##    this correctly sends the F5 debug to localhost,
##    but means that when exporting native builds debug has 
##    to be turned off.
#func decide_if_localhost():
##	return false
#	if OS.get_name() == "HTML5":
#		return false
#	else:
#		return OS.is_debug_build()
#
#
#func get_websocket_url():
#	if localhost == true:
#		# LOCALHOST is always the same.
#		return "ws://localhost:9080"
#	else:
#		if OS.get_name() == "HTML5":
#			# REMOTE HTML5 (ITCH BUILD)
#			return "wss://still-basin-28484.herokuapp.com:443"
#		else:
#			# REMOTE NATIVE (F5 testing)
#			return "ws://still-basin-28484.herokuapp.com:80"


#onready var websocket_url = get_websocket_url()


#onready var websocket_url = "wss://still-basin-28484.herokuapp.com:443"
onready var websocket_url = "wss://mysterious-castle-01746.herokuapp.com:443"
#onready var websocket_url = "ws://localhost:9080"


#################################
#################################
#################################
#################################
#################################
#################################





var room_code

onready var online = get_node("/root/main/online")
onready var UI = get_node("/root/main/UI_main")
onready var world = get_node("/root/main/world")
onready var rhymer = get_node("/root/main/rhymer")
onready var UI_ingame = get_node("/root/main/UI_ingame")
onready var debuglabel = get_node("/root/main/debuglabel")

enum WORDLIST {ENGLISH, FORSEN}

var game_settings = {\
	"wordlist": WORDLIST.ENGLISH, \
	"speed": 160, \
	"serve_pause": 1.5, \
	"maxscore": 5, \
	"hit_accel": 1.25 \
}

var game_state = {"score": {"left": 0, "right": 0}, "used_words": [], "serving": true}


enum SIDE {LEFT, RIGHT}
var side

func is_left_side():
	return side == SIDE.LEFT
func is_right_side():
	return side == SIDE.RIGHT


func leave_room():
	stop_game()
	online.leave_room()
	UI_ingame.set_code("")
	UI_ingame.show_room_code()
	UI_ingame.show_waiting_4_opp()
	switch_to_main_screen()

func create_room(room_name):
	online.create_room(room_name)

func join_room(code):
	online.join_room(code)

func actually_created_room(code):
	room_code = code
	UI_ingame.set_code(code)
	switch_to_game_screen()
	
func found_partner():
	# we are the host, and a client just connected to our room
	side = SIDE.LEFT
	world.grab_left_side()
	UI_ingame.hide_room_code()
	UI_ingame.hide_waiting_4_opp()
	# sync game settings !!!!!!!!
	# sync game settings
	# sync game settings
	# sync game settings

func found_room():
	# we are the client, and we just connected to the host's room
	side = SIDE.RIGHT
	world.grab_right_side()
	switch_to_game_screen()
	UI_ingame.hide_room_code()
	UI_ingame.hide_waiting_4_opp()

func decide_to_begin_new_game():
	# local
	begin_new_game()
	# remote
	Global.online.send_begin_game_message()

func begin_new_game():
	world.begin_new_game()
	world.show()
	UI_ingame.switch_to_active_game_view()

func stop_game():
	world.stop_game()
	UI_ingame.switch_to_pregame_view()
	

func _ready():
	switch_to_main_screen()
	randomize()

func switch_to_main_screen():
	UI_ingame.get_children()[0].visible = false
	UI.get_children()[0].visible = true
	world.hide()

func switch_to_game_screen():
	UI.get_children()[0].visible = false
	UI_ingame.get_children()[0].visible = true
	UI_ingame.switch_to_pregame_view()



func debug(text):
	debuglabel.text += ("\n" + str(text))

func lobby_already_exists_alert():
	UI.lobby_already_exists_alert()

func lobby_does_not_exist_alert():
	UI.lobby_does_not_exist_alert()
