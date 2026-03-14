GLOBAL_VAR(posibrain_notify_cooldown)

/obj/item/mmi/posibrain
	name = "positronic brain"
	desc = "A cube of shining metal, four inches to a side and covered in shallow grooves."
	icon = 'icons/obj/assemblies.dmi'
	icon_state = "posibrain"
	w_class = WEIGHT_CLASS_NORMAL
	req_access = list(ACCESS_ROBOTICS)
	braintype = "Android"

	///Message sent to the user when polling ghosts
	var/begin_activation_message = span_notice("You carefully locate the manual activation switch and start the positronic brain's boot process.")
	///Message sent as a visible message on success
	var/success_message = span_notice("The positronic brain pings, and its lights start flashing. Success!")
	///Message sent as a visible message on failure
	var/fail_message = span_notice("The positronic brain buzzes quietly, and the golden lights fade away. Perhaps you could try again?")
	///Visible message sent when a player possesses the brain
	var/new_mob_message = span_notice("The positronic brain chimes quietly.")
	///Examine message when the posibrain has no mob
	var/dead_message = span_deadsay("It appears to be completely inactive. The reset light is blinking.")
	///Examine message when the posibrain cannot poll ghosts due to cooldown
	var/recharge_message = span_warning("The positronic brain isn't ready to activate again yet! Give it some time to recharge.")

	///Can be set to tell ghosts what the brain will be used for
	var/ask_role = ""
	var/new_role
	///World time tick when ghost polling will be available again
	var/next_ask
	///Delay after polling ghosts
	var/ask_delay = 60 SECONDS

	/// This should be set by policy
	var/welcome_message = span_warning("ALL PAST LIVES ARE FORGOTTEN.") + "\n<b>You are a positronic brain, brought into existence aboard Space Station 13.\n\
	As a synthetic intelligence, you answer to all crewmembers and the AI.\n\
	Remember, the purpose of your existence is to serve the crew and the station. Above all else, do no harm to crewmembers and the AI.</b>"

	///One of these names is randomly picked as the posibrain's name on possession. If left blank, it will use the global posibrain names
	var/list/possible_names
	///Picked posibrain name
	var/picked_name
	///Whether this positronic brain is currently looking for a ghost to enter it.
	var/searching = FALSE
	///List of all ckeys who has already entered this posibrain once before.
	var/list/ckeys_entered = list()

/obj/item/mmi/posibrain/proc/ping_ghosts(msg, newlymade)
	if(newlymade || GLOB.posibrain_notify_cooldown <= world.time)
		notify_ghosts(
			"[name] [msg] in [get_area(src)]! [ask_role ? "Personality requested: \[[ask_role]\]" : ""]",
			source = src,
			header = "Ghost in the Machine",
			click_interact = TRUE,
			ghost_sound = !newlymade ? 'sound/effects/ghost2.ogg':null,
			ignore_key = POLL_IGNORE_POSIBRAIN,
			notify_flags = (GHOST_NOTIFY_IGNORE_MAPLOAD),
			notify_volume = 75,
		)
		if(!newlymade)
			GLOB.posibrain_notify_cooldown = world.time + ask_delay

/obj/item/mmi/posibrain/attack_self(mob/user)
	if(!brainmob)
		set_brainmob(new /mob/living/brain(src))
	if(!(GLOB.ghost_role_flags & GHOSTROLE_SILICONS))
		to_chat(user, span_warning("Central Command has temporarily outlawed posibrain sentience in this sector..."))
		return
	if(is_occupied())
		to_chat(user, span_warning("This [name] is already active!"))
		return
	if(next_ask > world.time)
		to_chat(user, recharge_message)
		return
	//Start the process of requesting a new ghost.
	to_chat(user, begin_activation_message)
	ping_ghosts("requested", FALSE)
	next_ask = world.time + ask_delay
	searching = TRUE
	update_icon()
	addtimer(CALLBACK(src, PROC_REF(check_success)), ask_delay)

