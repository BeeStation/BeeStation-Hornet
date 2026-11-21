
/// Round-local switch for the experimental perspective. Deliberately not a
/// config entry: no config file or reload can turn it on. It starts off and is
/// changed only through set_brandish_perspective() (the admin/coder verb).
GLOBAL_VAR_INIT(brandish_perspective_enabled, FALSE)

/// Bodies that never use the perspective, even while it is enabled globally.
/// Ghosts, lobby players and other non-living mobs are excluded here.
/mob/proc/brandish_perspective_allowed()
	return FALSE

/mob/living/brandish_perspective_allowed()
	// A mind housed inside a carried object (soulstone shade, possessed blade,
	// sentient artifact, pAI card, MMI) has no body to steer or face forward.
	return !isitem(loc)

/// Cyborgs, AIs and pAIs keep their own cameras and controls.
/mob/living/silicon/brandish_perspective_allowed()
	return FALSE

/mob/living/brain/brandish_perspective_allowed()
	return FALSE

/// Shades exist only inside a container: soulstones and sentient artifacts.
/mob/living/simple_animal/shade/brandish_perspective_allowed()
	return FALSE

/// Server-wide switch. The round starts in the normal perspective; an admin or
/// coder turns the experimental perspective on for every eligible living body.
/proc/set_brandish_perspective(enable)
	enable = !!enable
	if(enable && (locate(/datum/station_trait/client_view_direction) in SSstation.station_traits))
		return FALSE
	var/was_enabled = GLOB.brandish_perspective_enabled
	GLOB.brandish_perspective_enabled = enable
	if(enable && !was_enabled)
		GLOB.brandish_intro_shown.Cut()
	if(enable != was_enabled)
		SEND_GLOBAL_SIGNAL(COMSIG_GLOB_BRANDISH_PERSPECTIVE_CHANGED)
		for(var/client/viewer in GLOB.clients)
			viewer.queue_brandish_camera_sync()
	return TRUE

/client/proc/toggle_brandish_perspective()
	set name = "Toggle Brandish Perspective"
	set category = "Debug"
	set desc = "Switch every living player between the normal view and the experimental Brandish perspective."
	if(!holder || !(holder.rank.rights & (R_ADMIN | R_DEBUG)))
		return
	var/enable = !GLOB.brandish_perspective_enabled
	if(enable && !GLOB.brandish_assets.has_catalog())
		to_chat(src, span_warning("This build uses original artwork. Build with tools/build/build to enable the Brandish perspective."))
		return
	if(!set_brandish_perspective(enable))
		to_chat(src, span_warning("Set the default client direction to NORTH to remove the direction station trait before enabling Brandish."))
		return
	log_admin("[key_name(src)] [enable ? "enabled" : "disabled"] the Brandish perspective for all players.")
	message_admins("[key_name_admin(src)] [enable ? "enabled" : "disabled"] the Brandish perspective for all players.")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Toggle Brandish Perspective")

/client/proc/toggle_brandish_camera()
	set name = "Brandish Camera"
	set category = "Debug"
	set desc = "Toggle relative movement and the forward-facing camera for your current body."
	var/allowed = holder && (holder.rank.rights & (R_ADMIN | R_DEBUG))
	if(!allowed)
		return
	if(!GLOB.brandish_perspective_enabled)
		to_chat(src, span_notice("The Brandish perspective is off. Use Toggle Brandish Perspective to enable it for everyone."))
		return
	if(!GLOB.brandish_assets.has_catalog())
		to_chat(src, span_warning("This build uses original artwork. Build with tools/build/build to enable the Brandish camera."))
		return
	if(brandish_camera)
		brandish_camera_suppressed = TRUE
		QDEL_NULL(brandish_camera)
		to_chat(src, span_notice("Brandish camera disabled. Normal view and controls restored."))
		return
	if(!mob?.brandish_perspective_allowed() || !brandish_has_local_eye() || mob.remote_control || mob.control_object)
		to_chat(src, span_warning("Use this camera while directly controlling a living character that supports it."))
		return
	brandish_camera_suppressed = FALSE
	sync_brandish_camera()
	to_chat(src, span_notice("Brandish camera enabled. The Brandish Perspective Guide shows your current movement bindings. Your character stays below center facing away. Use this verb again to restore the view."))
