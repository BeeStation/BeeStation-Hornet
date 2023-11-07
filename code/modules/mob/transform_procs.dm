#define TRANSFORMATION_DURATION 22

/mob/living/carbon/proc/monkeyize(skip_animation = FALSE)
	if (notransform || transformation_timer)
		return

	if(ismonkey(src))
		return

	//Make mob invisible and spawn animation
	notransform = TRUE
	Paralyze(TRANSFORMATION_DURATION, ignore_canstun = TRUE)
	icon = null
	cut_overlays()
	invisibility = INVISIBILITY_MAXIMUM

	if(!skip_animation)
		new /obj/effect/temp_visual/monkeyify(loc)

		transformation_timer = addtimer(CALLBACK(src, .proc/finish_monkeyize), TRANSFORMATION_DURATION, TIMER_UNIQUE)

//Mostly same as monkey but turns target into teratoma

/mob/living/carbon/proc/teratomize()
	if (notransform || transformation_timer)
		return

	//Make mob invisible and spawn animation
	notransform = TRUE
	Paralyze(TRANSFORMATION_DURATION, ignore_canstun = TRUE)
	icon = null
	cut_overlays()
	invisibility = INVISIBILITY_MAXIMUM

	new /obj/effect/temp_visual/monkeyify(loc)

	transformation_timer = addtimer(CALLBACK(src, PROC_REF(finish_teratomize)), TRANSFORMATION_DURATION, TIMER_UNIQUE)

/mob/living/carbon/proc/finish_monkeyize()
	transformation_timer = null
	to_chat(src, "<B>You are now a monkey.</B>")
	notransform = FALSE
	icon = initial(icon)
	invisibility = 0
	set_species(/datum/species/monkey)
	SEND_SIGNAL(src, COMSIG_HUMAN_MONKEYIZE)
	uncuff()
	return src

/mob/living/carbon/proc/finish_teratomize()
	transformation_timer = null
	to_chat(src, "<B>You are now a teratoma.</B>")
	notransform = FALSE
	icon = initial(icon)
	invisibility = 0
	set_species(/datum/species/teratoma)
	uncuff()
	return src

//////////////////////////           Humanize               //////////////////////////////
//Could probably be merged with monkeyize but other transformations got their own procs, too

/mob/living/carbon/proc/humanize()
	if (notransform || transformation_timer)
		return

	if(!ismonkey(src))
		return

	//Make mob invisible and spawn animation
	notransform = TRUE
	Paralyze(TRANSFORMATION_DURATION, ignore_canstun = TRUE)
	icon = null
	cut_overlays()
	invisibility = INVISIBILITY_MAXIMUM

	new /obj/effect/temp_visual/monkeyify/humanify(loc)
	transformation_timer = addtimer(CALLBACK(src, .proc/finish_humanize), TRANSFORMATION_DURATION, TIMER_UNIQUE)

/mob/living/carbon/proc/finish_humanize()
	transformation_timer = null
	to_chat(src, "<B>You are now a human.</B>")
	notransform = FALSE
	icon = initial(icon)
	invisibility = 0
	set_species(/datum/species/human)
	SEND_SIGNAL(src, COMSIG_MONKEY_HUMANIZE)
	return src

//A common proc to start an -ize transformation
/mob/living/carbon/proc/pre_transform(delete_items = FALSE)
	if(notransform)
		return TRUE
	notransform = TRUE
	Paralyze(1, ignore_canstun = TRUE)

	if(delete_items)
		for(var/obj/item/W in get_equipped_items(TRUE) | held_items)
			qdel(W)
	else
		unequip_everything()
	regenerate_icons()
	icon = null
	invisibility = INVISIBILITY_MAXIMUM
	for(var/t in bodyparts)
		qdel(t)

/mob/living/carbon/AIize(transfer_after = TRUE, client/preference_source)
	return pre_transform() ? null : ..()

