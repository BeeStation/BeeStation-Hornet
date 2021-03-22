/mob/living/carbon/alien/humanoid/doUnEquip(obj/item/I, force, newloc, no_move, invdrop = TRUE, was_thrown = FALSE)
	. = ..()
	if(!. || !I)
		return

