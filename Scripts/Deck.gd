extends Node2D

const CARD_SCENE_PATH = "res://Scenes/Card.tscn"
const CARD_DRAW_SPEED = 0.2
const MAX_CARD_COUNT = 3

var card_count = 0

var player_deck = []

var card_database_reference 

func _ready() -> void:
	card_database_reference = preload("res://Scripts/CardDatabase.gd")
	
	# Access the constants via the card_database instance
	for suit in card_database_reference.SUIT:
		for rank in card_database_reference.RANK:
			player_deck.append({"rank": rank, "suit": suit})
	
	$RichTextLabel.text = str(player_deck.size())
	
	$"../PlayerHand".connect("card_count_changed", on_card_count_changed)

func on_card_count_changed(new_count):
	card_count = new_count

func draw_card():
	card_count += 1 
	if card_count <= MAX_CARD_COUNT:
		var card_drawn = player_deck[0]
		var rank = card_drawn["rank"].to_lower()  # e.g. "ace"
		var suit = card_drawn["suit"].to_lower()  # e.g. "hearts"
		var card_image = "res://assets/Cards/%s_of_%s.png" % [rank, suit]
		
		player_deck.erase(card_drawn)
		
		if player_deck.size() == 0:
			$Area2D/CollisionShape2D.disabled = true
			$Sprite2D.visible = false
			$RichTextLabel.visible =  false
		
		$RichTextLabel.text = str(player_deck.size())
		var card_scene = preload(CARD_SCENE_PATH)
		var new_card = card_scene.instantiate()
		new_card.rank = "Ace"
		new_card.suit = "Hearts"
		new_card.get_node("CardImage").texture = load(card_image)
		$"../CardManager". add_child(new_card)
		new_card.name = "Card"
		$"../PlayerHand".add_card_to_hand(new_card, CARD_DRAW_SPEED)
		
