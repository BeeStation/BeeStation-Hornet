/datum/holoparasite_ability/major/spatial
	name = "Spatial Rending"
	desc = "The holoparasite can compress space itself between it and a target, bring almost everything on a desired tile to the space right in front of it."
	ui_icon = "compress"
	cost = 3
	thresholds = list(
		list(
			"stat" = "Potential",
			"desc" = "Reduces the cooldown of the spatial rending pull ability."
		)
	)
	/// How long the cooldown lasts, affected by potential.
	var/cooldown_length = 0
	/// When the hand ability can be used again.
	COOLDOWN_DECLARE(spatial_rending_cooldown)

/datum/holoparasite_ability/major/spatial/apply()
	..()
	cooldown_length = (10 / master_stats.potential) * 10

/datum/holoparasite_ability/major/spatial/register_signals()
	..()
	RegisterSignal(owner, COMSIG_MOB_ATTACK_RANGED, PROC_REF(on_ranged_attack))
	RegisterSignal(owner, COMSIG_HOLOPARA_STAT, PROC_REF(on_stat))

/datum/holoparasite_ability/major/spatial/unregister_signals()
	..()
	UnregisterSignal(owner, list(COMSIG_MOB_ATTACK_RANGED, COMSIG_HOLOPARA_STAT))

/datum/holoparasite_ability/major/spatial/proc/on_ranged_attack(datum/_source, atom/target)
	SIGNAL_HANDLER
	ASSERT_ABILITY_USABILITY
	if(!COOLDOWN_FINISHED(src, spatial_rending_cooldown) || owner.Adjacent(target) || !isturf(owner.loc))
		return
	if(!in_view_range(owner, target))
		to_chat(owner, span_warning("You cannot pull something so far away!"))
		return
	var/turf/hand_turf = get_step(owner, get_dir(owner, target))
	var/things_pulled = 0
	var/turf/target_turf = get_turf(target)
	var/pull_dist = get_dist(hand_turf, target_turf)
	for(var/atom/movable/thing_to_pull in target_turf)
		// Don't pull anchored objects, or non-living mobs.
		if(thing_to_pull.anchored || (ismob(thing_to_pull) && !isliving(thing_to_pull)))
			continue
		// It's warping space itself, no bluespace anchor can stop it.
		do_teleport(thing_to_pull, hand_turf, precision = 0, no_effects = TRUE, channel = TELEPORT_CHANNEL_FREE)
		if(isliving(thing_to_pull))
			thing_to_pull.log_message("was pulled [pull_dist] tiles (from [AREACOORD(hand_turf)] to [AREACOORD(target_turf)]) by spatial rending from [key_name(owner)]", LOG_ATTACK)
			owner.log_message("pulled [key_name(thing_to_pull)] [pull_dist] tiles (from [AREACOORD(hand_turf)] to [AREACOORD(target_turf)]) with spatial rending", LOG_ATTACK, log_globally = FALSE)
		things_pulled++
	owner.face_atom(hand_turf)
	if(things_pulled)
		playsound(owner, 'sound/effects/spatialpull.ogg', vol = 80, vary = TRUE) // blink lol
		var/datum/beam/beam = target_turf.Beam(hand_turf, "bsa_beam_greyscale", time = 1.5 SECONDS)
		for(var/obj/effect/ebeam/beam_part in beam.elements)
			beam_part.add_atom_colour(owner.accent_color, FIXED_COLOUR_PRIORITY)
		owner.visible_message(span_danger("[owner.color_name] compresses space, bringing the objects on [target_turf] directly to it!"))
		owner.balloon_alert(owner, "pulled [things_pulled] things", show_in_chat = FALSE)
		COOLDOWN_START(src, spatial_rending_cooldown, cooldown_length)
		SSblackbox.record_feedback("amount", "holoparasite_spatial_things_pulled", things_pulled)

/**
 * Adds hand cooldown info to the holoparasite's stat panel.
 */
/datum/holoparasite_ability/major/spatial/proc/on_stat(datum/_source, list/tab_data)
	SIGNAL_HANDLER
	if(!COOLDOWN_FINISHED(src, spatial_rending_cooldown))
		tab_data["Spatial Rend Cooldown Remaining"] = GENERATE_STAT_TEXT(COOLDOWN_TIMELEFT_TEXT(src, spatial_rending_cooldown))
