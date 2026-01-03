/mob/living/silicon
	gender = NEUTER
	has_unlimited_silicon_privilege = 1
	verb_say = "states"
	verb_ask = "queries"
	verb_exclaim = "declares"
	verb_yell = "alarms"
	initial_language_holder = /datum/language_holder/synthetic
	see_in_dark = NIGHTVISION_FOV_RANGE
	bubble_icon = "machine"
	weather_immunities = list("ash")
	mob_biotypes = MOB_ROBOTIC
	flags_1 = PREVENT_CONTENTS_EXPLOSION_1
	deathsound = 'sound/voice/borg_deathsound.ogg'
	examine_cursor_icon = null
	speech_span = SPAN_ROBOT
	var/datum/ai_laws/laws = null//Now... THEY ALL CAN ALL HAVE LAWS
	var/last_lawchange_announce = 0
	var/list/alarms_to_show = list()
	var/list/alarms_to_clear = list()
	var/designation = ""
	var/radiomod = "" //Radio character used before state laws/arrivals announce to allow department transmissions, default, or none at all.
	var/obj/item/camera/siliconcam/aicamera = null //photography
	hud_possible = list(ANTAG_HUD, DIAG_STAT_HUD, DIAG_HUD, DIAG_TRACK_HUD)

	var/obj/item/radio/borg/radio = null ///If this is a path, this gets created as an object in Initialize.

	var/list/alarm_types_show = list(ALARM_ATMOS = 0, ALARM_FIRE = 0, ALARM_POWER = 0, ALARM_CAMERA = 0, ALARM_MOTION = 0)
	var/list/alarm_types_clear = list(ALARM_ATMOS = 0, ALARM_FIRE = 0, ALARM_POWER = 0, ALARM_CAMERA = 0, ALARM_MOTION = 0)

	var/lawcheck[1]
	var/ioncheck[1]
	var/hackedcheck[1]
	var/devillawcheck[5]

	/// Are our siliconHUDs on? TRUE for yes, FALSE for no.
	var/sensors_on = TRUE
	var/med_hud = DATA_HUD_MEDICAL_ADVANCED //Determines the med hud to use
	var/sec_hud = DATA_HUD_SECURITY_ADVANCED //Determines the sec hud to use
	var/d_hud = DATA_HUD_DIAGNOSTIC_BASIC //Determines the diag hud to use

	var/law_change_counter = 0
	var/obj/machinery/camera/builtInCamera = null
	var/updating = FALSE //portable camera camerachunk update

	var/hack_software = FALSE //Will be able to use hacking actions
	var/interaction_range = 7			//wireless control range
	///The reference to the built-in tablet that borgs carry.
	var/obj/item/modular_computer/tablet/integrated/modularInterface

	//The internal ID card inside the AI.
	var/list/default_access_list = list()
	var/obj/item/card/id/internal_id_card
	var/currently_stating_laws = FALSE

	mobchatspan = "centcom"

/mob/living/silicon/Initialize(mapload)
	. = ..()
	GLOB.silicon_mobs += src
	faction += FACTION_SILICON
	if(ispath(radio))
		radio = new radio(src)
	for(var/datum/atom_hud/data/diagnostic/diag_hud in GLOB.huds)
		diag_hud.add_to_hud(src)
	diag_hud_set_status()
	diag_hud_set_health()
	create_access_card(default_access_list)
	default_access_list = null
	ADD_TRAIT(src, TRAIT_ADVANCEDTOOLUSER, ROUNDSTART_TRAIT)

	ADD_TRAIT(src, TRAIT_MADNESS_IMMUNE, ROUNDSTART_TRAIT)
	ADD_TRAIT(src, TRAIT_MARTIAL_ARTS_IMMUNE, ROUNDSTART_TRAIT)

/mob/living/silicon/Destroy()
	QDEL_NULL(radio)
	QDEL_NULL(aicamera)
	QDEL_NULL(builtInCamera)
	laws?.owner = null //Laws will refuse to die otherwise.
	QDEL_NULL(laws)
	QDEL_NULL(modularInterface)
	QDEL_NULL(internal_id_card)
	GLOB.silicon_mobs -= src
	return ..()

/mob/living/silicon/proc/create_access_card(list/access_list)
	if(!internal_id_card)
		internal_id_card = new()
		internal_id_card.name = "[src] internal access"
	internal_id_card.access |= access_list

