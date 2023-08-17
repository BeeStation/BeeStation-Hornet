/mob/living/simple_animal/hostile/holoparasite
	/// Cooldown for when the holoparasite can manifest/recall again.
	COOLDOWN_DECLARE(manifest_cooldown)

/**
 * Manifests the holoparasite from its summoner.
 */
/mob/living/simple_animal/hostile/holoparasite/proc/manifest(forced = FALSE)
	if(parent_holder.locked)
		balloon_alert(src, "locked", show_in_chat = FALSE)
		to_chat(src, "<span class='warning holoparasite'>Your summoner has <b>locked</b> you, preventing you from manifesting!</span>")
		return FALSE
	if(is_summoner_dead() || !can_be_manifested() || (!forced && !COOLDOWN_FINISHED(src, manifest_cooldown)))
		return FALSE
	if(SEND_SIGNAL(src, COMSIG_HOLOPARA_MANIFEST, forced) & COMPONENT_OVERRIDE_HOLOPARA_MANIFEST)
		return TRUE
	if(!is_manifested())
		attached_to_summoner = TRUE
		update_summoner_attachment()
		new /obj/effect/temp_visual/holoparasite/phase(loc)
		reset_perspective()
		setup_barriers()
		if(emissive)
			set_light_on(TRUE)
		if(range != 1)
			tracking_beacon.toggle_visibility(TRUE)
			tracking_beacon.add_to_huds()
		parent_holder.reset_monitor_hud()
		COOLDOWN_START(src, manifest_cooldown, HOLOPARASITE_MANIFEST_COOLDOWN)
		if(hud_used)
			var/atom/movable/screen/holoparasite/manifest_recall/mr_hud = locate() in hud_used.static_inventory
			mr_hud?.begin_timer(HOLOPARASITE_MANIFEST_COOLDOWN)
		SEND_SIGNAL(src, COMSIG_HOLOPARA_POST_MANIFEST, forced)
		return TRUE
	return FALSE

/**
 * Recalls the holoparasite back to its summoner.
 */
/mob/living/simple_animal/hostile/holoparasite/proc/recall(forced = FALSE)
	. = TRUE
	if(is_summoner_dead())
		nullspace()
		return FALSE
	if(!is_manifested())
		return FALSE
	if(!forced && !COOLDOWN_FINISHED(src, manifest_cooldown))
		return FALSE
	SEND_SIGNAL(src, COMSIG_HOLOPARA_PRE_RECALL, forced)
	tracking_beacon.toggle_visibility(FALSE)
	tracking_beacon.remove_from_huds()
	new /obj/effect/temp_visual/holoparasite/phase/out(loc)
	forceMove(summoner.current)
	pixel_x = initial(pixel_x)
	pixel_y = initial(pixel_y)
	layer = initial(layer)
	detach_from_summoner()
	if(emissive)
		set_light_on(FALSE)
	cut_barriers()
	parent_holder.reset_monitor_hud()
	if(!forced)
		COOLDOWN_START(src, manifest_cooldown, HOLOPARASITE_MANIFEST_COOLDOWN)
		if(hud_used)
			var/atom/movable/screen/holoparasite/manifest_recall/mr_hud = locate() in hud_used.static_inventory
			mr_hud?.begin_timer(HOLOPARASITE_MANIFEST_COOLDOWN)
	SEND_SIGNAL(src, COMSIG_HOLOPARA_RECALL, forced)
