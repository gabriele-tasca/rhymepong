extends CanvasLayer

export var QuitButtonPath: NodePath
onready var QuitButton = get_node(QuitButtonPath)

export var SettingsButtonPath: NodePath
onready var SettingsButton = get_node(SettingsButtonPath)

export var StartGameButtonPath: NodePath
onready var StartGameButton = get_node(StartGameButtonPath)

export var StopGameButtonPath: NodePath
onready var StopGameButton = get_node(StopGameButtonPath)

export var RoomCodePanelPath: NodePath
onready var RoomCodePanel = get_node(RoomCodePanelPath)



export var room_code_line_path: NodePath
onready var room_code_line = get_node(room_code_line_path)

func _on_QuitButton_button_down():
	Global.leave_room()


#func _on_ResetButton_pressed():
#	Global.world.setup_same()
#	Global.online.send_reset_message()

func switch_to_active_game_view():
	StopGameButton.visible = true
	SettingsButton.visible = false
	StartGameButton.visible = false

func switch_to_pregame_view():
	SettingsButton.visible = true
	StartGameButton.visible = true
	StopGameButton.visible = false


func hide_room_code():
	RoomCodePanel.visible = false

func show_room_code():
	RoomCodePanel.visible = true



func _on_SettingsButton_pressed():
	SettingsButton.text = "NOTHING HERE YET!"
	yield(get_tree().create_timer(2), "timeout")
	SettingsButton.text = "GAME SETTINGS"

func set_code(lobby):
	Global.room_code = lobby
	room_code_line.text = lobby
	if lobby != "":
		copy()
		say_copied()


func _on_LineEdit_focus_entered():
	copy()
	say_copied()

func copy():
	OS.set_clipboard(Global.room_code) 

const COPIED = preload("res://scenes/online/copied/copied.tscn")
func say_copied():
	if get_name() != "HTML5":
		var copied = COPIED.instance()
		self.add_child(copied)


func _on_StartGameButton_pressed():
	if (Global.online.connected == true):
		Global.decide_to_begin_new_game()
	else:
		StartGameButton.text = "NOT CONNECTED"
		yield(get_tree().create_timer(2), "timeout")
		StartGameButton.text = "START GAME"
		


func _on_StopGameButton_pressed():
	Global.stop_game()
	Global.online.send_stop_game_message()

func hide_waiting_4_opp():
	$Control/Waiting4OpponentLabel.visible = false

func show_waiting_4_opp():
	$Control/Waiting4OpponentLabel.visible = true
