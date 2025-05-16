/**
 * Registers the relevant signals with a body.
 */
/mob/living/simple_animal/hostile/holoparasite/proc/register_body_signals(mob/living/target)
	RegisterSignal(target, COMSIG_MOVABLE_MOVED, PROC_REF(on_summoner_moved))
	RegisterSignal(target, COMSIG_ATOM_DIR_CHANGE, PROC_REF(on_summoner_dir_change))
	RegisterSignal(target, COMSIG_LIVING_HEALTH_UPDATE, PROC_REF(on_summoner_update_health))
	RegisterSignal(target, COMSIG_LIVING_ON_WABBAJACKED, PROC_REF(on_owner_wabbajacked))
	RegisterSignal(target, COMSIG_LIVING_SHAPESHIFTED, PROC_REF(on_owner_shapeshifted))
	RegisterSignal(target, COMSIG_LIVING_UNSHAPESHIFTED, PROC_REF(on_owner_unshapeshifted))

/**
 * Unregisters the relevant signals from a body.
 */
/mob/living/simple_animal/hostile/holoparasite/proc/unregister_body_signals(mob/living/target)
	UnregisterSignal(target, list(COMSIG_MOVABLE_MOVED, COMSIG_ATOM_DIR_CHANGE, COMSIG_LIVING_HEALTH_UPDATE, COMSIG_LIVING_ON_WABBAJACKED, COMSIG_LIVING_SHAPESHIFTED, COMSIG_LIVING_UNSHAPESHIFTED))

/**
 * Handle the summoner's movement, snapping the holoparasite back to their them if they move too far away,
 * and re-drawing the range barriers.
 */
/mob/living/simple_animal/hostile/holoparasite/proc/on_summoner_moved()
	SIGNAL_HANDLER
	snapback()
	setup_barriers()

/**
 * Handle the summoner changing direction.
 * We just update the attachment visuals here, so an attached holoparasite smoothly stays behind the back of its summoner.
 */
/mob/living/simple_animal/hostile/holoparasite/proc/on_summoner_dir_change()
	SIGNAL_HANDLER
	update_summoner_attachment()

/**
 * Handles updating the medhuds and such whenever the summoner's health is updated.
 */
/mob/living/simple_animal/hostile/holoparasite/proc/on_summoner_update_health()
	SIGNAL_HANDLER
	update_health_hud()
	med_hud_set_health()
	med_hud_set_status()
