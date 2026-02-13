/datum/action/spell/pointed/blind
	name = "Blind"
	desc = "This spell temporarily blinds a single target."
	button_icon_state = "blind"
	ranged_mousepointer = 'icons/effects/mouse_pointers/blind_target.dmi'

	sound = 'sound/magic/blind.ogg'
	school = SCHOOL_TRANSMUTATION
	cooldown_time = 30 SECONDS
	cooldown_reduction_per_rank = 6.25 SECONDS

	invocation = "STI KALY"
	invocation_type = INVOCATION_WHISPER
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC

	active_msg = "You prepare to blind a target..."

	/// The amount of blind to apply
	var/eye_blind_amount = 10
	/// The amount of blurriness to apply
	var/eye_blur_duration = 40 SECONDS
	/// The duration of the blind mutation placed on the person
	var/blind_mutation_duration = 30 SECONDS

/datum/action/spell/pointed/blind/is_valid_spell(mob/user, atom/target)
	. = ..()
	if(!.)
		return FALSE
	if (target == user)
		return FALSE
	if(!ishuman(target))
		return FALSE

	var/mob/living/carbon/human/human_target = target
	return !human_target.is_blind()

/datum/action/spell/pointed/blind/on_cast(mob/user, mob/living/carbon/human/target)
	. = ..()
	if(target.can_block_magic(antimagic_flags))
		to_chat(target, ("<span class='notice'>Your eye itches, but it passes momentarily.</span>"))
		to_chat(owner, ("<span class='warning'>The spell had no effect!</span>"))
		return FALSE

	to_chat(target, ("<span class='warning'>Your eyes cry out in pain!</span>"))
	target.set_blindness(eye_blind_amount)
	target.set_eye_blur_if_lower(eye_blur_duration)
	return TRUE