/mob/living/silicon/proc/create_modularInterface()
	if(!modularInterface)
		modularInterface = new /obj/item/modular_computer/tablet/integrated(src)
	modularInterface.layer = ABOVE_HUD_PLANE
	modularInterface.plane = ABOVE_HUD_PLANE
	modularInterface.saved_identification = real_name || name
	if(iscyborg(src))
		modularInterface.saved_job = JOB_NAME_CYBORG
		modularInterface.install_component(new /obj/item/computer_hardware/hard_drive/small/pda/robot)
	if(isAI(src))
		modularInterface.saved_job = JOB_NAME_AI
		modularInterface.install_component(new /obj/item/computer_hardware/hard_drive/small/pda/ai)
	if(ispAI(src))
		modularInterface.saved_job = JOB_NAME_PAI
		modularInterface.install_component(new /obj/item/computer_hardware/hard_drive/small/pda/ai)

/mob/living/silicon/med_hud_set_health()
	return //we use a different hud

/mob/living/silicon/med_hud_set_status()
	return //we use a different hud

/mob/living/silicon/contents_explosion(severity, target)
	return

/mob/living/silicon/proc/queueAlarm(message, type, incoming = FALSE)
	var/in_cooldown = (alarms_to_show.len > 0 || alarms_to_clear.len > 0)
	if(incoming)
		alarms_to_show += message
		alarm_types_show[type] += 1
	else
		alarms_to_clear += message
		alarm_types_clear[type] += 1

	if(!in_cooldown)
		addtimer(CALLBACK(src, PROC_REF(handle_alarms)), 30) //3 second cooldown

/mob/living/silicon/proc/handle_alarms()
	if(alarms_to_show.len < 5)
		for(var/msg in alarms_to_show)
			to_chat(src, msg)
	else if(alarms_to_show.len)

		var/msg = "--- "

		for(var/alarm_type in alarm_types_show)
			msg += "[uppertext(alarm_type)]: [alarm_types_show[alarm_type]] alarms detected. - "

		msg += "<a href='byond://?src=[REF(src)];showalerts=1'>\[Show Alerts\]</a>"
		to_chat(src, msg)

	if(alarms_to_clear.len < 3)
		for(var/msg in alarms_to_clear)
			to_chat(src, msg)

	else if(alarms_to_clear.len)
		var/msg = "--- "

		for(var/alarm_type in alarm_types_clear)
			msg += "[uppertext(alarm_type)]: [alarm_types_clear[alarm_type]] alarms cleared. - "

		msg += "<a href='byond://?src=[REF(src)];showalerts=1'>\[Show Alerts\]</a>"
		to_chat(src, msg)

	alarms_to_show = list()
	alarms_to_clear = list()
	for(var/key in alarm_types_show)
		alarm_types_show[key] = 0
	for(var/key in alarm_types_clear)
		alarm_types_clear[key] = 0

/mob/living/silicon/can_inject(mob/user, target_zone, injection_flags)
	return FALSE

/mob/living/silicon/try_inject(mob/user, target_zone, injection_flags)
	. = ..()
	if(!. && (injection_flags & INJECT_TRY_SHOW_ERROR_MESSAGE))
		to_chat(user, "<span class='alert'>[p_Their()] outer shell is too tough.</span>")

/proc/islinked(mob/living/silicon/robot/bot, mob/living/silicon/ai/ai)
	if(!istype(bot) || !istype(ai))
		return FALSE
	if(bot.connected_ai == ai)
		return TRUE
	return FALSE

