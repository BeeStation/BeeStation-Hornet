/obj/item/flashbulb/bomb
	name = "suspicious flashbulb"
	desc = "A powerful flashbulb that looks slightly off, with strange wires running out the back."
	charges_left = 15

/obj/item/flashbulb/bomb/use_flashbulb()
	to_chat(usr, "<span class='userdanger'>You press down on the flashbulb and hear a violent hiss!</span>")
	explosion(src, -1, 1, 3, 4)
	charges_left = 0
	icon_state = "flashbulbburnt"
	return FLASH_USE_BURNOUT