/obj/item/mmi/posibrain/AltClick(mob/living/user)
	if(!istype(user) || !user.canUseTopic(src, BE_CLOSE))
		return
	var/input_seed = stripped_input(user, "Enter a personality seed", "Enter seed", ask_role, MAX_NAME_LEN)
	if(!istype(user) || !user.canUseTopic(src, BE_CLOSE))
		return
	if(input_seed)
		to_chat(user, "<span class='notice'>You set the personality seed to \"[input_seed]\".</span>")
		ask_role = input_seed
		update_icon()

/obj/item/mmi/posibrain/proc/check_success()
	searching = FALSE
	update_icon()
	if(QDELETED(brainmob))
		return
	if(brainmob.client)
		visible_message(success_message)
		playsound(src, 'sound/machines/ping.ogg', 15, TRUE)
	else
		visible_message(fail_message)

//ATTACK GHOST IGNORING PARENT RETURN VALUE
/obj/item/mmi/posibrain/attack_ghost(mob/user)
	activate(user)

/obj/item/mmi/posibrain/proc/is_occupied()
	if(brainmob.key)
		return TRUE
	if(iscyborg(loc))
		var/mob/living/silicon/robot/R = loc
		if(R.mmi == src)
			return TRUE
	return FALSE

//Two ways to activate a positronic brain. A clickable link in the ghost notif, or simply clicking the object itself.
/obj/item/mmi/posibrain/proc/activate(mob/user)
	if(QDELETED(brainmob))
		return FALSE
	if(user.ckey in ckeys_entered)
		to_chat(user, span_warning("You cannot re-enter [src] a second time!"))
		return FALSE
	if(is_banned_from(user.ckey, ROLE_POSIBRAIN))
		to_chat(user, span_warning("You are restricted from taking positronic brain spawns at this time."))
		return FALSE
	if(user.client.get_exp_living(TRUE) <= MINUTES_REQUIRED_BASIC)
		to_chat(user, span_warning("You aren't allowed to take positronic brain spawns yet."))
		return FALSE
	if(is_occupied() || QDELETED(brainmob) || QDELETED(src) || QDELETED(user))
		return FALSE
	if(!(GLOB.ghost_role_flags & GHOSTROLE_SILICONS))
		to_chat(user, span_warning("Central Command has temporarily outlawed posibrain sentience in this sector..."))
		return FALSE
	if(user.suiciding) //if they suicided, they're out forever.
		to_chat(user, span_warning("[src] fizzles slightly. Sadly it doesn't take those who suicided!"))
		return FALSE
	var/posi_ask = tgui_alert(user, "Become a [name]? (Warning, You can no longer be revived, and all past lives will be forgotten!)", "Confirm", list("Yes","No"))
	if(posi_ask != "Yes" || QDELETED(src))
		return FALSE
	if(brainmob.suiciding) //clear suicide status if the old occupant suicided.
		brainmob.set_suicide(FALSE)
	transfer_personality(user)

	var/datum/job/posibrain/pj = SSjob.GetJob(JOB_NAME_POSIBRAIN)
	pj.remove_posi_slot(src)

	return TRUE

/obj/item/mmi/posibrain/transfer_identity(mob/living/carbon/transferred_user)
	name = "[initial(name)] ([transferred_user])"
	brainmob.name = transferred_user.real_name
	brainmob.real_name = transferred_user.real_name
	if(transferred_user.has_dna())
		if(!brainmob.stored_dna)
			brainmob.stored_dna = new /datum/dna/stored(brainmob)
		transferred_user.dna.copy_dna(brainmob.stored_dna)
	brainmob.timeofdeath = transferred_user.timeofdeath
	brainmob.set_stat(CONSCIOUS)
	if(brainmob.mind)
		brainmob.mind.assigned_role = new_role
	if(transferred_user.mind)
		transferred_user.mind.transfer_to(brainmob)

	brainmob.mind.remove_all_antag_datums()
	brainmob.mind.wipe_memory()
	investigate_flags = ADMIN_INVESTIGATE_TARGET
	update_icon()

