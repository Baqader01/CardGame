extends Node2D

enum SlotType { FOUNDATION, TABLEAU }

@export var slot_type := SlotType.FOUNDATION
var card_in_slot = false
