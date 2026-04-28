/obj/item/book/granter/action/spell/charge
	granted_action = /datum/action/spell/charge
	action_name = "charge"
	icon_state ="bookcharge"
	desc = "This book is made of 100% postconsumer wizard."
	remarks = list(
		"I feel ALIVE!",
		"I CAN TASTE THE MANA!",
		"What a RUSH!",
		"I'm FLYING through these pages!",
		"THIS GENIUS IS MAKING IT!",
		"This book is ACTION PAcKED!",
		"HE'S DONE IT",
		"LETS GOOOOOOOOOOOO",
	)

/obj/item/book/granter/action/spell/charge/recoil(mob/living/user)
	. = ..()
	to_chat(user,("<span class='warning'>[src] suddenly feels very warm!</span>"))
	empulse(src, 1, 1)
