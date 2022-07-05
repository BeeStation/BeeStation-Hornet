#define MOVE_ANIMATION_STAGE_ONE 1
#define MOVE_ANIMATION_STAGE_TWO 2
/obj/structure/transit_tube_pod
	icon = 'icons/obj/atmospherics/pipes/transit_tube.dmi'
	icon_state = "pod"
	animate_movement = FORWARD_STEPS
	anchored = TRUE
	density = TRUE
	layer = BELOW_OBJ_LAYER
	var/moving = 0
	var/datum/gas_mixture/air_contents = new()
	var/obj/structure/transit_tube/current_tube = null

/obj/structure/transit_tube_pod/Initialize(mapload)
	. = ..()
	air_contents.set_moles(GAS_O2, MOLES_O2STANDARD)
	air_contents.set_moles(GAS_N2, MOLES_N2STANDARD)
	air_contents.set_temperature(T20C)


/obj/structure/transit_tube_pod/Destroy()
	empty_pod()
	return ..()

/obj/structure/transit_tube_pod/update_icon()
	if(contents.len)
		icon_state = "pod_occupied"
	else
		icon_state = "pod"

/obj/structure/transit_tube_pod/attackby(obj/item/I, mob/user, params)
	if(I.tool_behaviour == TOOL_CROWBAR)
		if(!moving)
			I.play_tool_sound(src)
			if(contents.len)
				user.visible_message("[user] empties \the [src].", "<span class='notice'>You empty \the [src].</span>")
				empty_pod()
			else
				deconstruct(TRUE, user)
	else
		return ..()

/obj/structure/transit_tube_pod/deconstruct(disassembled = TRUE, mob/user)
	if(!(flags_1 & NODECONSTRUCT_1))
		var/atom/location = get_turf(src)
		if(user)
			location = user.loc
			add_fingerprint(user)
			user.visible_message("[user] removes [src].", "<span class='notice'>You remove [src].</span>")
		var/obj/structure/c_transit_tube_pod/R = new/obj/structure/c_transit_tube_pod(location)
		transfer_fingerprints_to(R)
		R.setDir(dir)
		empty_pod(location)
	qdel(src)

/obj/structure/transit_tube_pod/ex_act(severity, target)
	..()
	if(!QDELETED(src))
		empty_pod()

/obj/structure/transit_tube_pod/contents_explosion(severity, target)
	for(var/thing in contents)
		switch(severity)
			if(EXPLODE_DEVASTATE)
				SSexplosions.high_mov_atom += thing
			if(EXPLODE_HEAVY)
				SSexplosions.med_mov_atom += thing
			if(EXPLODE_LIGHT)
				SSexplosions.low_mov_atom += thing

/obj/structure/transit_tube_pod/singularity_pull(S, current_size)
	..()
	if(current_size >= STAGE_FIVE)
		deconstruct(FALSE)

/obj/structure/transit_tube_pod/container_resist(mob/living/user)
	if(!user.incapacitated())
		empty_pod()
		return
	if(!moving)
		user.changeNext_move(CLICK_CD_BREAKOUT)
		user.last_special = world.time + CLICK_CD_BREAKOUT
		to_chat(user, "<span class='notice'>You start trying to escape from the pod...</span>")
		if(do_after(user, 600, target = src))
			to_chat(user, "<span class='notice'>You manage to open the pod.</span>")
			empty_pod()

/obj/structure/transit_tube_pod/proc/empty_pod(atom/location)
	if(!location)
		location = get_turf(src)
	for(var/atom/movable/M in contents)
		M.forceMove(location)
	update_icon()

/obj/structure/transit_tube_pod/proc/follow_tube(obj/structure/transit_tube/tube)
	if(moving || !tube.has_exit(dir))
		return

	moving = TRUE
	current_tube = tube
	var/datum/move_loop/engine = SSmove_manager.force_move_dir(src, dir, 0, priority = MOVEMENT_ABOVE_SPACE_PRIORITY)
	RegisterSignal(engine, COMSIG_MOVELOOP_PREPROCESS_CHECK, .proc/before_pipe_transfer)
	RegisterSignal(engine, COMSIG_MOVELOOP_POSTPROCESS, .proc/after_pipe_transfer)
	RegisterSignal(engine, COMSIG_PARENT_QDELETING, .proc/engine_finish)
	calibrate_engine(engine)

