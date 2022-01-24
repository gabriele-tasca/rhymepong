extends Node

export var left_score_label_p: NodePath
onready var left_score_label = get_node(left_score_label_p)

export var right_score_label_p: NodePath
onready var right_score_label = get_node(right_score_label_p)

export var announcement_label_p: NodePath
onready var announcement_label = get_node(announcement_label_p)

export var line_edit_p: NodePath
onready var line_edit = get_node(line_edit_p)

export var side_switcher_p: NodePath
onready var side_switcher = get_node(side_switcher_p)

export var enemy_word_label_p: NodePath
onready var enemy_word_label = get_node(enemy_word_label_p)

export var enemy_word_descript_p: NodePath
onready var enemy_word_descript = get_node(enemy_word_descript_p)

var own_avatar
var enemy_avatar

var used_words = []
var enemy_word: String

func grab_left_side():
	own_avatar = $LeftAvatar
	enemy_avatar = $RightAvatar
	setup_own_avatar()
#	move_movable_ui_to_right_side()

func grab_right_side():
	own_avatar = $RightAvatar
	enemy_avatar = $LeftAvatar
	setup_own_avatar()
#	move_movable_ui_to_left_side()

func setup_own_avatar():
	own_avatar.set_own()

var count = 0
func _input(event):
	if event.is_action_pressed("chatbox-enter"):
		Global.debug("enter")
		if can_hit():
			rhymepong_strike()
	if event.is_action_pressed("ping"):
		Global.online.ping()
	

func move_movable_ui_to_left_side():
	side_switcher.anchor_left = 0
	side_switcher.anchor_right = 0
	side_switcher.margin_left = 0
	side_switcher.margin_right = 290

func move_movable_ui_to_right_side():
	side_switcher.anchor_left = 1
	side_switcher.anchor_right = 1
	side_switcher.margin_left = -290
	side_switcher.margin_right = 0

func can_hit():
	if Global.is_left_side():
		return (is_ball_on_left_side() \
				  && $ball.velocity.x <= 0)
	elif Global.is_right_side():
		return (is_ball_on_right_side() \
				  && $ball.velocity.x >= 0)

onready var center = get_viewport().size.x /2
func ball_dist_from_center():
	return ($ball.global_position.x - center)
func is_ball_on_left_side():
	return ball_dist_from_center() < 0
func is_ball_on_right_side():
	return ball_dist_from_center() > 0
	

func hit_ball():
	$ball.velocity.x = $ball.velocity.x* Global.game_settings.hit_accel
	$ball.velocity.x = -$ball.velocity.x


onready var feedback_label = line_edit.get_node("Label")
onready var feedback_label_anim = line_edit.get_node("Label/AnimationPlayer")
func feedback(text):
	feedback_label.text = text
	feedback_label_anim.play("fade")

const BALL = preload("res://scenes/world/ball.tscn")


var serve_v = Vector2(1.0, 0.3)*Global.game_settings.speed
var serve_v_right = serve_v
var serve_v_left = Vector2(-serve_v.x, serve_v.y)

func serve_right():
	serve($ServePosRight.global_position, serve_v_right)

func serve_left():
	serve($ServePosLeft.global_position, serve_v_left)



var letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'

func serve(new_position: Vector2, v: Vector2):
	Global.game_state.serving = false
	
	$ball.global_position = new_position
	$ball.velocity = Vector2.ZERO
	$ball.activate()
	Global.game_state.serving = true
	
	var on_the_side_that_serves = ((v.x > 0 ) == Global.is_right_side())
	
	var starting_letter = letters[randi()% 25]
	if on_the_side_that_serves:
		set_serving_letter(starting_letter)
	else:
		set_waiting_for_enemy_word()
	
	add_word_to_used(starting_letter)
	
	
	yield(get_tree().create_timer(Global.game_settings.serve_pause), "timeout")
	$ball.velocity = v



func goal_left():
	set_score_right(Global.game_state.score.right +1)
	var someone_won = check_winners()
	if someone_won:
		Global.stop_game()
	else:
		announce_right_player_scored()
		serve_left()

