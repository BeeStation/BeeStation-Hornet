/mob/living/gib(no_brain, no_organs, no_bodyparts)
	var/prev_lying = lying
	if(stat != DEAD)
		death(TRUE)

	if(!prev_lying)
		gib_animation()

	spill_organs(no_brain, no_organs, no_bodyparts)

	if(!no_bodyparts)
		spread_bodyparts(no_brain, no_organs)

	spawn_gibs(no_bodyparts)
	qdel(src)

/mob/living/proc/gib_animation()
	return

/mob/living/proc/spawn_gibs()
	new /obj/effect/gibspawner/generic(drop_location(), src, get_static_viruses())

/mob/living/proc/spill_organs()
	return

/mob/living/proc/spread_bodyparts()
	return

/mob/living/dust(just_ash, drop_items, force)
	death(TRUE)

	if(drop_items)
		unequip_everything()

	if(buckled)
		buckled.unbuckle_mob(src, force = TRUE)

	dust_animation()
	spawn_dust(just_ash)
	QDEL_IN(src,5) // since this is sometimes called in the middle of movement, allow half a second for movement to finish, ghosting to happen and animation to play. Looks much nicer and doesn't cause multiple runtimes.

/mob/living/proc/dust_animation()
	return

/mob/living/proc/spawn_dust(just_ash = FALSE)
	new /obj/effect/decal/cleanable/ash(loc)


/mob/living/death(gibbed)
	var/was_dead_before = stat == DEAD
	stat = DEAD
	unset_machine()
	timeofdeath = world.time
	tod = station_time_timestamp()
	var/turf/T = get_turf(src)
	for(var/obj/item/I in contents)
		I.on_mob_death(src, gibbed)
	for(var/datum/disease/advance/D in diseases)
		for(var/symptom in D.symptoms)
			var/datum/symptom/S = symptom
			S.OnDeath(D)
	if(mind)
		if(mind.name && mind.active && !istype(T.loc, /area/ctf))
			var/rendered = "<span class='deadsay'><b>[mind.name]</b> has died at <b>[get_area_name(T)]</b>.</span>"
			deadchat_broadcast(rendered, follow_target = src, turf_target = T, message_type=DEADCHAT_DEATHRATTLE)
		mind.store_memory("Time of death: [tod]", 0)
	GLOB.alive_mob_list -= src
	if(!gibbed && !was_dead_before)
		GLOB.dead_mob_list += src

	SetSleeping(0, 0)
	blind_eyes(1)

	update_action_buttons_icon()
	update_health_hud()
	update_mobility()

	med_hud_set_health()
	med_hud_set_status()


	stop_pulling()

	. = ..()

	if (client)
		reset_perspective(null)
		reload_fullscreen()
		client.move_delay = initial(client.move_delay)
		//This first death of the game will not incur a ghost role cooldown
		client.next_ghost_role_tick = client.next_ghost_role_tick || suiciding ? world.time + CONFIG_GET(number/ghost_role_cooldown) : world.time

		SSmedals.UnlockMedal(MEDAL_GHOSTS,client)

	for(var/s in ownedSoullinks)
		var/datum/soullink/S = s
		S.ownerDies(gibbed)
	for(var/s in sharedSoullinks)
		var/datum/soullink/S = s
		S.sharerDies(gibbed)

	return TRUE

/mob/living/carbon/death(gibbed)
	. = ..()

	set_drugginess(0)
	set_disgust(0)
	update_damage_hud()

	if(!gibbed && !QDELETED(src))
		addtimer(CALLBACK(src, .proc/med_hud_set_status), (DEFIB_TIME_LIMIT * 10) + 10)

