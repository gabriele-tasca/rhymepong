extends Area2D

onready var world = get_parent()

func ball_entered():
	if Global.is_right_side():
		world.goal_right()
		Global.online.send_goal_right_message()
