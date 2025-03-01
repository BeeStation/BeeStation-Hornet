//The code execution of the emote datum is located at code/datums/emotes.dm
/mob/proc/emote(act, m_type, message, intentional = FALSE)
	var/param = message
	var/custom_param = findchar(act, " ")
	if(custom_param)
		param = copytext(act, custom_param + length(act[custom_param]))
		act = copytext(act, 1, custom_param)

	act = LOWER_TEXT(act)
	var/list/key_emotes = GLOB.emote_list[act]

	if(!length(key_emotes))
		if(intentional)
			to_chat(src, span_notice("'[act]' emote does not exist. Say *help for a list."))
		return FALSE
	var/silenced = FALSE
	for(var/datum/emote/emote in key_emotes)
		if(!emote.check_cooldown(src, intentional))
			silenced = TRUE
			continue
		if(!emote.can_run_emote(src, TRUE, intentional, param))
			continue
		emote.run_emote(src, param, m_type, intentional)
		SEND_SIGNAL(src, COMSIG_MOB_EMOTE, emote, act, m_type, message, intentional)
		//SEND_SIGNAL(src, COMSIG_MOB_EMOTED(emote.key))
		return TRUE
	if(intentional && !silenced)
		to_chat(src, span_notice("Unusable emote '[act]'. Say *help for a list."))
	return FALSE

/datum/emote/flip
	key = "flip"
	key_third_person = "flips"
	hands_use_check = TRUE
	mob_type_allowed_typecache = list(/mob/living, /mob/dead/observer)
	mob_type_ignore_stat_typecache = list(/mob/dead/observer, /mob/living/silicon/ai)
	emote_type = EMOTE_VISIBLE

/datum/emote/flip/run_emote(mob/user, params , type_override, intentional)
	. = ..()
	user.SpinAnimation(7,1)
	if(isliving(user))
		var/mob/living/L = user
		L.confused += 2

/datum/emote/flip/check_cooldown(mob/user, intentional)
	. = ..()
	if(.)
		return
	if(!can_run_emote(user, intentional=intentional))
		return
	if(isliving(user))
		var/mob/living/flippy_mcgee = user
		if(prob(20))
			flippy_mcgee.Knockdown(1 SECONDS)
			flippy_mcgee.visible_message(
				span_notice("[flippy_mcgee] attempts to do a flip and falls over, what a doofus!"),
				span_notice("You attempt to do a flip while still off balance from the last flip and fall down!")
			)
			if(prob(50))
				flippy_mcgee.adjustBruteLoss(1)
		else
			flippy_mcgee.visible_message(
				span_notice("[flippy_mcgee] stumbles a bit after their flip."),
				span_notice("You stumble a bit from still being off balance from your last flip.")
			)

/datum/emote/spin
	key = "spin"
	key_third_person = "spins"
	hands_use_check = TRUE
	mob_type_allowed_typecache = list(/mob/living, /mob/dead/observer)
	mob_type_ignore_stat_typecache = list(/mob/dead/observer)
	emote_type = EMOTE_VISIBLE

/datum/emote/spin/run_emote(mob/user, params ,  type_override, intentional)
	. = ..()
	user.spin(20, 1)

/datum/emote/inhale
	key = "inhale"
	key_third_person = "inhales"
	message = "breathes in"
	emote_type = EMOTE_AUDIBLE | EMOTE_VISIBLE

/datum/emote/exhale
	key = "exhale"
	key_third_person = "exhales"
	message = "breathes out"
	emote_type = EMOTE_AUDIBLE | EMOTE_VISIBLE