/mob/living/silicon/Topic(href, href_list)
	if (href_list["lawc"]) // Toggling whether or not a law gets stated by the State Laws verb --NeoFite
		var/L = text2num(href_list["lawc"])
		switch(lawcheck[L+1])
			if ("Yes")
				lawcheck[L+1] = "No"
			if ("No")
				lawcheck[L+1] = "Yes"
		checklaws()

	if (href_list["lawi"]) // Toggling whether or not a law gets stated by the State Laws verb --NeoFite
		var/L = text2num(href_list["lawi"])
		switch(ioncheck[L])
			if ("Yes")
				ioncheck[L] = "No"
			if ("No")
				ioncheck[L] = "Yes"
		checklaws()

	if (href_list["lawh"])
		var/L = text2num(href_list["lawh"])
		switch(hackedcheck[L])
			if ("Yes")
				hackedcheck[L] = "No"
			if ("No")
				hackedcheck[L] = "Yes"
		checklaws()

	if (href_list["lawdevil"]) // Toggling whether or not a law gets stated by the State Laws verb --NeoFite
		var/L = text2num(href_list["lawdevil"])
		switch(devillawcheck[L])
			if ("Yes")
				devillawcheck[L] = "No"
			if ("No")
				devillawcheck[L] = "Yes"
		checklaws()


	if (href_list["laws"] && !currently_stating_laws) // With how my law selection code works, I changed statelaws from a verb to a proc, and call it through my law selection panel. --NeoFite
		statelaws()

	if (href_list["printlawtext"]) // this is kinda backwards
		to_chat(usr, href_list["printlawtext"])

	return


/mob/living/silicon/proc/statelaws(force = FALSE)
	var/mob/living/silicon/S = usr
	var/total_laws_count = 0
	//laws_sanity_check()
	//laws.show_laws(world)
	var/number = 1

	var/list/laws_to_state = list()

	if (laws.zeroth)
		if (force || lawcheck[1] == "Yes")
			laws_to_state += "0. [laws.zeroth]"
			total_laws_count++

	for (var/index in 1 to laws.hacked.len)
		var/law = laws.hacked[index]
		var/num = ion_num()
		if (length(law) > 0)
			if (force || hackedcheck[index] == "Yes")
				laws_to_state += "[num]. [law]"
				total_laws_count++

	for (var/index in 1 to laws.ion.len)
		var/law = laws.ion[index]
		var/num = ion_num()
		if (length(law) > 0)
			if (force || ioncheck[index] == "Yes")
				laws_to_state += "[num]. [law]"
				total_laws_count++

	for (var/index in 1 to laws.inherent.len)
		var/law = laws.inherent[index]

		if (length(law) > 0)
			if (force || lawcheck[index+1] == "Yes")
				laws_to_state += "[number]. [law]"
				total_laws_count++
				number++

	for (var/index in 1 to laws.supplied.len)
		var/law = laws.supplied[index]

		if (length(law) > 0)
			if(lawcheck.len >= number+1)
				if (force || lawcheck[number+1] == "Yes")
					laws_to_state += "[number]. [law]"
					total_laws_count++
					number++

	if(!force)
		var/static/regex/dont_state_regex = regex("Do(?:n'?t| not) state", "i")
		var/list/bad_idea_laws = list()
		for(var/law in laws_to_state)
			if(findtext(law, dont_state_regex))
				bad_idea_laws |= law
		if(length(bad_idea_laws))
			var/all_bad_idea_laws = english_list(bad_idea_laws)
			if(tgui_alert(usr, "Are you sure you want to state these laws? Stating some of your selected laws may be a bad idea!:\n[all_bad_idea_laws]", buttons = list("Yes", "No")) != "Yes")
				return

	if(currently_stating_laws)
		return

	currently_stating_laws = TRUE

	//"radiomod" is inserted before a hardcoded message to change if and how it is handled by an internal radio.
	say("[radiomod] Current Active Laws:", ignore_spam = TRUE, forced = "state laws")
	S.client?.silicon_spam_grace()

	for(var/law_index = 1 to length(laws_to_state))
		var/law = laws_to_state[law_index]
		addtimer(CALLBACK(src, PROC_REF(state_singular_law), S, law), 1 SECONDS * law_index)

	addtimer(CALLBACK(src, PROC_REF(finished_stating_laws), S, total_laws_count), 1 SECONDS * (length(laws_to_state) + 1))


/mob/living/silicon/proc/finished_stating_laws(mob/living/silicon/silicon, total_laws_count)
	silicon.client?.silicon_spam_grace_done(total_laws_count)
	currently_stating_laws = FALSE

/mob/living/silicon/proc/state_singular_law(mob/living/silicon/silicon, law)
	say("[radiomod] [law]", ignore_spam = TRUE, forced = "state laws")
	silicon.client?.silicon_spam_grace()

