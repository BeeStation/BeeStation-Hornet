
/datum/mutation/self_amputation
	name = "Autotomy"
	desc = "Allows a creature to voluntary discard a random appendage."
	quality = POSITIVE
	instability = 30
	power_path = /datum/action/spell/self_amputation

	energy_coeff = 1
	synchronizer_coeff = 1

/datum/action/spell/self_amputation
	name = "Drop a limb"
	desc = "Concentrate to make a random limb pop right off your body."
	button_icon_state = "autotomy"
	mindbound = FALSE
	cooldown_time = 10 SECONDS
	spell_requirements = NONE

/datum/action/spell/self_amputation/is_valid_spell(mob/user, atom/target)
	return iscarbon(user)

/datum/action/spell/self_amputation/on_cast(mob/living/carbon/user, atom/target)
	. = ..()
	if(HAS_TRAIT(user, TRAIT_NODISMEMBER))
		to_chat(user, ("<span class='notice'>You concentrate really hard, but nothing happens.</span>"))
		return

	var/list/parts = list()
	for(var/obj/item/bodypart/to_remove as anything in user.bodyparts)
		if(to_remove.body_zone == BODY_ZONE_HEAD || to_remove.body_zone == BODY_ZONE_CHEST)
			continue
		if(to_remove.bodypart_flags & BODYPART_UNREMOVABLE)
			continue
		parts += to_remove

	if(!length(parts))
		to_chat(user, ("<span class='notice'>You can't shed any more limbs!</span>"))
		return

	var/obj/item/bodypart/to_remove = pick(parts)
	to_remove.dismember()
