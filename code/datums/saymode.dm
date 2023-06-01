/datum/saymode
	var/key
	var/mode
	var/early = FALSE

//Return FALSE if you have handled the message. Otherwise, return TRUE and saycode will continue doing saycode things.
//user = whoever said the message
//message = the message
//language = the language.
/datum/saymode/proc/handle_message(mob/living/user, message, datum/language/language)
	return TRUE

/datum/saymode/xeno
	key = "a"
	mode = MODE_ALIEN

/datum/saymode/xeno/handle_message(mob/living/user, message, datum/language/language)
	if(user.hivecheck())
		user.alien_talk(message)
	else if("carp" in user.faction)
		user.carp_talk(message)
	return FALSE


/datum/saymode/vocalcords
	key = MODE_KEY_VOCALCORDS
	mode = MODE_VOCALCORDS

/datum/saymode/vocalcords/handle_message(mob/living/user, message, datum/language/language)
	if(iscarbon(user))
		var/mob/living/carbon/C = user
		var/obj/item/organ/vocal_cords/V = C.getorganslot(ORGAN_SLOT_VOICE)
		if(V && V.can_speak_with())
			V.handle_speech(message) //message
			V.speak_with(message) //action
	return FALSE


/datum/saymode/binary //everything that uses .b (silicons, drones, swarmers)
	key = MODE_KEY_BINARY
	mode = MODE_BINARY

/datum/saymode/binary/handle_message(mob/living/user, message, datum/language/language)
	if(isswarmer(user))
		var/mob/living/simple_animal/hostile/swarmer/S = user
		S.swarmer_chat(message)
		return FALSE
	if(isdrone(user))
		var/mob/living/simple_animal/drone/D = user
		D.drone_chat(message)
		return FALSE
	if(user.binarycheck())
		user.robot_talk(message)
		return FALSE
	return FALSE


/datum/saymode/holopad
	key = "h"
	mode = MODE_HOLOPAD

/datum/saymode/holopad/handle_message(mob/living/user, message, datum/language/language)
	if(isAI(user))
		var/mob/living/silicon/ai/AI = user
		AI.holopad_talk(message, language)
		return FALSE
	return TRUE

/datum/saymode/slime_link
	key = MODE_KEY_SLIMELINK
	mode = MODE_SLIMELINK
	early = TRUE

/datum/saymode/slime_link/handle_message(mob/living/user, message, datum/language/_language)
	. = FALSE
	if(!user || !user.mind)
		return TRUE
	if(!length(message))
		return TRUE
	if(ishuman(user))
		var/mob/living/carbon/human/h_user = user
		if(isstargazer(h_user))
			var/datum/species/oozeling/stargazer/stargazer = h_user.dna.species
			stargazer.slime_chat(h_user, message)
			return
	var/datum/weakref/mind_ref = GLOB.slime_linked_with[user.mind]
	var/datum/species/oozeling/stargazer/stargazer = mind_ref?.resolve()
	if(!stargazer || !istype(stargazer))
		return TRUE
	stargazer.slime_chat(user, message)
