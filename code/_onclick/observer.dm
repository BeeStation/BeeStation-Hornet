/mob/dead/observer/DblClickOn(atom/A, params)
	if(check_click_intercept(params, A))
		return

	if(can_reenter_corpse && mind && mind.current)
		if(A == mind.current || (mind.current in A)) // double click your corpse or whatever holds it
			reenter_corpse()						// (cloning scanner, body bag, closet, mech, etc)
			return									// seems legit.

	// Things you might plausibly want to follow
	if(ismovable(A))
		check_orbitable(A)

	// Otherwise jump
	else if(A.loc)
		abstract_move(get_turf(A))

/mob/dead/observer/ClickOn(atom/A, params)
	if(check_click_intercept(params,A))
		return

	var/list/modifiers = params2list(params)
	if(SEND_SIGNAL(src, COMSIG_MOB_CLICKON, A, modifiers) & COMSIG_MOB_CANCEL_CLICKON)
		return

	if(LAZYACCESS(modifiers, SHIFT_CLICK))
		if(LAZYACCESS(modifiers, MIDDLE_CLICK))
			ShiftMiddleClickOn(A, params)
			return
		if(LAZYACCESS(modifiers, CTRL_CLICK))
			CtrlShiftClickOn(A)
			return
		ShiftClickOn(A)
		return
	if(LAZYACCESS(modifiers, MIDDLE_CLICK))
		MiddleClickOn(A, params)
		return
	if(LAZYACCESS(modifiers, ALT_CLICK))
		AltClickOn(A)
		return
	if(LAZYACCESS(modifiers, CTRL_CLICK))
		CtrlClickOn(A)
		return

	if(world.time <= next_move)
		return
	// You are responsible for checking config.ghost_interaction when you override this function
	// Not all of them require checking, see below
	A.attack_ghost(src)

// Oh by the way this didn't work with old click code which is why clicking shit didn't spam you
/atom/proc/attack_ghost(mob/dead/observer/user)
	if(SEND_SIGNAL(src, COMSIG_ATOM_ATTACK_GHOST, user) & COMPONENT_CANCEL_ATTACK_CHAIN)
		return TRUE
	if(user.client)
		if(user.gas_scan && atmos_scan(user = user, target = src, silent = TRUE))
			return TRUE
		//additional arguments are here due to how extrapolators work
		if(user.virus_scan && virusscan(user, src, 10, 10, list()))
			return TRUE
		else if(IsAdminGhost(user))
			attack_ai(user)
		else if(user.client.prefs.read_player_preference(/datum/preference/toggle/inquisitive_ghost))
			user.examinate(src)
	return FALSE

/mob/living/attack_ghost(mob/dead/observer/user)
	if(user.client)
		if(user.health_scan)
			healthscan(user, src, 1, TRUE)
			chemscan(user, src, 1, TRUE)
		if(user.genetics_scan)
			genescan(src, user)
		if(user.nanite_scan)
			var/response = SEND_SIGNAL(src, COMSIG_NANITE_SCAN, user, TRUE)
			if(!response)
				to_chat(user, span_info("No nanites detected in the subject."))
	return ..()

// ---------------------------------------
// And here are some good things for free:
// Now you can click through portals, wormholes, gateways, and teleporters while observing. -Sayu

/obj/machinery/gateway/attack_ghost(mob/user)
	. = ..()
	if(.)
		return

	if(linked_gateway)
		user.abstract_move(get_turf(linked_gateway))
		return TRUE
	to_chat(user, "[src] has no destination.")
	return TRUE

/obj/machinery/teleport/hub/attack_ghost(mob/user)
	if(!power_station?.engaged || !power_station.teleporter_console || !power_station.teleporter_console.target_ref)
		return ..()

	var/atom/target = power_station.teleporter_console.target_ref.resolve()
	if(!target)
		power_station.teleporter_console.target_ref = null
		return ..()

	user.abstract_move(get_turf(target))
