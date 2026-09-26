/datum/mutation/overload
	name = "Overload"
	desc = "Allows an Ethereal to overload their skin to cause a bright flash."
	quality = POSITIVE
	locked = TRUE
	instability = 30
	power_path = /datum/action/spell/overload
	species_allowed = list(SPECIES_ETHEREAL)

/datum/action/spell/overload
	name = "Overload"
	desc = "Concentrate to make your skin energize."
	spell_requirements = null
	cooldown_time = 60 SECONDS
	button_icon_state = "blind"
	mindbound = FALSE
	var/max_distance = 4

/datum/action/spell/overload/on_cast(mob/user, atom/target)
	. = ..()
	if(!isethereal(user))
		return

	var/list/mob/targets = oviewers(max_distance, get_turf(user))
	to_chat(targets, "<span class='disarm'>[user] emits a blinding light!</span>")
	for(var/mob/living/carbon/C in targets)
		if(C.flash_act(1))
			C.Paralyze(10 + (5*max_distance))

/datum/mutation/overload/modify()
	if(power_path)
		var/datum/action/spell/overload/S = power_path
		S.max_distance = 4 * GET_MUTATION_POWER(src)