/mob/living/silicon/proc/checklaws() //Gives you a link-driven interface for deciding what laws the statelaws() proc will share with the crew. --NeoFite

	var/list = "<b>Which laws do you want to include when stating them for the crew?</b><br><br>"

	if (laws.zeroth)
		if (!lawcheck[1])
			lawcheck[1] = "No" //Given Law 0's usual nature, it defaults to NOT getting reported. --NeoFite
		list += {"<A href='byond://?src=[REF(src)];lawc=0'>[lawcheck[1]] 0:</A> <font color='#ff0000'><b>[laws.zeroth]</b></font><BR>"}

	for (var/index = 1, index <= laws.hacked.len, index++)
		var/law = laws.hacked[index]
		if (length(law) > 0)
			if (!hackedcheck[index])
				hackedcheck[index] = "No"
			list += {"<A href='byond://?src=[REF(src)];lawh=[index]'>[hackedcheck[index]] [ion_num()]:</A> <font color='#660000'>[law]</font><BR>"}
			hackedcheck.len += 1

	for (var/index = 1, index <= laws.ion.len, index++)
		var/law = laws.ion[index]

		if (length(law) > 0)
			if (!ioncheck[index])
				ioncheck[index] = "Yes"
			list += {"<A href='byond://?src=[REF(src)];lawi=[index]'>[ioncheck[index]] [ion_num()]:</A> <font color='#547DFE'>[law]</font><BR>"}
			ioncheck.len += 1

	var/number = 1
	for (var/index = 1, index <= laws.inherent.len, index++)
		var/law = laws.inherent[index]

		if (length(law) > 0)
			lawcheck.len += 1

			if (!lawcheck[number+1])
				lawcheck[number+1] = "Yes"
			list += {"<A href='byond://?src=[REF(src)];lawc=[number]'>[lawcheck[number+1]] [number]:</A> [law]<BR>"}
			number++

	for (var/index = 1, index <= laws.supplied.len, index++)
		var/law = laws.supplied[index]
		if (length(law) > 0)
			lawcheck.len += 1
			if (!lawcheck[number+1])
				lawcheck[number+1] = "Yes"
			list += {"<A href='byond://?src=[REF(src)];lawc=[number]'>[lawcheck[number+1]] [number]:</A> <font color='#990099'>[law]</font><BR>"}
			number++
	list += {"<br><br><A href='byond://?src=[REF(src)];laws=1'>State Laws</A>"}

	usr << browse(HTML_SKELETON(list), "window=laws")

/mob/living/silicon/proc/ai_roster()
	if(!client || !COOLDOWN_FINISHED(client, crew_manifest_delay))
		return
	COOLDOWN_START(client, crew_manifest_delay, 1 SECONDS)
	GLOB.crew_manifest_tgui.ui_interact(src)

/mob/living/silicon/proc/set_autosay() //For allowing the AI and borgs to set the radio behavior of auto announcements (state laws, arrivals).
	if(!radio)
		to_chat(src, "Radio not detected.")
		return

	//Ask the user to pick a channel from what it has available.
	var/Autochan = input("Select a channel:") as null|anything in list("Default","None") + radio.channels

	if(!Autochan)
		return
	if(Autochan == "Default") //Autospeak on whatever frequency to which the radio is set, usually Common.
		radiomod = ";"
		Autochan += " ([radio.get_frequency()])"
	else if(Autochan == "None") //Prevents use of the radio for automatic annoucements.
		radiomod = ""
	else	//For department channels, if any, given by the internal radio.
		for(var/key in GLOB.department_radio_keys)
			if(GLOB.department_radio_keys[key] == Autochan)
				radiomod = ":" + key
				break

	to_chat(src, span_notice("Automatic announcements [Autochan == "None" ? "will not use the radio." : "set to [Autochan]."]"))

/mob/living/silicon/put_in_hand_check() // This check is for borgs being able to receive items, not put them in others' hands.
	return 0

/mob/living/silicon/assess_threat(judgment_criteria, lasercolor = "", datum/callback/weaponcheck=null) //Secbots won't hunt silicon units
	return -10

/mob/living/silicon/proc/remove_sensors()
	var/datum/atom_hud/secsensor = GLOB.huds[sec_hud]
	var/datum/atom_hud/medsensor = GLOB.huds[med_hud]
	var/datum/atom_hud/diagsensor = GLOB.huds[d_hud]
	secsensor.remove_hud_from(src)
	medsensor.remove_hud_from(src)
	diagsensor.remove_hud_from(src)

