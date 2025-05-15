const RANK = ["Ace", "2", "3", "4", "5", "6", "7", "8", "9", "10", "Jack", "Queen", "King"];
const SUIT = ["Hearts", "Diamonds", "Clubs", "Spades"];

func compare_cards_by_rank(card_a, card_b):
	var rank_a = card_a.rank  # card's rank property, e.g. "Ace", "2", etc.
	var rank_b = card_b.rank

	var index_a = RANK.find(rank_a)
	var index_b = RANK.find(rank_b)

	if index_a < index_b:
		return -1
	elif index_a > index_b:
		return 1
	else:
		return 0
