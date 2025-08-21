/**
 * Blow up the mob into giblets
 *
 * Arguments:
 * * no_brain - Should the mob NOT drop a brain?
 * * no_organs - Should the mob NOT drop organs?
 * * no_bodyparts - Should the mob NOT drop bodyparts?
*/
/mob/living/proc/gib(no_brain, no_organs, no_bodyparts)
	var/prev_lying = lying_angle
	if(stat != DEAD)
		death(TRUE)

	if(!prev_lying)
		gib_animation()

	spill_organs(no_brain, no_organs, no_bodyparts)

	if(!no_bodyparts)
		spread_bodyparts(no_brain, no_organs)

	spawn_gibs(no_bodyparts)
	SEND_SIGNAL(src, COMSIG_LIVING_GIBBED, no_brain, no_organs, no_bodyparts)
	qdel(src)

/mob/living/proc/gib_animation()
	return

/mob/living/proc/spawn_gibs()
	new /obj/effect/gibspawner/generic(drop_location(), src, get_static_viruses())

/mob/living/proc/spill_organs()
	return

/mob/living/proc/spread_bodyparts()
	return

/**
 * This is the proc for turning a mob into ash.
 * Dusting robots does not eject the MMI, so it's a bit more powerful than gib()
 *
 * Arguments:
 * * just_ash - If TRUE, ash will spawn where the mob was, as opposed to remains
 * * drop_items - Should the mob drop their items before dusting?
 * * force - Should this mob be FORCABLY dusted?
*/
/mob/living/proc/dust(just_ash, drop_items, force)
	if(stat != DEAD)
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

/*
 * Called when the mob dies. Can also be called manually to kill a mob.
 *
 * Arguments:
 * * gibbed - Was the mob gibbed?
*/
/mob/living/proc/death(gibbed)
	if(stat == DEAD)
		return FALSE

	set_stat(DEAD)
	unset_machine()
	timeofdeath = world.time
	tod = station_time_timestamp()
	var/turf/death_turf = get_turf(src)
	var/area/death_area = get_area(src)
	// Display a death message if the mob is a player mob (has an active mind)
	var/player_mob_check = mind && mind.name && mind.active

	// and, display a death message if the area allows it (or if they're in nullspace)
	var/valid_area_check = !death_area || !(death_area.area_flags & NO_DEATH_MESSAGE)

	if(player_mob_check && valid_area_check)
		deadchat_broadcast(" has died at <b>[get_area_name(death_turf)]</b>.", "<b>[mind.name]</b>", follow_target = src, turf_target = death_turf, message_type=DEADCHAT_DEATHRATTLE)
		mind.store_memory("Time of death: [tod]", 0)
	if(playable)
		remove_from_spawner_menu()
	set_drugginess(0)
	set_disgust(0)
	SetSleeping(0, 0)
	reset_perspective(null)
	reload_fullscreen()
	update_action_buttons_icon()
	update_damage_hud()
	update_health_hud()
	med_hud_set_health()
	med_hud_set_status()
	stop_pulling()

	SEND_SIGNAL(src, COMSIG_LIVING_DEATH, gibbed)
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_MOB_DEATH, src, gibbed)

	if (client)
		client.move_delay = initial(client.move_delay)
		//This first death of the game will not incur a ghost role cooldown
		client.next_ghost_role_tick = client.next_ghost_role_tick || suiciding ? world.time + CONFIG_GET(number/ghost_role_cooldown) : world.time

		INVOKE_ASYNC(client, TYPE_PROC_REF(/client, give_award), /datum/award/achievement/misc/ghosts, client.mob)

	for(var/s in ownedSoullinks)
		var/datum/soullink/S = s
		S.ownerDies(gibbed)
	for(var/s in sharedSoullinks)
		var/datum/soullink/S = s
		S.sharerDies(gibbed)

	if(mind?.current)
		client?.tgui_panel?.give_dead_popup()

	return TRUE
