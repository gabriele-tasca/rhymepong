extends CanvasLayer

export var join_code_line_path: NodePath
onready var join_code_line = get_node(join_code_line_path)

export var create_code_line_path: NodePath
onready var create_code_line = get_node(create_code_line_path)


export var webgl_p: NodePath
onready var webgl = get_node(webgl_p)

export var top_alert_p: NodePath
onready var top_alert_panel = get_node(top_alert_p)

export var bot_alert_p: NodePath
onready var bot_alert_panel = get_node(bot_alert_p)


func lobby_does_not_exist_alert():
	bot_alert("Room does not exist")

func lobby_already_exists_alert():
	top_alert("A room with that name already exists")

func top_alert(text):
	top_alert_panel.visible = true
	top_alert_panel.get_node("PanelContainer/MarginContainer/Label").text = text
#	yield(get_tree().create_timer(0.5),"timeout")
	top_alert_panel.get_node("AnimationPlayer").stop()
	top_alert_panel.get_node("AnimationPlayer").play("fade")

func bot_alert(text):
	bot_alert_panel.visible = true
	bot_alert_panel.get_node("PanelContainer/MarginContainer/Label").text = text
#	yield(get_tree().create_timer(0.5),"timeout")
	bot_alert_panel.get_node("AnimationPlayer").stop()
	bot_alert_panel.get_node("AnimationPlayer").play("fade")

func _ready():
	create_code_line.text = "room"+str(randi()%899 + 100)

func _on_CreateButton_pressed():
	if create_code_line.text == "":
		top_alert("Room name can't be empty")
	else:
		Global.create_room(create_code_line.text)


func _on_JoinButton_pressed():
	if join_code_line.text != "":
		Global.join_room(join_code_line.text)
	else:
		bot_alert("Room name can't be empty")

func _input(event):
	if OS.get_name() == "HTML5":
		if join_code_line.has_focus():
			if Input.is_action_just_pressed("paste"):
				var clip = OS.get_clipboard()
				join_code_line.text = clip
				if clip == "":
					webgl.visible = true
					yield(get_tree().create_timer(7),"timeout")
					webgl.get_node("AnimationPlayer").play("fade")
