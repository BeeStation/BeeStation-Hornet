//==================================//
// !           Armaments          ! //
//==================================//
/datum/clockcult/scripture/clockwork_armaments
	name = "Clockwork Armaments"
	desc = "Summon clockwork armor and weapons, to be ready for battle."
	tip = "Summon clockwork armor and weapons, to be ready for battle."
	button_icon_state = "clockwork_armor"
	power_cost = 250
	invokation_time = 20
	invokation_text = list("Through courage and hope...", "...we shall protect thee!")
	category = SPELLTYPE_PRESERVATION
	cogs_required = 1

/datum/clockcult/scripture/clockwork_armaments/invoke_success()
	var/mob/living/M = invoker
	var/datum/antagonist/servant_of_ratvar/servant = is_servant_of_ratvar(M)
	if(!servant)
		return FALSE
	//Equip mob with gamer gear
	var/static/datum/outfit/clockcult/armaments/armaments = new
	armaments.equip(M)
