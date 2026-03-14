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

	ghostize()
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
	var/was_dead_before = stat == DEAD
	set_stat(DEAD)
	SEND_SIGNAL(src, COMSIG_LIVING_DEATH, gibbed, was_dead_before)
	unset_machine()
	timeofdeath = world.time
	tod = station_time_timestamp()
	var/turf/T = get_turf(src)
	if(mind)
		if(mind.name && mind.active && !istype(T.loc, /area/ctf))
			var/rendered = span_deadsay("<b>[mind.name]</b> has died at <b>[get_area_name(T)]</b>.")
			deadchat_broadcast(rendered, follow_target = src, turf_target = T, message_type=DEADCHAT_DEATHRATTLE)
		mind.store_memory("Time of death: [tod]", 0)
	remove_from_alive_mob_list()
	if(playable)
		remove_from_spawner_menu()
	if(!gibbed && !was_dead_before)
		add_to_dead_mob_list()

	SetSleeping(0, 0)

	update_action_buttons_icon()
	update_health_hud()

	med_hud_set_health()
	med_hud_set_status()


	stop_pulling()

	SEND_SIGNAL(src, COMSIG_LIVING_DEATH, gibbed)
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_MOB_DEATH, src, gibbed)

	if (client)
		reset_perspective(null)
		reload_fullscreen()
		client.move_delay = initial(client.move_delay)
		client.player_details.time_of_death = timeofdeath
		//This first death of the game will not incur a ghost role cooldown
		client.next_ghost_role_tick = client.next_ghost_role_tick || suiciding ? world.time + CONFIG_GET(number/ghost_role_cooldown) : world.time

		INVOKE_ASYNC(client, TYPE_PROC_REF(/client, give_award), /datum/award/achievement/misc/ghosts, src)

	if(mind?.current)
		client?.tgui_panel?.give_dead_popup()

	return TRUE

/mob/living/carbon/death(gibbed)
	. = ..()

	set_disgust(0)
	update_damage_hud()

	if(!gibbed && !QDELETED(src))
		addtimer(CALLBACK(src, PROC_REF(med_hud_set_status)), (DEFIB_TIME_LIMIT * 10) + 10)
