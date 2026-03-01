/datum/action/spell/pointed/abyssal_gaze
	name = "Abyssal Gaze"
	desc = "This spell instills a deep terror in your target, temporarily chilling and blinding it."
	ranged_mousepointer = 'icons/effects/mouse_pointers/cult_target.dmi'
	background_icon_state = "bg_demon"
	button_icon_state = "bg_demon_border"


	button_icon = 'icons/hud/actions/actions_cult.dmi'
	button_icon_state = "abyssal_gaze"

	school = SCHOOL_EVOCATION
	cooldown_time = 75 SECONDS
	invocation_type = INVOCATION_NONE
	spell_requirements = NONE
	antimagic_flags = MAGIC_RESISTANCE|MAGIC_RESISTANCE_HOLY

	cast_range = 5
	active_msg = "You prepare to instill a deep terror in a target..."

	/// The duration of the blind on our target
	var/blind_duration = 4 SECONDS
	/// The amount of temperature we take from our target
	var/amount_to_cool = 200

/datum/action/spell/pointed/abyssal_gaze/is_valid_spell(mob/user, atom/target)
	return iscarbon(target)

/datum/action/spell/pointed/abyssal_gaze/on_cast(mob/user, mob/living/carbon/target)
	. = ..()
	if(target.can_block_magic(antimagic_flags))
		to_chat(owner, ("<span class='warning'>The spell had no effect!</span>"))
		to_chat(target, ("<span class='warning'>You feel a freezing darkness closing in on you, but it rapidly dissipates.</span>"))
		return FALSE

	to_chat(target, ("<span class='userdanger'>A freezing darkness surrounds you...</span>"))
	target.playsound_local(get_turf(target), 'sound/hallucinations/i_see_you1.ogg', 50, 1)
	owner.playsound_local(get_turf(owner), 'sound/effects/ghost2.ogg', 50, 1)
	target.set_blindness(blind_duration)
	if(ishuman(target))
		var/mob/living/carbon/human/human_cast_on = target
		human_cast_on.adjust_coretemperature(-amount_to_cool)
	target.adjust_bodytemperature(-amount_to_cool)
