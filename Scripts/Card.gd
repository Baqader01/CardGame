extends Node

#emit signals to card manager
signal hovered
signal hovered_off

var hand_position

func _on_area_2d_mouse_entered() -> void:
	emit_signal("hovered", self)


func _on_area_2d_mouse_exited() -> void:
	emit_signal("hovered_off", self)

func _ready() -> void:
	get_parent().connect_card_signals(self)
