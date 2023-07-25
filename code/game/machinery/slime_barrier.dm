//code\game\objects\structures\slime_barrier.dm
/obj/machinery/slime_barrier_generator
	name = "gelatinous exclusion field generator"
	desc = "Keep in mind, it is not made of, nor makes, slime."
	density = FALSE
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "slime_field-off"
	var/active = FALSE
	///active field size, minimum, 0, is 1x1
	var/size = 2
	//powernetstuff
	var/power = 0
	var/maximum_stored_power = 500
	///the attached cable
	var/obj/structure/cable/attached
	///list of active walls
	var/list/walls = list()
	///accessible?
	var/locked = FALSE
	///List of types to block movement
	var/list/pass_blacklist = list(/mob/living/simple_animal/slime, /mob/living/carbon/monkey)

/obj/machinery/slime_barrier_generator/proc/power()
	if(!anchored)
		power = 0
		return
	var/turf/T = get_turf(src)

	var/obj/structure/cable/C = T.get_cable_node()
	var/datum/powernet/PN
	if(C)
		PN = C.powernet //find the powernet of the connected cable

	if(!PN)
		return

	var/surplus = max(PN.avail - PN.load, 0)
	var/avail_power = min(rand(50,200), surplus)
	if(avail_power)
		power += avail_power
		PN.load += avail_power //uses powernet power.

/obj/machinery/slime_barrier_generator/proc/project(replace = TRUE)
	for(var/turf/T in getline(locate(x-(size-(size*0.5)), y+(size-(size*0.5)), z), locate(x+(size-(size*0.5)), y+(size-(size*0.5)), z))) //top
		walls += new /obj/structure/window/slime_barrier(T, NORTH, pass_blacklist)
	for(var/turf/T in getline(locate(x-(size-(size*0.5)), y-(size-(size*0.5)), z), locate(x-(size-(size*0.5)), y+(size-(size*0.5)), z))) //left
		walls += new /obj/structure/window/slime_barrier(T, WEST, pass_blacklist)
	for(var/turf/T in getline(locate(x+(size-(size*0.5)), y-(size-(size*0.5)), z), locate(x+(size-(size*0.5)), y+(size-(size*0.5)), z))) //right
		walls += new /obj/structure/window/slime_barrier(T, EAST, pass_blacklist)
	for(var/turf/T in getline(locate(x-(size-(size*0.5)), y-(size-(size*0.5)), z), locate(x+(size-(size*0.5)), y-(size-(size*0.5)), z))) //bottom
		walls += new /obj/structure/window/slime_barrier(T, SOUTH, pass_blacklist)

/obj/machinery/slime_barrier_generator/proc/use_stored_power(amount)
	power = CLAMP(power - amount, 0, maximum_stored_power)
	update_activity()

/obj/machinery/slime_barrier_generator/proc/update_activity()
	for(var/obj/structure/window/slime_barrier/S as() in walls)
		qdel(S)
	if(obj_flags & EMAGGED)
		sleep(10)
	if(active)
		if(!power)
			visible_message("<span class='danger'>The [src.name] shuts down due to lack of power!</span>", \
			"<span class='italics'>You hear heavy droning fade out.</span>")
			active = FALSE
			icon_state = "slime_field-off"
			return
		project()

/obj/machinery/shieldwallgen/can_be_unfasten_wrench(mob/user, silent)
	if(active)
		if(!silent)
			to_chat(user, "<span class='warning'>Turn off the shield generator first!</span>")
		return FAILED_UNFASTEN
	return ..()

/obj/machinery/slime_barrier_generator/attackby(obj/item/W, mob/living/user, params)
	if(W.tool_behaviour == TOOL_WRENCH)
		default_unfasten_wrench(user, W, 0)

	else if(W.GetID())
		if(allowed(user) && !(obj_flags & EMAGGED))
			locked = !locked
			to_chat(user, "<span class='notice'>You [src.locked ? "lock" : "unlock"] the controls.</span>")
		else if(obj_flags & EMAGGED)
			to_chat(user, "<span class='danger'>Error, access controller damaged!</span>")
		else
			to_chat(user, "<span class='danger'>Access denied.</span>")

	else
		add_fingerprint(user)
		return ..()

