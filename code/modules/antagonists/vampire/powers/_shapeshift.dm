/datum/action/vampire/shapeshift
	power_flags = BP_AM_TOGGLE
	check_flags = BP_CANT_USE_IN_TORPOR | BP_CANT_USE_WHILE_STAKED | BP_CANT_USE_IN_FRENZY | BP_CANT_USE_WHILE_INCAPACITATED | BP_CANT_USE_WHILE_UNCONSCIOUS

	/// A typepath to the mob we will shapeshift into
	var/mob/shapeshifted_mob

/datum/action/vampire/shapeshift/activate_power()
	. = ..()
	// This power cannot be used unless the owner is a carbon. This can't runtime
	var/mob/living/living_owner = owner
	living_owner.do_shapeshift(shapeshifted_mob)

/datum/action/vampire/shapeshift/deactivate_power()
	. = ..()
	var/mob/living/living_owner = owner
	var/percent_damage_taken = living_owner.get_total_damage() / living_owner.maxHealth

	living_owner.do_unshapeshift()
	living_owner = owner // Our owner reference is now invalid, reacquire it

	// Unshapeshifting will fully heal the vampire, so we store the sustained damage beforehand and then reapply it as brute
	living_owner.adjustBruteLoss(percent_damage_taken * living_owner.maxHealth)
