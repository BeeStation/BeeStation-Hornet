//Hulk turns your skin green, and allows you to punch through walls.
/datum/mutation/hulk
	name = "Hulk"
	desc = "A poorly understood genome that causes the holder's muscles to expand, inhibit speech and gives the person a bad skin condition."
	quality = POSITIVE
	locked = TRUE
	difficulty = 16
	species_allowed = list(SPECIES_HUMAN) //no skeleton/lizard hulk
	mobtypes_allowed = list(/mob/living/carbon/human)
	health_req = 25
	instability = 40
	var/bodypart_color = COLOR_DARK_LIME
	traits = list(
		TRAIT_CHUNKYFINGERS,
		TRAIT_HULK,
		TRAIT_STUNIMMUNE,
		TRAIT_PUSHIMMUNE,
		TRAIT_CONFUSEIMMUNE,
		TRAIT_IGNOREDAMAGESLOWDOWN,
		TRAIT_NOSTAMCRIT,
		TRAIT_NOLIMBDISABLE,
		TRAIT_FAST_CUFF_REMOVAL
	)

/datum/mutation/hulk/on_acquiring(mob/living/carbon/human/owner)
	. = ..()
	if(!.)
		return
	for(var/obj/item/bodypart/part as anything in owner.bodyparts)
		part.add_color_override(bodypart_color, LIMB_COLOR_HULK)
	owner.update_body_parts()
	SEND_SIGNAL(owner, COMSIG_ADD_MOOD_EVENT, "hulk", /datum/mood_event/hulk)
	RegisterSignal(owner, COMSIG_MOB_SAY, PROC_REF(handle_speech))

/datum/mutation/hulk/on_attack_hand(atom/target, proximity)
	if(proximity) //no telekinetic hulk attack
		return target.attack_hulk(owner)

/datum/mutation/hulk/on_life(delta_time, times_fired)
	if(owner.health < 0)
		on_losing(owner)
		to_chat(owner, span_danger("You suddenly feel very weak."))
		qdel(src)

/datum/mutation/hulk/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	for(var/obj/item/bodypart/part as anything in owner.bodyparts)
		part.remove_color_override(LIMB_COLOR_HULK)
	owner.update_body_parts()
	SEND_SIGNAL(owner, COMSIG_CLEAR_MOOD_EVENT, "hulk")
	UnregisterSignal(owner, COMSIG_MOB_SAY)

/datum/mutation/hulk/proc/handle_speech(datum/source, list/speech_args)
	SIGNAL_HANDLER

	var/message = speech_args[SPEECH_MESSAGE]
	if(message)
		message = "[replacetext(message, ".", "!")]!!"
	speech_args[SPEECH_MESSAGE] = message
	return COMPONENT_UPPERCASE_SPEECH
