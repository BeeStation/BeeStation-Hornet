#define GOHOME_START 0
#define GOHOME_FLICKER_ONE 2
#define GOHOME_FLICKER_TWO 4
#define GOHOME_TELEPORT 6

/**
 * Given to Vampires near Sol if they have a Coffin claimed.
 * Teleports them to their Coffin after a delay.
 * Makes them drop everything if someone witnesses the act.
 */
/datum/action/vampire/gohome
	name = "Vanishing Act"
	desc = "As dawn aproaches, disperse into mist and return directly to your Lair.<br><b>WARNING:</b> You will drop <b>ALL</b> of your possessions if observed by mortals."
	button_icon_state = "power_gohome"
	power_explanation = "Activating Vanishing Act will, after a short delay, teleport you to your Claimed Coffin.\n\
		Immediately after activating, lights around the user will begin to flicker.\n\
		Once the user teleports to their coffin, in their place will be a Rat or Bat."
	power_flags = BP_AM_TOGGLE | BP_AM_SINGLEUSE | BP_AM_STATIC_COOLDOWN
	check_flags = BP_CANT_USE_IN_FRENZY | BP_CANT_USE_WHILE_STAKED
	purchase_flags = NONE
	bloodcost = 100
	cooldown_time = 100 SECONDS
	///What stage of the teleportation are we in
	var/teleporting_stage = GOHOME_START
	/// The types of mobs that will drop post-teleportation.
	var/static/list/spawning_mobs = list(
		/mob/living/basic/mouse = 3,
		/mob/living/simple_animal/hostile/retaliate/bat = 1,
	)

/datum/action/vampire/gohome/can_use()
	. = ..()
	if(!.)
		return FALSE

	/// Have No Lair (NOTE: You only got this power if you had a lair, so this means it's destroyed)
	if(!vampiredatum_power?.coffin)
		owner.balloon_alert(owner, "coffin was destroyed!")
		return FALSE

/datum/action/vampire/gohome/activate_power()
	. = ..()
	owner.balloon_alert(owner, "preparing to teleport...")
	if(do_after(owner, GOHOME_TELEPORT SECONDS, timed_action_flags=(IGNORE_USER_LOC_CHANGE | IGNORE_INCAPACITATED | IGNORE_HELD_ITEM)))
		teleport_to_coffin(owner)

/datum/action/vampire/gohome/UsePower()
	. = ..()
	if(!.)
		return FALSE

	switch(teleporting_stage)
		if(GOHOME_START)
			INVOKE_ASYNC(src, PROC_REF(flicker_lights), 3, 20)
		if(GOHOME_FLICKER_ONE)
			INVOKE_ASYNC(src, PROC_REF(flicker_lights), 4, 40)
		if(GOHOME_FLICKER_TWO)
			INVOKE_ASYNC(src, PROC_REF(flicker_lights), 4, 60)
	teleporting_stage++

/datum/action/vampire/gohome/continue_active()
	. = ..()
	if(!.)
		return FALSE

	if(!isturf(owner.loc))
		return FALSE
	if(!vampiredatum_power.coffin)
		owner.balloon_alert(owner, "coffin destroyed!")
		to_chat(owner, span_warning("Your coffin has been destroyed! You no longer have a destination."))
		return FALSE
	return TRUE

/datum/action/vampire/gohome/proc/flicker_lights(flicker_range, beat_volume)
	for(var/obj/machinery/light/nearby_lights in view(flicker_range, get_turf(owner)))
		nearby_lights.flicker(5)
	playsound(get_turf(owner), 'sound/effects/singlebeat.ogg', beat_volume, 1)

/datum/action/vampire/gohome/proc/teleport_to_coffin(mob/living/carbon/user)
	var/turf/current_turf = get_turf(owner)
	// If we aren't in the dark, anyone watching us will cause us to drop out stuff
	if(!QDELETED(current_turf?.lighting_object) && current_turf.get_lumcount() >= 0.2)
		for(var/mob/living/watcher in viewers(world.view, get_turf(owner)) - owner)
			if(QDELETED(watcher.client) || watcher.client?.is_afk() || watcher.stat != CONSCIOUS)
				continue
			if(watcher.has_unlimited_silicon_privilege)
				continue
			if(watcher.is_blind())
				continue
			if(!IS_VAMPIRE(watcher) && !IS_VASSAL(watcher))
				for(var/obj/item/item in owner)
					owner.dropItemToGround(item, TRUE)
				break
	user.uncuff()

	playsound(current_turf, 'sound/magic/summon_karp.ogg', 60, 1)

	var/datum/effect_system/steam_spread/vampire/puff = new /datum/effect_system/steam_spread/vampire()
	puff.set_up(3, 0, current_turf)
	puff.start()

	/// STEP FIVE: Create animal at prev location
	var/mob/living/simple_animal/new_mob = pick_weight(spawning_mobs)
	new new_mob(current_turf)
	/// TELEPORT: Move to Coffin & Close it!
	user.set_resting(TRUE, TRUE, FALSE)
	do_teleport(owner, vampiredatum_power.coffin, channel = TELEPORT_CHANNEL_MAGIC, no_effects = TRUE)
	vampiredatum_power.coffin.close(owner)
	vampiredatum_power.coffin.take_contents()
	playsound(vampiredatum_power.coffin.loc, vampiredatum_power.coffin.close_sound, 15, 1, -3)

	deactivate_power()

/datum/effect_system/steam_spread/vampire
	effect_type = /obj/effect/particle_effect/smoke/vampsmoke

#undef GOHOME_START
#undef GOHOME_FLICKER_ONE
#undef GOHOME_FLICKER_TWO
#undef GOHOME_TELEPORT
