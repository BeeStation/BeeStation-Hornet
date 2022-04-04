//The code execution of the emote datum is located at code/datums/emotes.dm
/mob/proc/emote(act, m_type = null, message = null, intentional = FALSE)
	act = lowertext(act)
	var/param = message
	var/custom_param = findchar(act, " ")
	if(custom_param)
		param = copytext(act, custom_param + length(act[custom_param]))
		act = copytext(act, 1, custom_param)


	var/list/key_emotes = GLOB.emote_list[act]

//MonkeStation Edit Start: /tg/ Hotkey Emotes
	if(!length(key_emotes))
		if(intentional)
			to_chat(src, "<span class='notice'>'[act]' emote does not exist. Say *help for a list.</span>")
		return FALSE
	var/silenced = FALSE
	for(var/datum/emote/P in key_emotes)
		if(!P.check_cooldown(src, intentional))
			silenced = TRUE
			continue
		if(P.run_emote(src, param, m_type, intentional))
			src.emote_cooling_down = TRUE
			addtimer(CALLBACK(src, /mob/proc/reset_emote_cooldown), 0.75 SECONDS)
			return TRUE
	if(intentional && !silenced)
		to_chat(src, "<span class='notice'>Unusable emote '[act]'. Say *help for a list.</span>")
	return FALSE
//MonkeStation Edit End

/datum/emote/flip
	key = "flip"
	key_third_person = "flips"
	restraint_check = TRUE
	mob_type_allowed_typecache = list(/mob/living, /mob/dead/observer)
	mob_type_ignore_stat_typecache = list(/mob/dead/observer)

//MonkeStation Edit: /tg/ emote hotkeys
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
				"<span class='notice'>[flippy_mcgee] attempts to do a flip and falls over, what a doofus!</span>",
				"<span class='notice'>You attempt to do a flip while still off balance from the last flip and fall down!</span>"
			)
			if(prob(50))
				flippy_mcgee.adjustBruteLoss(1)
		else
			flippy_mcgee.visible_message(
				"<span class='notice'>[flippy_mcgee] stumbles a bit after their flip.</span>",
				"<span class='notice'>You stumble a bit from still being off balance from your last flip.</span>"
			)
//MonkeStation Edit End

/datum/emote/flip/run_emote(mob/user, params , type_override, intentional)
	. = ..()
	if(.)
		user.SpinAnimation(7,1)
		if(isliving(user) && intentional)
			var/mob/living/L = user
			//MonkeStation Edit: Hat Loss
			if(iscarbon(L))
				var/mob/living/carbon/hat_loser = user
				if(hat_loser.head)
					var/obj/item/clothing/head/worn_headwear = hat_loser.head
					if(worn_headwear.contents.len)
						worn_headwear.throw_hats(rand(2,3), get_turf(hat_loser), hat_loser)
			//MonkeStation Edit End
			L.confused += 2

/datum/emote/spin
	key = "spin"
	key_third_person = "spins"
	restraint_check = TRUE
	mob_type_allowed_typecache = list(/mob/living, /mob/dead/observer)
	mob_type_ignore_stat_typecache = list(/mob/dead/observer)

/datum/emote/spin/run_emote(mob/user, params ,  type_override, intentional)
	. = ..()
	if(.)
		user.spin(20, 1)
		if(isliving(user) && intentional)
			var/mob/living/L = user
			//MonkeStation Edit: Hat Loss
			if(iscarbon(L))
				var/mob/living/carbon/hat_loser = user
				if(hat_loser.head)
					var/obj/item/clothing/head/worn_headwear = hat_loser.head
					if(worn_headwear.contents.len)
						worn_headwear.throw_hats(rand(1,2), get_turf(hat_loser), hat_loser)
			//MonkeStation Edit End
			L.confused += 2
		if(iscyborg(user) && user.has_buckled_mobs())
			var/mob/living/silicon/robot/R = user
			var/datum/component/riding/riding_datum = R.GetComponent(/datum/component/riding)
			if(riding_datum)
				for(var/mob/M in R.buckled_mobs)
					riding_datum.force_dismount(M)
			else
				R.unbuckle_all_mobs()
