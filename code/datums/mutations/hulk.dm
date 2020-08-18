//Hulk turns your skin green, and allows you to punch through walls.
/datum/mutation/human/hulk
	name = "Hulk"
	desc = "A poorly understood genome that causes rapid muscular growth and accelerated adrenaline production, as well as heavy brain damage and skin defects."
	quality = POSITIVE
	locked = TRUE
	difficulty = 16
	text_gain_indication = "<span class='notice'>Your muscles hurt!</span>"
	health_req = 25
	instability = 40
	locked = TRUE
	var/cachedcolor = null

/datum/mutation/human/hulk/on_acquiring(mob/living/carbon/human/owner)
	if(..())
		return
	ADD_TRAIT(owner, TRAIT_STUNIMMUNE, TRAIT_HULK)
	ADD_TRAIT(owner, TRAIT_PUSHIMMUNE, TRAIT_HULK)
	ADD_TRAIT(owner, TRAIT_CONFUSEIMMUNE, TRAIT_HULK)
	ADD_TRAIT(owner, TRAIT_IGNOREDAMAGESLOWDOWN, TRAIT_HULK)
	ADD_TRAIT(owner, TRAIT_NOSTAMCRIT, TRAIT_HULK)
	ADD_TRAIT(owner, TRAIT_NOLIMBDISABLE, TRAIT_HULK)
	ADD_TRAIT(owner, TRAIT_NOGUNS, TRAIT_HULK)
	owner.update_body_parts()
	SEND_SIGNAL(owner, COMSIG_ADD_MOOD_EVENT, "hulk", /datum/mood_event/hulk)
	RegisterSignal(owner, COMSIG_MOB_SAY, .proc/handle_speech)
	if(owner.dna.species.use_skintones)
		cachedcolor = owner.skin_tone
		owner.skin_tone = "green"
	else if(MUTCOLORS in owner.dna.species.species_traits)
		cachedcolor = owner.dna.features["mcolor"]
		owner.dna.features["mcolor"] = "7f0"
	owner.regenerate_icons()
	owner.dna.species.punchdamage += 8 //this is so much easier. hulks do about 15 base damage. Simple.

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
	REMOVE_TRAIT(owner, TRAIT_NOGUNS, TRAIT_HULK)
	owner.update_body_parts()
	SEND_SIGNAL(owner, COMSIG_CLEAR_MOOD_EVENT, "hulk")
	owner.dna.species.punchdamage -= 8
	if(owner.dna.species.use_skintones)
		owner.skin_tone = cachedcolor
	else if(MUTCOLORS in owner.dna.species.species_traits)
		owner.dna.features["mcolor"] = cachedcolor
	owner.regenerate_icons()

/datum/mutation/human/hulk/proc/handle_speech(original_message, wrapped_message)
	var/message = wrapped_message[1]
	if(message)
		message = "[replacetext(message, ".", "!")]!!"
	wrapped_message[1] = message
	return COMPONENT_UPPERCASE_SPEECH
