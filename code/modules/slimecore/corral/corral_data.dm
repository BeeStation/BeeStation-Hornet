//this is just a doc comment but currently the max interior size is 9x9 so 11x11 if you include the corral walls
/datum/corral_data
	///list of all managed slimes
	var/list/managed_slimes = list()
	///the installed corral upgrades
	var/list/corral_upgrades = list()

	///the turfs inside the corral
	var/list/corral_turfs = list()
	///our corral corners
	var/list/corral_corners = list()
	///the corral connecter effects
	var/list/corral_connectors = list()

	var/max_capacity = 20

/datum/corral_data/proc/setup_pen()
	for(var/turf/turf as anything in corral_turfs)
		turf.air_update_turf(update = TRUE, remove = FALSE)
		RegisterSignal(turf, COMSIG_ATOM_ENTERED, PROC_REF(check_entered))
		RegisterSignal(turf, COMSIG_ATOM_EXITED, PROC_REF(check_exited))

		for(var/mob/living/basic/slime/slime as anything in turf.contents)
			if(!istype(slime))
				continue

			if(length(managed_slimes) >= max_capacity)
				slime.death()
				slime.visible_message("The pressure of the slimes kills [slime].")
				continue

			managed_slimes |= slime
			RegisterSignal(slime, COMSIG_ATOM_SUCKED, PROC_REF(remove_cause_sucked))
			RegisterSignal(slime, COMSIG_LIVING_DEATH, PROC_REF(remove_cause_sucked))
			RegisterSignals(slime, list(COMSIG_PREQDELETED, COMSIG_QDELETING), PROC_REF(try_remove))

	for(var/obj/machinery/corral_corner/corner as anything in corral_corners)
		RegisterSignal(corner, COMSIG_QDELETING, PROC_REF(start_break))

/datum/corral_data/Destroy(force, ...)
	QDEL_LIST(corral_connectors)
	for(var/turf/turf as anything in corral_turfs)
		if(!QDELETED(turf))
			turf.air_update_turf(update = TRUE, remove = FALSE)
	corral_turfs = null

	for(var/obj/machinery/corral_corner/corner as anything in corral_corners)
		corner.connected_data = null
		UnregisterSignal(corner, COMSIG_QDELETING)
		corral_corners -= corner
	corral_corners = null

	for(var/mob/living/basic/slime/slime as anything in managed_slimes)
		UnregisterSignal(slime, COMSIG_ATOM_SUCKED)
		UnregisterSignal(slime, COMSIG_LIVING_DEATH)
	managed_slimes = null

	. = ..()

/datum/corral_data/proc/check_entered(datum/source, atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	if(!istype(arrived, /mob/living/basic/slime))
		return

	if(isliving(arrived))
		var/mob/living/living = arrived
		if(living.stat == DEAD)
			return

	if(arrived in managed_slimes)
		return

	if(length(managed_slimes) >= max_capacity)
		var/mob/living/living = arrived
		living.visible_message("The pressure of the slimes kills [living].")
		living.death()
		return

	RegisterSignal(arrived, COMSIG_ATOM_SUCKED, PROC_REF(remove_cause_sucked))
	RegisterSignal(arrived, COMSIG_LIVING_DEATH, PROC_REF(remove_cause_sucked))
	RegisterSignals(arrived, list(COMSIG_PREQDELETED, COMSIG_QDELETING), PROC_REF(try_remove))
	managed_slimes |= arrived
	for(var/datum/corral_upgrade/upgrade as anything in corral_upgrades)
		upgrade.on_slime_entered(arrived, src)
	update_slimes()

/datum/corral_data/proc/check_exited(turf/source, atom/movable/gone, direction)
	if(!istype(gone, /mob/living/basic/slime))
		return

	var/turf/turf = get_step(source, direction)
	if(turf in corral_turfs)
		return

	UnregisterSignal(gone, COMSIG_ATOM_SUCKED)
	UnregisterSignal(gone, COMSIG_LIVING_DEATH)
	UnregisterSignal(gone, list(COMSIG_PREQDELETED, COMSIG_QDELETING))
	managed_slimes -= gone
	for(var/datum/corral_upgrade/upgrade as anything in corral_upgrades)
		upgrade.on_slime_exited(gone)
	update_slimes()

/datum/corral_data/proc/remove_cause_sucked(atom/movable/gone)

	UnregisterSignal(gone, COMSIG_ATOM_SUCKED)
	UnregisterSignal(gone, COMSIG_LIVING_DEATH)
	UnregisterSignal(gone, list(COMSIG_PREQDELETED, COMSIG_QDELETING))
	managed_slimes -= gone
	for(var/datum/corral_upgrade/upgrade as anything in corral_upgrades)
		upgrade.on_slime_exited(gone)
	update_slimes()

/datum/corral_data/proc/try_remove(mob/living/basic/slime/source)
	managed_slimes -= source
	update_slimes()

/datum/corral_data/proc/update_slimes()
	for(var/mob/living/basic/slime/slime as anything in managed_slimes)
		if(QDELETED(slime) || !(get_turf(slime) in corral_turfs))
			managed_slimes -= slime
			if(QDELETED(slime))
				continue
			UnregisterSignal(slime, COMSIG_ATOM_SUCKED)
			UnregisterSignal(slime, COMSIG_LIVING_DEATH)
			UnregisterSignal(slime, list(COMSIG_PREQDELETED, COMSIG_QDELETING))
			for(var/datum/corral_upgrade/upgrade as anything in corral_upgrades)
				upgrade.on_slime_exited(slime)

/datum/corral_data/proc/start_break()
	qdel(src)
