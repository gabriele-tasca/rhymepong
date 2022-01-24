extends Node2D

const YOU = preload("res://scenes/world/avatar/(you).tscn")

func set_own():
	self.modulate = Color.red

func say_you():
	var you = YOU.instance()
	self.add_child(you)

const SHADOW = preload("res://scenes/world/avatar/shadow.tscn")
var shadow_spacing = 28
var min_alpha = 0.4
func teleport(pos: Vector2):
	var arrow = self.global_position - pos
	var nshadows = arrow.length()/shadow_spacing
	for i in nshadows:
		var prog = (i/nshadows)
		var shadow = SHADOW.instance()
		$shadowroot.add_child(shadow)
		shadow.global_position = (self.global_position + prog*arrow)
		shadow.modulate.a = 1 - prog*(1-min_alpha)
	
	self.global_position = pos