/obj/structure/transit_tube_pod/proc/before_pipe_transfer(datum/move_loop/move/source)
	SIGNAL_HANDLER
	setDir(source.direction)

/obj/structure/transit_tube_pod/proc/after_pipe_transfer(datum/move_loop/move/source)
	SIGNAL_HANDLER

	density = current_tube.density
	if(current_tube.should_stop_pod(src, source.direction))
		current_tube.pod_stopped(src, dir)
		qdel(source)
		return
	calibrate_engine(source)

/obj/structure/transit_tube_pod/proc/calibrate_engine(datum/move_loop/move/engine)
	var/next_dir = current_tube.get_exit(dir)

	if(!next_dir)
		qdel(engine)
		return
	var/exit_delay = current_tube.exit_delay(src, dir)
	var/atom/next_loc = get_step(loc, next_dir)

	current_tube = null
	for(var/obj/structure/transit_tube/tube in next_loc)
		if(tube.has_entrance(next_dir))
			current_tube = tube
			break

	if(!current_tube)
		setDir(next_dir)
				// Allow collisions when leaving the tubes.
		Move(get_step(loc, dir), dir)
		qdel(src)
		return

	var/enter_delay = current_tube.enter_delay(src, next_dir)
	engine.direction = next_dir
	engine.set_delay(enter_delay + exit_delay)

/obj/structure/transit_tube_pod/proc/engine_finish()
	SIGNAL_HANDLER
	density = TRUE
	moving = 0

	var/obj/structure/transit_tube/TT = locate(/obj/structure/transit_tube) in loc
	if(!TT || (!(dir in TT.tube_dirs) && !(turn(dir,180) in TT.tube_dirs)))	//landed on a turf without transit tube or not in our direction
		deconstruct(FALSE)	//we automatically deconstruct the pod

/obj/structure/transit_tube_pod/return_air()
	return air_contents

/obj/structure/transit_tube_pod/return_analyzable_air()
	return air_contents

/obj/structure/transit_tube_pod/assume_air(datum/gas_mixture/giver)
	return air_contents.merge(giver)

/obj/structure/transit_tube_pod/assume_air_moles(datum/gas_mixture/giver, moles)
	return giver.transfer_to(air_contents, moles)

/obj/structure/transit_tube_pod/assume_air_ratio(datum/gas_mixture/giver, ratio)
	return giver.transfer_ratio_to(air_contents, ratio)

/obj/structure/transit_tube_pod/remove_air(amount)
	return air_contents.remove(amount)

/obj/structure/transit_tube_pod/remove_air_ratio(ratio)
	return air_contents.remove_ratio(ratio)

/obj/structure/transit_tube_pod/transfer_air(datum/gas_mixture/taker, moles)
	return air_contents.transfer_to(taker, moles)

/obj/structure/transit_tube_pod/transfer_air_ratio(datum/gas_mixture/taker, ratio)
	return air_contents.transfer_ratio_to(taker, ratio)

/obj/structure/transit_tube_pod/relaymove(mob/mob, direction)
	if(istype(mob) && mob.client)
		if(!moving)
			for(var/obj/structure/transit_tube/station/station in loc)
				if(!station.pod_moving)
					if(direction == turn(station.boarding_dir,180))
						if(station.open_status == STATION_TUBE_OPEN)
							mob.forceMove(loc)
							update_icon()
						else
							station.open_animation()

					else if(direction in station.tube_dirs)
						setDir(direction)
						station.launch_pod()
				return

			for(var/obj/structure/transit_tube/TT in loc)
				if(dir in TT.tube_dirs)
					if(TT.has_exit(direction))
						setDir(direction)
						return

/obj/structure/transit_tube_pod/return_temperature()
	return air_contents.return_temperature()

#undef MOVE_ANIMATION_STAGE_ONE
#undef MOVE_ANIMATION_STAGE_TWO
