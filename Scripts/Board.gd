extends Node2D

var player_deck = []

@onready var label = Label.new()

func _ready() -> void:
	init_deck()
	deal_cards()
	place_stock_pile()
	place_foundation()

func _process(_delta) -> void:
	label.text = str(GameManager.deck.size())

func init_deck():
	# Access the constants via the card_database instance
	for suit in CardDatabase.SUIT:
		for rank in CardDatabase.RANK:
			var card = preload("res://Scenes/Card.tscn").instantiate()
			card.name = "Card"
			card.rank = rank
			card.suit = suit
			player_deck.append(card)
			GameManager.deck.append(card)
			
	#7, 9, 10
	GameManager.deck.shuffle()
	
	#adding deck size
	label.set_position(Vector2(GameManager.PILE_X_OFFSET - 310, GameManager.PILE_Y_OFFSET - 100))
	add_child(label)

func place_foundation():
	for i in range(4):
		var foundation = preload("res://Scenes/cardslot.tscn").instantiate()
		foundation.position = GameManager.get_pile_position(i * 1.5, 0, GameManager.PILE_X_OFFSET - 100, GameManager.PILE_Y_OFFSET - 250)
		add_child(foundation)

func deal_cards():
	for i in range(GameManager.NO_OF_PILES):
		var pile = GameManager.piles[i] 
		
		#create empty card
		var empty_card = preload("res://Scenes/Card.tscn").instantiate()
		empty_card.flip()
		empty_card.position = GameManager.get_pile_position(i, 0, GameManager.PILE_X_OFFSET, GameManager.PILE_Y_OFFSET)
		empty_card.pile_id = i
		empty_card.z_index = -1
		pile.append(empty_card)
		add_child(empty_card)
		
		for j in range(0, i + 1):
			var card = GameManager.deck.pop_back()
			card.z_index = j
			if j == i:
				card.flip()
			card.position = GameManager.get_pile_position(i, j, GameManager.PILE_X_OFFSET, GameManager.PILE_Y_OFFSET)
			card.pile_id = i
			pile.append(card)
			add_child(card)

func place_stock_pile():
	#place the remaining cards on a stock pile
	for i in range(len(GameManager.deck) - 1):
		var card = GameManager.deck[i]
		card.stock = true
		card.position = GameManager.get_pile_position(
			0, 0, GameManager.PILE_X_OFFSET - 300, GameManager.PILE_Y_OFFSET + 30
		)
		add_child(card)
	
	#place the last card from set below the deck for use
	var last_card = GameManager.deck[-1]
	last_card.stock = false
	last_card.flip()
	last_card.position = GameManager.get_pile_position(
		0, 0,  GameManager.PILE_X_OFFSET - 300, GameManager.PILE_Y_OFFSET + 300
	)
	add_child(last_card)
