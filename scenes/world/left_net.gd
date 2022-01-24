extends Area2D

onready var world = get_parent()

func ball_entered():
	if Global.is_left_side():
		world.goal_left()
		Global.online.send_goal_left_message()