func goal_right():
	set_score_left(Global.game_state.score.left +1)
	left_score_label.text = str(Global.game_state.score.left)
	var someone_won = check_winners()
	if someone_won:
		Global.stop_game()
	else:
		announce_left_player_scored()
		serve_right()


func check_winners():
	if Global.game_state.score.left >= Global.game_settings.maxscore:
		announce_left_win()
		return true
	elif Global.game_state.score.right >= Global.game_settings.maxscore:
		announce_right_win()
		return true
	else:
		return false



	

func reset_score():
	set_score_left(0)
	set_score_right(0)

func set_score_right(new_score):
	Global.game_state.score.right = new_score
	right_score_label.text = str(new_score)

func set_score_left(new_score):
	Global.game_state.score.left = new_score
	left_score_label.text = str(new_score)

func begin_new_game():
	reset_score()
	announce_fade("")
	clear_used_words()
	serve_left()
	line_edit.grab_focus()

func rhymepong_strike():
	var word = line_edit.text
	var word_valid = check_word(word, enemy_word)
	if word_valid == false:
		return
#	# success!
	# local
	hit_ball()
	own_avatar.teleport($ball.global_position)
	# remote sync
	var arr = [$ball.global_position.x, $ball.global_position.y, $ball.velocity.x, $ball.velocity.y, word]
	Global.online.send_hit_message(arr)
	add_word_to_used(word)
	line_edit.text = ""
	feedback("NICE!")
	set_waiting_for_enemy_word()
	Global.game_state.serving = false

func check_word(word, l_enemy_word):
	if is_word_already_used(word):
		feedback("ALREADY USED!")
		return false
	if not Global.rhymer.word_exists(word):
		feedback("NOT A WORD!")
		return false
	if Global.game_state.serving == true:
		if not Global.rhymer.check_first_letter_equal(word, l_enemy_word):
			feedback("MUST START WITH "+l_enemy_word.to_upper()+" !")
			return false
	else: # serving == false:
		if not Global.rhymer.check_rhyme(word, l_enemy_word):
			feedback("DOESN'T RHYME!\n(ACCORDING TO THE CMU DICTIONARY)")
			return false
	return true



func read_hit_message(arr):
	$ball.global_position = Vector2(arr[0],arr[1])
	$ball.velocity = Vector2(arr[2],arr[3])
	enemy_avatar.teleport($ball.global_position)
	set_enemy_word(arr[4])
	Global.game_state.serving = false


func read_begin_game_message():
	begin_new_game()

func add_word_to_used(word: String):
	used_words.push_back(word)

func is_word_already_used(word):
	var res = false
	for u in used_words:
		if word == u: res = true
	return res

func clear_used_words():
	used_words = []

func stop_game():
#	self.hide()
	$ball.deactivate()
#	feedback("")
	enemy_word_label.text = ""
	enemy_word_descript.text = ""

func set_enemy_word(word):
	self.enemy_word = word
	enemy_word_descript.text = ("enemy word: ")
	enemy_word_label.text = word
	add_word_to_used(word)

func set_serving_letter(letter):
	self.enemy_word = letter
	enemy_word_descript.text = ("starting letter:")
	enemy_word_label.text = letter

func set_waiting_for_enemy_word():
	enemy_word_descript.text = ("waiting...")
	enemy_word_label.text = ""

#var left_player_str = "PLAYER 1"
#var right_player_str = "PLAYER 2"
#var scores_str = "SCORES!"
#var wins_str = "WINS!"
func announce_left_player_scored():
	announce_fade("PLAYER 1 SCORES!")
	
func announce_right_player_scored():
	announce_fade("PLAYER 2 SCORES!")
	
func announce_left_win():
	announce_nofade("PLAYER 1 WINS!")

func announce_right_win():
	announce_nofade("PLAYER 2 WINS!")

onready var announcement_label_anim_player = announcement_label.get_node("AnimationPlayer")
func announce_fade(string):
	announcement_label.text = string
	announcement_label_anim_player.play("fade")

func announce_nofade(string):
	announcement_label_anim_player.stop()
	announcement_label.modulate = Color.white
	announcement_label.text = string


func show():
	self.visible = true
	own_avatar.say_you()
	$CanvasLayer.get_children()[0].visible = true

func hide():
	self.visible = false
	$CanvasLayer.get_children()[0].visible = false