/mob/proc/AIize(transfer_after = TRUE, client/preference_source)
	var/list/turf/landmark_loc = list()
	for(var/obj/effect/landmark/start/ai/sloc in GLOB.landmarks_list)
		if(locate(/mob/living/silicon/ai) in sloc.loc)
			continue
		if(sloc.primary_ai)
			LAZYCLEARLIST(landmark_loc)
			landmark_loc += sloc.loc
			break
		landmark_loc += sloc.loc
	if(!landmark_loc.len)
		to_chat(src, "Oh god sorry we can't find an unoccupied AI spawn location, so we're spawning you on top of someone.")
		for(var/obj/effect/landmark/start/ai/sloc in GLOB.landmarks_list)
			landmark_loc += sloc.loc

	if(!landmark_loc.len)
		message_admins("Could not find ai landmark for [src]. Yell at a mapper! We are spawning them at their current location.")
		landmark_loc += loc

	if(client)
		stop_sound_channel(CHANNEL_LOBBYMUSIC)

	if(!transfer_after)
		mind.active = FALSE

	. = new /mob/living/silicon/ai(pick(landmark_loc), null, src)

	if(preference_source)
		apply_pref_name(/datum/preference/name/ai, preference_source)

	qdel(src)

/mob/living/carbon/human/proc/Robotize(delete_items = 0, transfer_after = TRUE)
	if(pre_transform(delete_items))
		return

	var/mob/living/silicon/robot/R = new /mob/living/silicon/robot(loc)

	R.job = JOB_NAME_CYBORG
	R.gender = gender
	R.invisibility = 0

	if(client)
		R.updatename(client)

	if(mind)//TODO //huh?
		if(!transfer_after)
			mind.active = FALSE
		mind.transfer_to(R)
	else if(transfer_after)
		R.key = key

	if(R.mmi)
		R.mmi.transfer_identity(src)

	R.notify_ai(NEW_BORG)

	. = R
	if(R.ckey && is_banned_from(R.ckey, JOB_NAME_CYBORG))
		INVOKE_ASYNC(R, TYPE_PROC_REF(/mob/living/silicon/robot, replace_banned_cyborg))
	qdel(src)

/mob/living/silicon/robot/proc/replace_banned_cyborg()
	to_chat(src, "<span class='userdanger'>You are job banned from cyborg! Appeal your job ban if you want to avoid this in the future!</span>")
	ghostize(FALSE)

	var/list/mob/dead/observer/candidates = pollCandidatesForMob("Do you want to play as [src]?", JOB_NAME_CYBORG, null, 7.5 SECONDS, src, ignore_category = FALSE)
	if(LAZYLEN(candidates))
		var/mob/dead/observer/chosen_candidate = pick(candidates)
		message_admins("[key_name_admin(chosen_candidate)] has taken control of ([key_name_admin(src)]) to replace a jobbanned player.")
		key = chosen_candidate.key
	else
		set_playable(JOB_NAME_CYBORG)

//human -> alien
/mob/living/carbon/human/proc/Alienize()
	if(pre_transform())
		return

	var/alien_caste = pick("Hunter","Sentinel","Drone")
	var/mob/living/carbon/alien/humanoid/new_xeno
	switch(alien_caste)
		if("Hunter")
			new_xeno = new /mob/living/carbon/alien/humanoid/hunter(loc)
		if("Sentinel")
			new_xeno = new /mob/living/carbon/alien/humanoid/sentinel(loc)
		if("Drone")
			new_xeno = new /mob/living/carbon/alien/humanoid/drone(loc)

	new_xeno.a_intent = INTENT_HARM
	new_xeno.key = key

	to_chat(new_xeno, "<B>You are now an alien.</B>")
	. = new_xeno
	qdel(src)

