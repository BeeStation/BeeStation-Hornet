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
		if(iscyborg(user) && user.has_buckled_mobs())
			var/mob/living/silicon/robot/R = user
			var/datum/component/riding/riding_datum = R.GetComponent(/datum/component/riding)
			if(riding_datum)
				for(var/mob/M in R.buckled_mobs)
					riding_datum.force_dismount(M)
			else
				R.unbuckle_all_mobs()

/datum/emote/inhale
	key = "inhale"
	key_third_person = "inhales"
	message = "breathes in"

/datum/emote/exhale
	key = "exhale"
	key_third_person = "exhales"
	message = "breathes out"
