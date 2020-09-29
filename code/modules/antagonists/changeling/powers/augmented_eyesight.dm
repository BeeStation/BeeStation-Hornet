//Augmented Eyesight: Gives you X-ray vision or protection from flashes. Also, high DNA cost because of how powerful it is.
//Possible todo: make a custom message for directing a penlight/flashlight at the eyes - not sure what would display though.

/datum/action/changeling/augmented_eyesight
	name = "Augmented Eyesight"
	desc = "Creates more light sensing rods in our eyes, allowing our vision to penetrate most blocking objects."
	helptext = "Grants us x-ray vision. We will become a lot more vulnerable to flash-based devices while x-ray vision is active."
	button_icon_state = "augmented_eyesight"
	chemical_cost = 0
	dna_cost = 2 //Would be 1 without thermal vision
	active = FALSE

/datum/action/changeling/augmented_eyesight/sting_action(mob/living/carbon/human/user)
	if(!istype(user))
		return
	..()
	var/obj/item/organ/eyes/E = user.getorganslot(ORGAN_SLOT_EYES)
	if(E)
		if(!active)
			E.sight_flags |= SEE_MOBS | SEE_OBJS | SEE_TURFS //Add sight flags to the user's eyes
			E.flash_protect = -1 //Adjust the user's eyes' flash protection
			to_chat(user, "We adjust our eyes to sense prey through walls.")
			active = TRUE //Defined in code/modules/spells/spell.dm
		else
			E.sight_flags ^= SEE_MOBS | SEE_OBJS | SEE_TURFS //Remove sight flags from the user's eyes
			to_chat(user, "We adjust our eyes to protect them from bright lights.")
			E.flash_protect = 0
			active = FALSE
		user.update_sight()
	else
		to_chat(user, "We can't adjust our eyes if we don't have any!")
	return 1


/datum/action/changeling/augmented_eyesight/Remove(mob/user) //Get rid of x-ray vision and flash protection when the user refunds this ability
	var/obj/item/organ/eyes/E = user.getorganslot(ORGAN_SLOT_EYES)
	if(E)
		if (active)
			E.sight_flags ^= SEE_MOBS | SEE_OBJS | SEE_TURFS
		else
			E.flash_protect = 0
		user.update_sight()
	..()