/obj/item/mmi/posibrain/proc/transfer_personality(mob/candidate)
	if(QDELETED(brainmob))
		return
	if(is_occupied()) //Prevents hostile takeover if two ghosts get the prompt or link for the same brain.
		to_chat(candidate, span_warning("This [name] was taken over before you could get to it! Perhaps it might be available later?"))
		return FALSE
	if(candidate.mind && !isobserver(candidate))
		candidate.mind.transfer_to(brainmob)
	else
		brainmob.ckey = candidate.ckey
	name = "[initial(name)] ([brainmob.name])"
	to_chat(brainmob, welcome_message)
	brainmob.mind.assigned_role = new_role
	brainmob.set_stat(CONSCIOUS)
	brainmob.remove_from_dead_mob_list()
	brainmob.add_to_alive_mob_list()

	visible_message(new_mob_message)
	check_success()
	ckeys_entered |= brainmob.ckey
	investigate_flags = ADMIN_INVESTIGATE_TARGET
	return TRUE


/obj/item/mmi/posibrain/examine(mob/user)
	. = ..()
	if(brainmob?.key)
		switch(brainmob.stat)
			if(CONSCIOUS)
				if(!brainmob.client)
					. += "It appears to be in stand-by mode." //afk
			if(DEAD)
				. += span_deadsay("It appears to be completely inactive.")
	else
		. += "[dead_message]"
		if(ask_role)
			. += span_notice("Current consciousness seed: \"[ask_role]\"")
		. += span_boldnotice("Alt-click to set a consciousness seed, specifying what [src] will be used for. This can help generate a personality interested in that role.")

/obj/item/mmi/posibrain/Initialize(mapload, autoping = TRUE)
	. = ..()
	set_brainmob(new /mob/living/brain(src))
	var/new_name
	if(!LAZYLEN(possible_names))
		new_name = pick(GLOB.posibrain_names)
	else
		new_name = pick(possible_names)
	brainmob.name = "[new_name]-[rand(100, 999)]"
	brainmob.real_name = brainmob.name
	brainmob.forceMove(src)
	brainmob.container = src

	//If we are on the station level, add it to the list of available posibrains.
	var/datum/job/posibrain/pj = SSjob.GetJob(JOB_NAME_POSIBRAIN)
	pj.check_add_posi_slot(src)

	if(autoping)
		ping_ghosts("created", TRUE)

/obj/item/mmi/posibrain/update_icon()
	if(searching)
		icon_state = "[initial(icon_state)]-searching"
		return
	if(brainmob?.key)
		icon_state = "[initial(icon_state)]-occupied"
	else
		icon_state = initial(icon_state)

//This Proc triggers when the Z level changes. If the Posi enters the station level, add it to the Job list.
//If it leaves, remove it.
/obj/item/mmi/posibrain/onTransitZ(old_z, new_z)
	. = ..()

	if(is_station_level(old_z) == is_station_level(new_z))
		//Early Return if we aren't entering or leaving station Z level.
		return

	if(is_occupied())
		//No need to track occupied Posis
		return

	var/datum/job/posibrain/pj = SSjob.GetJob(JOB_NAME_POSIBRAIN)

	//Posi was on station, now is not on station
	if(is_station_level(new_z))
		pj.check_add_posi_slot(src)
	else
		pj.remove_posi_slot(src)

/obj/item/mmi/posibrain/Destroy()
	if(is_occupied())
		//No need to track occupied Posis
		return ..()

	var/datum/job/posibrain/pj = SSjob.GetJob(JOB_NAME_POSIBRAIN)
	pj.remove_posi_slot(src)
	return ..()

/obj/item/mmi/posibrain/attackby(obj/item/O, mob/user, params)
	return

/obj/item/mmi/posibrain/add_mmi_overlay()
	return
