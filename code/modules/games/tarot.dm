//Some silly tarot cards for predicting when the Clown will die. Ported from TG. https://github.com/tgstation/tgstation/pull/51318/
/obj/item/toy/cards/deck/tarot
	name = "Tarot Card Deck"
	desc = "A full 78 card deck of Tarot Cards, no refunds on false predicitons."
	icon = 'icons/obj/toy.dmi'
	icon_state = "deck_tarot_full"
	deckstyle = "tarot"

/obj/item/toy/cards/deck/tarot/populate_deck()
	for(var/suit in list("Cups", "Wands", "Swords", "Coins"))
		for(var/i in 1 to 10)
			cards += "[i] of [suit]"
		for(var/person in list("Page", "Champion", "Queen", "King"))
			cards += "[person] of [suit]"
	for(var/trump in list("The Magician", "The High Priestess", "The Empress", "The Emperor", "The Hierophant", "The Lover", "The Chariot", "Justice", "The Hermit", "The Wheel of Fortune", "Strength", "The Hanged Man", "Death", "Temperance", "The Devil", "The Tower", "The Star", "The Moon", "The Sun", "Judgement", "The World", "The Fool"))
		cards += "[trump]"

/obj/item/toy/cards/deck/tarot/draw_card(mob/user)
	. = ..()
	if(prob(50))
		var/obj/item/toy/cards/singlecard/C = .
		if(!C)
			return FALSE

		var/matrix/M = matrix()
		M.Turn(180)
		C.transform = M


