/obj/item/flashbulb/bomb
	name = "suspicious flashbulb"
	desc = "A powerful flashbulb that looks slightly off, with strange wires running out the back."
	charges_left = 15

/obj/item/flashbulb/bomb/use_flashbulb()
	explosion(src, -1, 1, 3, 4)
	charges_left = 0
	icon_state = "flashbulbburnt"
	return 1
