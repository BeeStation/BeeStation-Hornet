#define STAIR_TERMINATOR_AUTOMATIC 0
#define STAIR_TERMINATOR_NO 1
#define STAIR_TERMINATOR_YES 2

// dir determines the direction of travel to go upwards
// stairs require /turf/open/transparentopenspace as the tile above them to work, unless your stairs have 'force_open_above' set to TRUE
// multiple stair objects can be chained together; the Z level transition will happen on the final stair object in the chain

/obj/structure/stairs
	name = "stairs"
	icon = 'icons/obj/stairs.dmi'
	icon_state = "stairs"
	anchored = TRUE

	var/force_open_above = FALSE // replaces the turf above this stair obj with /turf/open/openspace
	var/terminator_mode = STAIR_TERMINATOR_AUTOMATIC
	var/turf/listeningTo


/obj/structure/stairs/Initialize(mapload)
	GLOB.stairs += src
	if(force_open_above)
		force_open_above()
		build_signal_listener()
	update_surrounding()

	var/static/list/loc_connections = list(
		COMSIG_ATOM_EXIT = PROC_REF(on_exit),
	)

	AddElement(/datum/element/connect_loc, loc_connections)

	return ..()

/obj/structure/stairs/Destroy()
	listeningTo = null
	GLOB.stairs -= src
	return ..()

/obj/structure/stairs/Move()			//Look this should never happen but...
	. = ..()
	if(force_open_above)
		build_signal_listener()
	update_surrounding()

// Passthrough for 0G travel
/obj/structure/stairs/attack_hand(mob/user, list/modifiers)
	var/turf/T = get_turf(src)
	T.attack_hand(user)

/obj/structure/stairs/proc/update_surrounding()
	update_icon()
	for(var/i in GLOB.cardinals)
		var/turf/T = get_step(get_turf(src), i)
		var/obj/structure/stairs/S = locate() in T
		if(S)
			S.update_icon()

/obj/structure/stairs/proc/on_exit(datum/source, atom/movable/leaving, direction)
	SIGNAL_HANDLER

	if(!isobserver(leaving) && isTerminator() && direction == dir)
		INVOKE_ASYNC(src, PROC_REF(stair_ascend), leaving)
		leaving.Bump(src)
		return COMPONENT_ATOM_BLOCK_EXIT

/obj/structure/stairs/Cross(atom/movable/AM)
	if(isTerminator() && (get_dir(src, AM) == dir) && (AM.z <= z))
		return FALSE
	return ..()

/obj/structure/stairs/update_icon()
	if(isTerminator())
		icon_state = "stairs_t"
	else
		icon_state = "stairs"

/obj/structure/stairs/proc/stair_ascend(atom/movable/AM)
	var/turf/checking = get_step_multiz(get_turf(src), UP)
	if(!istype(checking))
		return
	// I'm only interested in if the pass is unobstructed, not if the mob will actually make it
	// Use atom's can_zTravel to forward to turf zPassOut/zPassIn checks. The original call
	// allowed buckled movement via ZMOVE_ALLOW_BUCKLED; can_zTravel doesn't take that flag
	// so we call it with the destination first and direction second (matching its signature).
	if(!AM.can_zTravel(checking, UP))
		return
	var/turf/target = get_step_multiz(get_turf(src), (dir|UP))
	if(istype(target) && !target.can_zFall(AM, null, get_step_multiz(target, DOWN))) //Don't throw them into a tile that will just dump them back down.
		AM.Move(target, (dir | UP))

/obj/structure/stairs/vv_edit_var(var_name, var_value)
	. = ..()
	if(!.)
		return
	if(var_name != NAMEOF(src, force_open_above))
		return
	if(!var_value)
		if(listeningTo)
			UnregisterSignal(listeningTo, COMSIG_TURF_MULTIZ_NEW)
			listeningTo = null
	else
		build_signal_listener()
		force_open_above()

/obj/structure/stairs/proc/build_signal_listener()
	if(listeningTo)
		UnregisterSignal(listeningTo, COMSIG_TURF_MULTIZ_NEW)
	var/turf/open/openspace/T = get_step_multiz(get_turf(src), UP)
	RegisterSignal(T, COMSIG_TURF_MULTIZ_NEW, PROC_REF(on_multiz_new))
	listeningTo = T

/obj/structure/stairs/proc/force_open_above()
	var/turf/open/openspace/T = get_step_multiz(get_turf(src), UP)
	if(T && !istype(T))
		T.ChangeTurf(/turf/open/openspace, flags = CHANGETURF_INHERIT_AIR)

/obj/structure/stairs/proc/on_multiz_new(turf/source, dir)
	SIGNAL_HANDLER

	if(dir == UP)
		var/turf/open/openspace/T = get_step_multiz(get_turf(src), UP)
		if(T && !istype(T))
			T.ChangeTurf(/turf/open/openspace, flags = CHANGETURF_INHERIT_AIR)

/obj/structure/stairs/intercept_zImpact(atom/movable/AM, levels = 1)
	. = ..()
	if(isTerminator())
		. |= FALL_INTERCEPTED | FALL_NO_MESSAGE

/obj/structure/stairs/proc/isTerminator()			//If this is the last stair in a chain and should move mobs up
	if(terminator_mode != STAIR_TERMINATOR_AUTOMATIC)
		return (terminator_mode == STAIR_TERMINATOR_YES)
	var/turf/T = get_turf(src)
	if(!T)
		return FALSE
	var/turf/them = get_step(T, dir)
	if(!them)
		return FALSE
	for(var/obj/structure/stairs/S in them)
		if(S.dir == dir)
			return FALSE
	return TRUE

/obj/structure/stairs/attack_ghost(mob/user)
	stair_ascend(user)

#undef STAIR_TERMINATOR_AUTOMATIC
#undef STAIR_TERMINATOR_NO
#undef STAIR_TERMINATOR_YES
