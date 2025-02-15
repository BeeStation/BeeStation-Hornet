/datum/religion_rites
	/// name of the religious rite
	var/name = "religious rite"
	/// Description of the religious rite
	var/desc = "immm gonna rooon"
	/// length it takes to complete the ritual
	var/ritual_length = (10 SECONDS) //total length it'll take
	/// list of invocations said (strings) throughout the rite
	var/list/ritual_invocations //strings that are by default said evenly throughout the rite
	/// message when you invoke
	var/invoke_msg
	var/favor_cost = 0
	/// does the altar auto-delete the rite
	var/auto_delete = TRUE

/datum/religion_rites/New()
	. = ..()
	if(!GLOB?.religious_sect)
		return
	LAZYADD(GLOB.religious_sect.active_rites, src)

/datum/religion_rites/Destroy()
	if(!GLOB?.religious_sect)
		return
	LAZYREMOVE(GLOB.religious_sect.active_rites, src)
	return ..()

/datum/religion_rites/proc/can_afford(mob/living/user)
	if(GLOB.religious_sect?.favor < favor_cost)
		to_chat(user, span_warning("This rite requires more favor!"))
		return FALSE
	return TRUE

///Called to perform the invocation of the rite, with args being the performer and the altar where it's being performed. Maybe you want it to check for something else?
/datum/religion_rites/proc/perform_rite(mob/living/user, atom/religious_tool)
	if(!can_afford(user))
		return FALSE
	var/turf/T = get_turf(religious_tool)
	if(!T.is_holy())
		to_chat(user, span_warning("The altar can only function in a holy area!"))
		return FALSE
	if(!GLOB.religious_sect.altar_anchored)
		to_chat(user, span_warning("The altar must be secured to the floor if you wish to perform the rite!"))
		return FALSE
	to_chat(user, span_notice("You begin to perform the rite of [name]..."))
	if(!ritual_invocations)
		if(do_after(user, delay = ritual_length, target = user))
			return TRUE
		return FALSE
	var/first_invoke = TRUE
	for(var/i in ritual_invocations)
		if(!GLOB.religious_sect.altar_anchored)
			to_chat(user, span_warning("The altar must be secured to the floor if you wish to perform the rite!"))
			return FALSE
		if(first_invoke) //instant invoke
			user.say(i)
			first_invoke = FALSE
			continue
		if(!length(ritual_invocations)) //we divide so we gotta protect
			return FALSE
		if(!do_after(user, delay = ritual_length/length(ritual_invocations), target = user))
			return FALSE
		user.say(i)
	if(!do_after(user, delay = ritual_length/length(ritual_invocations), target = user)) //because we start at 0 and not the first fraction in invocations, we still have another fraction of ritual_length to complete
		return FALSE
	if(!GLOB.religious_sect.altar_anchored)
		to_chat(user, span_warning("The altar must be secured to the floor if you wish to perform the rite!"))
		return FALSE
	if(invoke_msg)
		user.say(invoke_msg)
	return TRUE


///Does the thing if the rite was successfully performed. return value denotes that the effect successfully (IE a harm rite does harm)
/datum/religion_rites/proc/invoke_effect(mob/living/user, atom/religious_tool)
	SHOULD_CALL_PARENT(TRUE)
	GLOB.religious_sect.on_riteuse(user,religious_tool)
	return TRUE
