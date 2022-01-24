extends Area2D

var velocity: Vector2

var active = false

#func initialize(new_position, start_v):
#	global_position = new_position
#	velocity = start_v
#	visible = true
#	active = true

func activate():
	active = true
	visible = true

func deactivate():
	global_position = Vector2(-9999, -9999)
	active = false
	visible = false

func _physics_process(delta):
	if active:
		self.global_position += velocity * delta


func _on_ball_area_entered(area):
	if area.name == "walls":
		y_bounce()
	else:
		if active:
			if area.has_method("ball_entered"):
				deactivate()
				area.ball_entered()


func y_bounce():
	self.velocity.y *= -1


