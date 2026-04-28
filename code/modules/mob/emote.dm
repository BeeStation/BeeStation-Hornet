//The code execution of the emote datum is located at code/datums/emotes.dm
/mob/proc/emote(act, type_override = NONE, message, intentional = FALSE, force_silence = FALSE, forced = FALSE)
	var/param = message
	var/custom_param = findchar(act, " ")
	if(custom_param)
		param = copytext(act, custom_param + length(act[custom_param]))
		act = copytext(act, 1, custom_param)

	act = LOWER_TEXT(act)
	var/list/key_emotes = GLOB.emote_list[act]

	if(!length(key_emotes))
		if(intentional && !force_silence)
			to_chat(src, span_notice("'[act]' emote does not exist. Say *help for a list."))
		return FALSE
	var/silenced = FALSE
	for(var/datum/emote/emote in key_emotes)
		if(!emote.check_cooldown(src, intentional))
			silenced = TRUE
			continue
		if(!forced && !emote.can_run_emote(src, TRUE, intentional, param))
			continue
		if(SEND_SIGNAL(src, COMSIG_MOB_PRE_EMOTED, emote.key, param, type_override, intentional, emote) & COMPONENT_CANT_EMOTE)
			silenced = TRUE
			continue
		emote.run_emote(src, param, type_override, intentional)
		SEND_SIGNAL(src, COMSIG_MOB_EMOTE, emote, act, type_override, message, intentional)
		SEND_SIGNAL(src, COMSIG_MOB_EMOTED(emote.key))
		return TRUE
	if(intentional && !silenced && !force_silence)
		to_chat(src, span_notice("Unusable emote '[act]'. Say *help for a list."))
	return FALSE

/datum/emote/help/run_emote(mob/user, params, type_override, intentional)
	. = ..()
	var/list/keys = list()
	var/list/message = list("Available emotes, you can use them with say [span_bold("\"*emote\"")]: \n")
	message += span_smallnoticeital("Note - emotes highlighted in blue play a sound \n\n")

	for(var/key in GLOB.emote_list)
		for(var/datum/emote/emote_action in GLOB.emote_list[key])
			if(emote_action.key in keys)
				continue
			if(emote_action.can_run_emote(user, status_check = FALSE , intentional = TRUE))
				keys += emote_action.key

	keys = sort_list(keys)

	// the span formatting will mess up sorting so need to do it afterwards
	for(var/i in 1 to keys.len)
		for(var/datum/emote/emote_action in GLOB.emote_list[keys[i]])
			if(emote_action.get_sound(user) && emote_action.should_play_sound(user, intentional = TRUE))
				keys[i] = span_boldnotice(keys[i])

	message += keys.Join(", ")
	message += "."
	message = message.Join("")
	to_chat(user, examine_block(message))

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

/datum/emote/living/inhale
	key = "inhale"
	key_third_person = "inhales"
	message = "breathes in"
	emote_type = EMOTE_AUDIBLE | EMOTE_VISIBLE

/datum/emote/living/exhale
	key = "exhale"
	key_third_person = "exhales"
	message = "breathes out"
	emote_type = EMOTE_AUDIBLE | EMOTE_VISIBLE

/datum/emote/jump
	key = "jump"
	key_third_person = "jumps"
	message = "jumps"
	cooldown = 0.8 SECONDS
	emote_type = EMOTE_VISIBLE
	// Allows ghosts to jump
	mob_type_ignore_stat_typecache = list(/mob/dead/observer)

/datum/emote/jump/run_emote(mob/user, params, type_override, intentional)
	. = ..()
	animate(user, 0.1 SECONDS, pixel_y = user.pixel_y + 4)
	animate(time = 0.1 SECONDS, pixel_y = user.pixel_y - 4)
	if(iscarbon(user))
		var/mob/living/carbon/jumps_till_drops = user
		jumps_till_drops.adjustStaminaLoss(10, forced = TRUE)

/datum/emote/jump/get_sound(mob/user)
	return 'sound/weapons/thudswoosh.ogg'

// Avoids playing sounds if we're a ghost
/datum/emote/jump/should_play_sound(mob/user, intentional)
	if(isliving(user))
		return ..()
	return FALSE
