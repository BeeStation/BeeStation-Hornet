//Hulk turns your skin green, and allows you to punch through walls.
/datum/mutation/human/hulk
	name = "Hulk"
	desc = "A poorly understood genome that causes the holder's muscles to expand, inhibit speech and gives the person a bad skin condition."
	quality = POSITIVE
	locked = TRUE
	difficulty = 16
	text_gain_indication = "<span class='notice'>Your muscles hurt!</span>"
	species_allowed = list("human") //no skeleton/lizard hulk
	health_req = 25
	instability = 40
	locked = TRUE

/datum/mutation/human/hulk/on_acquiring(mob/living/carbon/human/owner)
	if(..())
		return
	ADD_TRAIT(owner, TRAIT_STUNIMMUNE, TRAIT_HULK)
	ADD_TRAIT(owner, TRAIT_PUSHIMMUNE, TRAIT_HULK)
	ADD_TRAIT(owner, TRAIT_CONFUSEIMMUNE, TRAIT_HULK)
	ADD_TRAIT(owner, TRAIT_IGNOREDAMAGESLOWDOWN, TRAIT_HULK)
	ADD_TRAIT(owner, TRAIT_NOSTAMCRIT, TRAIT_HULK)
	ADD_TRAIT(owner, TRAIT_NOLIMBDISABLE, TRAIT_HULK)
	owner.update_body_parts()
	SEND_SIGNAL(owner, COMSIG_ADD_MOOD_EVENT, "hulk", /datum/mood_event/hulk)
	RegisterSignal(owner, COMSIG_MOB_SAY, .proc/handle_speech)

/datum/mutation/human/hulk/on_attack_hand(atom/target, proximity)
	if(proximity) //no telekinetic hulk attack
		return target.attack_hulk(owner)

/datum/mutation/human/hulk/on_life()
	if(owner.health < 0)
		on_losing(owner)
		to_chat(owner, "<span class='danger'>You suddenly feel very weak.</span>")

/datum/mutation/human/hulk/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	REMOVE_TRAIT(owner, TRAIT_STUNIMMUNE, TRAIT_HULK)
	REMOVE_TRAIT(owner, TRAIT_PUSHIMMUNE, TRAIT_HULK)
	REMOVE_TRAIT(owner, TRAIT_CONFUSEIMMUNE, TRAIT_HULK)
	REMOVE_TRAIT(owner, TRAIT_IGNOREDAMAGESLOWDOWN, TRAIT_HULK)
	REMOVE_TRAIT(owner, TRAIT_NOSTAMCRIT, TRAIT_HULK)
	REMOVE_TRAIT(owner, TRAIT_NOLIMBDISABLE, TRAIT_HULK)
	owner.update_body_parts()
	SEND_SIGNAL(owner, COMSIG_CLEAR_MOOD_EVENT, "hulk")

/datum/mutation/human/hulk/proc/handle_speech(original_message, wrapped_message)
	var/message = wrapped_message[1]
	if(message)
		message = "[replacetext(message, ".", "!")]!!"
	wrapped_message[1] = message
	return COMPONENT_UPPERCASE_SPEECH