/obj/machinery/slime_barrier_generator/interact(mob/user, special_state)
	add_fingerprint(user)
	if(!anchored)
		to_chat(user, "<span class='warning'>\The [src] needs to be firmly secured to the floor first!</span>")
		return
	if(locked && !issilicon(user))
		to_chat(user, "<span class='warning'>The controls are locked!</span>")
		return
	if(!power)
		to_chat(user, "<span class='warning'>\The [src] needs to be powered by a wire!</span>")
		return

	active = (active-1) * -1 //todo: reconsider this
	if(active)
		to_chat(user, "<span class='warning'>You activate the [src]!</span>")
		icon_state = "slime_field-on"
	else
		to_chat(user, "<span class='warning'>You disable the [src]!</span>")
		icon_state = "slime_field-off"

/obj/machinery/slime_barrier_generator/process(delta_time)
	power()
	use_stored_power(50)

/obj/structure/window/slime_barrier
	name = "gelatinous exclusion barrier"
	desc = "Keeps them in, and us out... but also us in."
	icon_state = "slimewindow"
	reinf = FALSE
	heat_resistance = 75000
	armor = list("melee" = 75, "bullet" = 5, "laser" = 0, "energy" = 0, "bomb" = 45, "bio" = 100, "rad" = 100, "fire" = 99, "acid" = 100, "stamina" = 0)
	max_integrity = 10000
	///List of types to block movement
	var/list/pass_blacklist

/obj/structure/window/slime_barrier/Initialize(mapload, dir, var/list/pass_list = list())
	. = ..()
	apply_wibbly_filters(src, 1)
	setDir(dir)
	pass_blacklist = typecacheof(pass_list)
	
/obj/structure/window/slime_barrier/deconstruct(disassembled)
	return

/obj/structure/window/slime_barrier/CanAllowThrough(atom/movable/mover, turf/target)
	. = ..()
	if(!(is_type_in_typecache(target, pass_blacklist)))
		return TRUE
	else
		var/mob/living/simple_animal/S = mover
		if(S.health <= 0)
			return TRUE
	if(.)
		return
	var/attempted_dir = get_dir(loc, target)
	if(attempted_dir == dir)
		return
	if(istype(mover, /obj/structure/window))
		var/obj/structure/window/W = mover
		if(!valid_window_location(loc, W.ini_dir))
			return FALSE
	else if(istype(mover, /obj/structure/windoor_assembly))
		var/obj/structure/windoor_assembly/W = mover
		if(!valid_window_location(loc, W.dir))
			return FALSE
	else if(istype(mover, /obj/machinery/door/window) && !valid_window_location(loc, mover.dir))
		return FALSE
	else if(attempted_dir != dir)
		return TRUE

/obj/structure/window/slime_barrier/on_exit(datum/source, atom/movable/leaving, direction)
	if(!(is_type_in_typecache(leaving, pass_blacklist)))
		return
	else
		var/mob/living/simple_animal/S = leaving
		if(S.health <= 0)
			return

	if (fulltile)
		return

	if(direction == dir && density)
		leaving.Bump(src)
		return COMPONENT_ATOM_BLOCK_EXIT

/obj/structure/window/slime_barrier/attackby(obj/item/I, mob/living/user, params)
	return

/obj/structure/window/slime_barrier/rcd_act(mob/user, obj/item/construction/rcd/the_rcd)
	return

/obj/structure/window/slime_barrier/wrench_act(mob/living/user, obj/item/I)
	return

/obj/structure/window/slime_barrier/attack_hand(mob/user)
	attack_hand(user)

/obj/machinery/slime_barrier_generator/turned_on
	icon_state = "slime_field-on"
	active = TRUE
