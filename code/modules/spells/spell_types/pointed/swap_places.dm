/datum/action/spell/pointed/swap_places
	name = "Switch Places"
	desc = "Swap places with a target you can see"
	button_icon_state = "translocate"

	school = SCHOOL_TRANSLOCATION
	cooldown_time = 5 SECONDS
	spell_requirements = null //This spell is given through either a ring or adminbus, no robes or any other requirements
	antimagic_flags = MAGIC_RESISTANCE

	active_msg = "You prepare to swap places with a target..."
	deactive_msg = "You dispel the translocation."
	cast_range = INFINITY //if they have been granted additional vision range, such as a prophet, they can use that range.


/datum/action/spell/pointed/swap_places/is_valid_spell(mob/user, atom/target)
	. = ..()
	if(!isliving(target))
		return FALSE
	return TRUE

/datum/action/spell/pointed/swap_places/on_cast(mob/living/user, atom/target)
	. = ..()
	var/turf/user_turf = get_turf(user)
	var/turf/target_turf = get_turf(target)
	do_teleport(user, target_turf, asoundin = 'sound/effects/phasein.ogg', channel = TELEPORT_CHANNEL_MAGIC)
	do_teleport(target, user_turf, asoundin = 'sound/effects/phasein.ogg', channel = TELEPORT_CHANNEL_MAGIC)
