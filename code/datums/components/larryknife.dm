//Larry With Knives
/datum/component/knife_attached_to_movable
	dupe_mode = COMPONENT_DUPE_UNIQUE
	var/knife_damage

	var/static/list/default_connections = list(COMSIG_ATOM_ENTERED = PROC_REF(knife_crossed))

/datum/component/knife_attached_to_movable/Initialize(damage = 0)
	knife_damage = damage
	RegisterSignal(parent, COMSIG_ATOM_ENTERED, PROC_REF(knife_crossed))
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(knife_move))
	add_connect_loc_behalf_to_parent()

/datum/component/knife_attached_to_movable/proc/add_connect_loc_behalf_to_parent()
	if(ismovable(parent))
		AddComponent(/datum/component/connect_loc_behalf, parent, default_connections)

/datum/component/knife_attached_to_movable/proc/stab(mob/living/carbon/C)
	if(!TIMER_COOLDOWN_CHECK(src, COOLDOWN_LARRYKNIFE))
		var/atom/movable/P = parent
		var/leg
		if(prob(50))
			leg = BODY_ZONE_R_LEG
		else
			leg = BODY_ZONE_L_LEG
		C.apply_damage(knife_damage, BRUTE, leg)
		P.visible_message("<span class='warning'>[C.name] is stabbed by [P.name].</span>")
		playsound(get_turf(P), 'sound/weapons/slice.ogg', 50, 1)
		TIMER_COOLDOWN_START(src, COOLDOWN_LARRYKNIFE, 2 SECONDS)

/datum/component/knife_attached_to_movable/proc/knife_crossed(datum/source, atom/movable/M, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER

	if(iscarbon(M))
		var/mob/living/carbon/C = M
		stab(C)

/datum/component/knife_attached_to_movable/proc/knife_move()
	var/atom/movable/A = parent
	if(isturf(A.loc))
		var/turf/T = get_turf(A)
		for(var/mob/living/carbon/C in T.contents)
			stab(C)
			break
