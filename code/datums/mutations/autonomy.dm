
/datum/mutation/self_amputation
	name = "Autotomy"
	desc = "Allows a creature to voluntary discard a random appendage."
	quality = POSITIVE
	text_gain_indication = ("<span class='notice'>Your joints feel loose.</span>")
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

/datum/action/spell/self_amputation/is_valid_target(atom/cast_on)
	return iscarbon(cast_on)

/datum/action/spell/self_amputation/cast(mob/living/carbon/cast_on)
	. = ..()
	if(HAS_TRAIT(cast_on, TRAIT_NODISMEMBER))
		to_chat(cast_on, ("<span class='notice'>You concentrate really hard, but nothing happens.</span>"))
		return

	var/list/parts = list()
	for(var/obj/item/bodypart/to_remove as anything in cast_on.bodyparts)
		if(to_remove.body_zone == BODY_ZONE_HEAD || to_remove.body_zone == BODY_ZONE_CHEST)
			continue
		if(!to_remove.dismemberable)
			continue
		parts += to_remove

	if(!length(parts))
		to_chat(cast_on, ("<span class='notice'>You can't shed any more limbs!</span>"))
		return

	var/obj/item/bodypart/to_remove = pick(parts)
	to_remove.dismember()
