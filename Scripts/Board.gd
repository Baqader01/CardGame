extends Node2D

var player_deck = []
var waste_pile = []

func _ready() -> void:
	init_deck()
	deal_cards()
	place_stock_pile()
	
	#$RichTextLabel.text = str(player_deck.size())

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
	seed(9)
	GameManager.deck.shuffle()

func deal_cards():
	for i in range(GameManager.NO_OF_PILES):
		var pile = GameManager.piles[i] 
		
		for j in range(0, i + 1):
			var card = GameManager.deck.pop_back()
			card.z_index = j
			if j == i:
				card.flip()
			card.position = GameManager.get_pile_position(i, j, GameManager.PILE_X_OFFSET, GameManager.PILE_Y_OFFSET)
			card.pile_id = i
			pile.append(card)
			add_child(card)
		
		#if player_deck.size() == 0:
			#$Area2D/CollisionShape2D.disabled = true
			#$Sprite2D.visible = false
			#$RichTextLabel.visible =  false
		#$RichTextLabel.text = str(player_deck.size())
		#$"../PlayerHand".add_card_to_hand(new_card, CARD_DRAW_SPEED)
		#waste_pile.insert(0, new_card)

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
	var card = GameManager.deck[-1]
	card.stock = false
	card.flip()
	card.position = GameManager.get_pile_position(
		0, 0,  GameManager.PILE_X_OFFSET - 300, GameManager.PILE_Y_OFFSET + 300
	)
	add_child(card)