/mob/living/carbon/human/proc/slimeize(reproduce as num)
	if(pre_transform())
		return

	var/mob/living/simple_animal/slime/new_slime
	if(reproduce)
		var/number = pick(14;2,3,4)	//reproduce (has a small chance of producing 3 or 4 offspring)
		var/list/babies = list()
		for(var/i in 1 to number)
			var/mob/living/simple_animal/slime/M = new/mob/living/simple_animal/slime(loc)
			M.set_nutrition(round(nutrition/number))
			step_away(M,src)
			babies += M
		new_slime = pick(babies)
	else
		new_slime = new /mob/living/simple_animal/slime(loc)
	new_slime.a_intent = INTENT_HARM
	new_slime.key = key

	to_chat(new_slime, "<B>You are now a slime. Skreee!</B>")
	. = new_slime
	qdel(src)

/mob/proc/become_overmind(starting_points = 60)
	var/mob/camera/blob/B = new /mob/camera/blob(get_turf(src), starting_points)
	B.key = key
	. = B
	qdel(src)


/mob/living/carbon/proc/corgize()
	if(pre_transform())
		return

	var/mob/living/simple_animal/pet/dog/corgi/new_corgi = new /mob/living/simple_animal/pet/dog/corgi (loc)
	new_corgi.a_intent = INTENT_HARM
	new_corgi.key = key

	to_chat(new_corgi, "<B>You are now a Corgi. Yap Yap!</B>")
	. = new_corgi
	qdel(src)

/mob/living/carbon/proc/gorillize()
	if(pre_transform())
		return
	var/mob/living/simple_animal/hostile/gorilla/new_gorilla = new (get_turf(src))
	new_gorilla.a_intent = INTENT_HARM
	if(mind)
		mind.transfer_to(new_gorilla)
	else
		new_gorilla.key = key
	to_chat(new_gorilla, "<B>You are now a gorilla. Ooga ooga!</B>")
	. = new_gorilla
	qdel(src)

/mob/living/carbon/proc/junglegorillize()
	if(pre_transform())
		return
	var/mob/living/simple_animal/hostile/gorilla/rabid/new_gorilla = new (get_turf(src))
	new_gorilla.a_intent = INTENT_HARM
	var/datum/atom_hud/H = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED]
	H.add_hud_to(new_gorilla)
	if(mind)
		mind.transfer_to(new_gorilla)
	else
		new_gorilla.key = key
	to_chat(new_gorilla, "<B>You are now a gorilla. Ooga ooga!</B>")
	. = new_gorilla
	qdel(src)

/mob/living/carbon/human/Animalize()

	var/list/mobtypes = typesof(/mob/living/simple_animal)
	var/mobpath = tgui_input_list(usr, "Which type of mob should [src] turn into?", "Choose a type", sort_list(mobtypes, GLOBAL_PROC_REF(cmp_typepaths_asc)))
	if(isnull(mobpath))
		return
	if(!mobpath)
		to_chat(usr, "<span class='danger'>Sorry but this mob type is currently unavailable.</span>")
		return

	if(pre_transform())
		return

	var/mob/new_mob = new mobpath(src.loc)

	new_mob.key = key
	new_mob.a_intent = INTENT_HARM

	to_chat(new_mob, "You suddenly feel more... animalistic.")
	. = new_mob
	qdel(src)

/mob/proc/Animalize()

	var/list/mobtypes = typesof(/mob/living/simple_animal)
	var/mobpath = tgui_input_list(usr, "Which type of mob should [src] turn into?", "Choose a type", sort_list(mobtypes, GLOBAL_PROC_REF(cmp_typepaths_asc)))
	if(isnull(mobpath))
		return
	if(!mobpath)
		to_chat(usr, "<span class='danger'>Sorry but this mob type is currently unavailable.</span>")
		return

	var/mob/new_mob = new mobpath(src.loc)

	new_mob.key = key
	new_mob.a_intent = INTENT_HARM
	to_chat(new_mob, "<span class='boldnotice'>You feel more... animalistic!</span>")

	. = new_mob
	qdel(src)

#undef TRANSFORMATION_DURATION
