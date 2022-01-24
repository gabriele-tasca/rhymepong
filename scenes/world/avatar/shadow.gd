extends Sprite

var fade_rate = 2.3

func _process(delta):
	self.modulate.a -= delta*fade_rate
	if self_modulate.a <= 0: self.queue_free()
