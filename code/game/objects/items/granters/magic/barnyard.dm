/obj/item/book/granter/action/spell/barnyard
	granted_action = /datum/action/spell/pointed/barnyardcurse
	action_name = "barnyard"
	icon_state ="bookhorses"
	desc = "This book is more horse than your mind has room for."
	remarks = list(
		"Moooooooo!",
		"Moo!",
		"Moooo!",
		"NEEIIGGGHHHH!",
		"NEEEIIIIGHH!",
		"NEIIIGGHH!",
		"HAAWWWWW!",
		"HAAAWWW!",
		"Oink!",
		"Squeeeeeeee!",
		"Oink Oink!",
		"Ree!!",
		"Reee!!",
		"REEE!!",
		"REEEEE!!",
	)

/obj/item/book/granter/action/spell/barnyard/recoil(mob/living/user)
	if(ishuman(user))
		to_chat(user, "<font size='15' color='red'><b>HORSIE HAS RISEN</b></font>")
		var/obj/item/clothing/magic_mask = new /obj/item/clothing/mask/horsehead/cursed(user.drop_location())
		var/mob/living/carbon/human/human_user = user
		if(!user.dropItemToGround(human_user.wear_mask))
			qdel(human_user.wear_mask)
		user.equip_to_slot_if_possible(magic_mask, ITEM_SLOT_MASK, TRUE, TRUE)
		qdel(src)
	else
		to_chat(user,("<span class='notice'>I say thee neigh</span>")) //It still lives here
