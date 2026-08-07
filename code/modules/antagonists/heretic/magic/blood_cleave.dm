/datum/action/spell/pointed/cleave
	name = "Cleave"
	desc = "Causes severe bleeding on a target and several targets around them."
	background_icon_state = "bg_heretic"
	button_icon = 'icons/hud/actions/actions_ecult.dmi'
	button_icon_state = "cleave"
	ranged_mousepointer = 'icons/effects/mouse_pointers/throw_target.dmi'

	school = SCHOOL_FORBIDDEN
	cooldown_time = 40 SECONDS

	invocation = "CL'VE!"
	invocation_type = INVOCATION_WHISPER
	spell_requirements = NONE

	cast_range = 9
	/// The radius of the cleave effect
	var/cleave_radius = 1

/datum/action/spell/pointed/cleave/is_valid_spell(mob/user, atom/target)
	return ..() && ishuman(target)

/datum/action/spell/pointed/cleave/on_cast(mob/user, atom/target)
	. = ..()
	var/list/mob/living/carbon/human/nearby = list(target)
	for(var/mob/living/carbon/human/nearby_human in range(cleave_radius, target))
		nearby += nearby_human

	for(var/mob/living/carbon/human/victim as anything in nearby)
		if(victim == owner || IS_HERETIC_OR_MONSTER(victim))
			continue
		if(victim.can_block_magic(MAGIC_RESISTANCE|MAGIC_RESISTANCE_HOLY))
			victim.visible_message(
				span_danger("[victim]'s body flashes in a fiery glow, but repels the blaze!"),
				span_danger("Your body begins to flash in a fiery glow, but you are protected!")
			)
			continue
		if(!victim.blood_volume)
			continue
		victim.visible_message(
			span_danger("[victim]'s veins are shredded from within as an unholy blaze erupts from [victim.p_their()] blood!"),
			span_danger("Your veins burst from within and unholy flame erupts from your blood!")
		)
		var/obj/item/bodypart/bodypart = pick(victim.bodyparts)
		victim.apply_damage(20, BURN, bodypart)

		new /obj/effect/temp_visual/cleave(get_turf(victim))

	return TRUE

/datum/action/spell/pointed/cleave/long
	name = "Lesser Cleave"
	cooldown_time = 60 SECONDS

/obj/effect/temp_visual/cleave
	icon = 'icons/effects/eldritch.dmi'
	icon_state = "cleave"
	duration = 6