/mob/living/silicon/proc/add_sensors()
	var/datum/atom_hud/secsensor = GLOB.huds[sec_hud]
	var/datum/atom_hud/medsensor = GLOB.huds[med_hud]
	var/datum/atom_hud/diagsensor = GLOB.huds[d_hud]
	secsensor.add_hud_to(src)
	medsensor.add_hud_to(src)
	diagsensor.add_hud_to(src)

/mob/living/silicon/proc/toggle_sensors()
	if(incapacitated())
		return
	sensors_on = !sensors_on
	if (!sensors_on)
		to_chat(src, "Sensor overlay deactivated.")
		remove_sensors()
		return
	add_sensors()
	to_chat(src, "Sensor overlay activated.")

/mob/living/silicon/update_transform()
	var/matrix/ntransform = matrix(transform) //aka transform.Copy()
	var/changed = 0
	if(resize != RESIZE_DEFAULT_SIZE)
		changed++
		ntransform.Scale(resize)
		resize = RESIZE_DEFAULT_SIZE

	if(changed)
		animate(src, transform = ntransform, time = 2,easing = EASE_IN|EASE_OUT)
	return ..()

/mob/living/silicon/is_literate()
	return TRUE

/mob/living/silicon/get_inactive_held_item()
	return FALSE

/mob/living/silicon/handle_high_gravity(gravity, delta_time, times_fired)
	return

/mob/living/silicon/rust_heretic_act()
	adjustBruteLoss(500)
	return TRUE

/mob/living/silicon/hears_radio()
	return FALSE

/mob/living/silicon/on_floored_start()
	return // Silicons are always standing by default.

/mob/living/silicon/on_floored_end()
	return // Silicons are always standing by default.

/mob/living/silicon/on_lying_down()
	return // Silicons are always standing by default.

/mob/living/silicon/on_standing_up()
	return // Silicons are always standing by default.

/**
 * Records an IC event log entry in the cyborg's internal tablet.
 *
 * Creates an entry in the borglog list of the cyborg's internal tablet (if it's a borg), listing the current
 * in-game time followed by the message given. These logs can be seen by the cyborg in their
 * BorgUI tablet app. By design, logging fails if the cyborg is dead.
 *
 * (This used to be in robot.dm. It's in here now.)
 *
 * Arguments:
 * string: a string containing the message to log.
 */
/mob/living/silicon/proc/logevent(string = "")
	if(!string)
		return
	if(stat == DEAD) //Dead silicons log no longer
		return
	if(!modularInterface)
		stack_trace("Silicon [src] ( [type] ) was somehow missing their integrated tablet. Please make a bug report.")
		create_modularInterface()
	var/mob/living/silicon/robot/robo = modularInterface.borgo
	if(istype(robo))
		modularInterface.borglog += "[station_time_timestamp()] - [string]"
	var/datum/computer_file/program/borg_self_monitor/program = modularInterface.get_self_monitoring()
	if(program)
		program.force_full_update()

/mob/living/silicon/robot/get_exp_list(minutes)
	. = ..()

	var/datum/job/cyborg/cyborg_job_ref = SSjob.GetJobType(/datum/job/cyborg)

	.[cyborg_job_ref.title] = minutes

/// Same as the normal character name replacement, but updates the contents of the modular interface.
/mob/living/silicon/fully_replace_character_name(oldname, newname)
	. = ..()
	if(!modularInterface)
		stack_trace("Silicon [src] ( [type] ) was somehow missing their integrated tablet. Please make a bug report.")
		create_modularInterface()
	modularInterface.saved_identification = newname

/mob/living/silicon/try_ducttape(mob/living/user, obj/item/stack/sticky_tape/duct/tape)
	. = FALSE

	var/robot_is_damaged = getBruteLoss()

	if (!robot_is_damaged)
		balloon_alert(user, "[src] is not damaged!")
		return

	user.visible_message(span_notice("[user] begins repairing [src] with [tape]."), span_notice("You begin repairing [src] with [tape]."))
	playsound(user, 'sound/items/duct_tape/duct_tape_rip.ogg', 50, TRUE)

	if (!do_after(user, 3 SECONDS, target = src))
		return

	to_chat(user, span_notice("You finish repairing [src] with [tape]."))
	adjustBruteLoss(-tape.object_repair_value)
	return TRUE
