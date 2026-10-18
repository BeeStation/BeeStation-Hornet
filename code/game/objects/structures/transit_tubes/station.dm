#define OPEN_DURATION (0.6 SECONDS)
#define CLOSE_DURATION (0.6 SECONDS)

// A place where tube pods stop, and people can get in or out.
// Mappers: use "Generate Instances from Directions" for this
// one.

/obj/structure/transit_tube/station
	name = "station tube station"
	icon_state = "closed_station0"
	base_icon_state = "station0"
	desc = "The lynchpin of the transit system."
	exit_delay = 1
	enter_delay = 2
	tube_construction = /obj/structure/c_transit_tube/station

	var/open_status = STATION_TUBE_CLOSED
	var/pod_moving = FALSE
	var/cooldown_delay = 5 SECONDS
	COOLDOWN_DECLARE(launch_cooldown)
	var/reverse_launch = FALSE
	var/boarding_dir //from which direction you can board the tube
	var/flipped = FALSE

/obj/structure/transit_tube/station/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/structure/transit_tube/station/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/structure/transit_tube/station/should_stop_pod(pod, from_dir)
	return TRUE

/obj/structure/transit_tube/station/Bumped(atom/movable/AM)
	. = ..()
	if(pod_moving || open_status != STATION_TUBE_OPEN || !isliving(AM) || AM.dir != boarding_dir)
		return

	var/obj/structure/transit_tube_pod/pod = locate() in loc
	if(!pod || pod.moving)
		return

	AM.forceMove(pod)
	pod.update_appearance(UPDATE_ICON_STATE)

//pod insertion
/obj/structure/transit_tube/station/MouseDrop_T(obj/structure/c_transit_tube_pod/unattached_pod, mob/user)
	if (astype(user, /mob/living)?.incapacitated || !istype(unattached_pod) || !in_range(user, src) || !in_range(src, unattached_pod))
		return
	if(locate(/obj/structure/transit_tube_pod) in loc)
		return //no fun allowed
	var/obj/structure/transit_tube_pod/new_pod = new(loc)
	unattached_pod.transfer_fingerprints_to(new_pod)
	new_pod.add_fingerprint(user)
	new_pod.setDir(turn(src.dir, -90))
	user.visible_message(span_notice("[user] inserts [unattached_pod]."), span_notice("You insert [unattached_pod]."))
	qdel(unattached_pod)

/obj/structure/transit_tube/station/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(. || pod_moving)
		return

	var/obj/structure/transit_tube_pod/pod = locate() in loc
	if(!pod)
		return

	// If we're not dragging anyone:
	// 1. Open the pod if it's closed
	// 2. Otherwise, if we aren't in the pod, try to empty out its contents
	// 3. If we can't do that, close the pod.
	if(!isliving(user.pulling))
		if(pod.moving || !(pod.dir in tube_dirs))
			return

		if(open_status == STATION_TUBE_CLOSED)
			open_animation()
		else if(open_status == STATION_TUBE_OPEN)
			if(!length(pod.contents) || user.loc == pod)
				close_animation()
				return

			user.visible_message(
				span_notice("[user] starts emptying [pod]'s contents onto the floor."),
				span_notice("You start emptying [pod]'s contents onto the floor..."),
			)
			if(!do_after(user, 1 SECONDS, target = src))
				balloon_alert(user, "interrupted!")
				return
			// make sure the pod hasn't moved and still exists
			if(!QDELETED(pod) && pod.loc == loc)
				for(var/atom/movable/thing in pod)
					thing.forceMove(get_turf(user))
		return

	// We've gotten to this point which means that we're dragging a living mob, so let's try to shove them into the pod!
	if(open_status != STATION_TUBE_OPEN || user.grab_state < GRAB_AGGRESSIVE)
		return

	var/mob/living/grabbed_mob = user.pulling
	if(grabbed_mob.buckled || grabbed_mob.has_buckled_mobs())
		to_chat(user, span_warning("[grabbed_mob] is attached to something!"))
		return

	pod.visible_message(
		span_warning("[user] starts putting [grabbed_mob] into the [pod]!"),
		span_notice("You start putting [grabbed_mob] into the pod!"),
	)
	if(!do_after(user, 1.5 SECONDS, target = src))
		balloon_alert(user, "interrupted!")
		return

	// make sure we're still in a valid state to shove them into the pod
	if(open_status != STATION_TUBE_OPEN || QDELETED(grabbed_mob) || user.grab_state < GRAB_AGGRESSIVE || user.pulling != grabbed_mob || grabbed_mob.buckled || grabbed_mob.has_buckled_mobs())
		return
	grabbed_mob.Paralyze(10 SECONDS)
	src.Bumped(grabbed_mob)

/obj/structure/transit_tube/station/crowbar_act(mob/living/user, obj/item/tool)
	var/anything_done = FALSE
	for(var/obj/structure/transit_tube_pod/victim in loc)
		victim.deconstruct(FALSE, user)
		anything_done = TRUE
	to_chat(user, span_notice("[anything_done ? "You empty \the [src]." : "\The [src] is already empty!"]"))
	return ITEM_INTERACT_SUCCESS

/obj/structure/transit_tube/station/proc/open_animation()
	if(open_status == STATION_TUBE_CLOSED)
		icon_state = "opening_[base_icon_state]"
		open_status = STATION_TUBE_OPENING
		addtimer(CALLBACK(src, PROC_REF(finish_animation)), OPEN_DURATION)

/obj/structure/transit_tube/station/proc/finish_animation()
	switch(open_status)
		if(STATION_TUBE_OPENING)
			icon_state = "open_[base_icon_state]"
			open_status = STATION_TUBE_OPEN
			for(var/obj/structure/transit_tube_pod/pod in loc)
				for(var/atom/movable/thing as anything in pod)
					// Let the mobs with clients decide what they want to do themselves.
					if(ismob(thing))
						var/mob/mob_content = thing
						if(mob_content.client && mob_content.stat < UNCONSCIOUS)
							continue

					var/atom/movable/movable_content = thing
					movable_content.forceMove(loc) //Everything else is moved out of.
		if(STATION_TUBE_CLOSING)
			icon_state = "closed_[base_icon_state]"
			open_status = STATION_TUBE_CLOSED

/obj/structure/transit_tube/station/proc/close_animation()
	if(open_status == STATION_TUBE_OPEN)
		icon_state = "closing_[base_icon_state]"
		open_status = STATION_TUBE_CLOSING
		addtimer(CALLBACK(src, PROC_REF(finish_animation)), CLOSE_DURATION)

/obj/structure/transit_tube/station/proc/launch_pod()
	if(!COOLDOWN_FINISHED(src, launch_cooldown))
		return
	for(var/obj/structure/transit_tube_pod/pod in loc)
		if(pod.moving)
			continue
		pod_moving = TRUE
		close_animation()
		sleep(CLOSE_DURATION + 0.2 SECONDS)
		if(open_status == STATION_TUBE_CLOSED && !QDELETED(pod) && pod.loc == loc)
			pod.follow_tube(src)
		pod_moving = FALSE
		return TRUE
	return FALSE

/obj/structure/transit_tube/station/process()
	if(!pod_moving)
		launch_pod()

/obj/structure/transit_tube/station/pod_stopped(obj/structure/transit_tube_pod/pod, from_dir)
	pod_moving = TRUE
	addtimer(CALLBACK(src, PROC_REF(start_stopped), pod), 0.5 SECONDS)

/obj/structure/transit_tube/station/proc/start_stopped(obj/structure/transit_tube_pod/pod)
	if(QDELETED(pod))
		return
	if(reverse_launch)
		pod.setDir(tube_dirs[1]) //turning the pod around for next launch.
	COOLDOWN_START(src, launch_cooldown, cooldown_delay)
	open_animation()
	addtimer(CALLBACK(src, PROC_REF(finish_stopped), pod), OPEN_DURATION + 2)

/obj/structure/transit_tube/station/proc/finish_stopped(obj/structure/transit_tube_pod/pod)
	pod_moving = FALSE
	if(QDELETED(pod))
		return
	var/datum/gas_mixture/floor_mixture = loc.return_air()
	if(pod.air_contents.equalize(floor_mixture)) //equalize the pod's mix with the tile it's on
		air_update_turf(FALSE, FALSE)

/obj/structure/transit_tube/station/init_tube_dirs()
	switch(dir)
		if(NORTH)
			tube_dirs = list(EAST, WEST)
		if(SOUTH)
			tube_dirs = list(EAST, WEST)
		if(EAST)
			tube_dirs = list(NORTH, SOUTH)
		if(WEST)
			tube_dirs = list(NORTH, SOUTH)
	boarding_dir = flipped ? dir : REVERSE_DIR(dir)

/obj/structure/transit_tube/station/flipped
	icon_state = "closed_station1"
	base_icon_state = "station1"
	tube_construction = /obj/structure/c_transit_tube/station/flipped
	flipped = TRUE

// Stations which will send the tube in the opposite direction after their stop.
/obj/structure/transit_tube/station/reverse
	tube_construction = /obj/structure/c_transit_tube/station/reverse
	reverse_launch = TRUE
	icon_state = "closed_terminus0"
	base_icon_state = "terminus0"

/obj/structure/transit_tube/station/reverse/init_tube_dirs()
	switch(dir)
		if(NORTH)
			tube_dirs = list(EAST)
		if(SOUTH)
			tube_dirs = list(WEST)
		if(EAST)
			tube_dirs = list(SOUTH)
		if(WEST)
			tube_dirs = list(NORTH)
	boarding_dir = flipped ? dir : REVERSE_DIR(dir)

/obj/structure/transit_tube/station/reverse/flipped
	icon_state = "closed_terminus1"
	base_icon_state = "terminus1"
	tube_construction = /obj/structure/c_transit_tube/station/reverse/flipped
	flipped = TRUE

//special dispenser station, it creates a pod for you to enter when you bump into it.

/obj/structure/transit_tube/station/dispenser
	name = "station tube pod dispenser"
	icon_state = "open_dispenser0"
	desc = "The lynchpin of a GOOD transit system."
	enter_delay = 1
	tube_construction = /obj/structure/c_transit_tube/station/dispenser
	base_icon_state = "dispenser0"
	open_status = STATION_TUBE_OPEN

	COOLDOWN_DECLARE(freight_output)
	COOLDOWN_DECLARE(freight_message)

/obj/structure/transit_tube/station/dispenser/close_animation()
	return

/obj/structure/transit_tube/station/dispenser/launch_pod()
	for(var/obj/structure/transit_tube_pod/pod in loc)
		if(pod.moving)
			continue
		pod_moving = TRUE
		pod.follow_tube(src)
		pod_moving = FALSE
		return TRUE
	return FALSE

/obj/structure/transit_tube/station/dispenser/examine(mob/user)
	. = ..()
	. += span_notice("This station will create a pod for you to ride, no need to wait for one.")

/obj/structure/transit_tube/station/dispenser/Bumped(atom/movable/AM)
	if(!istype(AM) || AM.dir != boarding_dir || AM.anchored)
		return
	if(!isliving(AM))
		if(!COOLDOWN_FINISHED(src, freight_output))
			if(COOLDOWN_FINISHED(src, freight_message))
				AM.visible_message(span_notice("Freight pod dispenser is recharging. Please wait."))
				COOLDOWN_START(src, freight_message, 10 SECONDS)
			return
		COOLDOWN_START(src, freight_output, 2 SECONDS)

	var/obj/structure/transit_tube_pod/dispensed/pod = new(loc)
	AM.visible_message(
		span_notice("[pod] forms around [AM]."),
		span_notice("[pod] materializes around you."),
	)
	playsound(src, 'sound/weapons/emitter2.ogg', 50, TRUE)
	pod.setDir(turn(src.dir, -90))
	AM.forceMove(pod)
	pod.update_appearance(UPDATE_ICON_STATE)
	launch_pod()

/obj/structure/transit_tube/station/dispenser/pod_stopped(obj/structure/transit_tube_pod/pod, from_dir)
	playsound(src, 'sound/machines/ding.ogg', 50, TRUE)
	qdel(pod)

/obj/structure/transit_tube/station/dispenser/flipped
	icon_state = "open_dispenser1"
	base_icon_state = "dispenser1"
	tube_construction = /obj/structure/c_transit_tube/station/dispenser/flipped
	flipped = TRUE

/obj/structure/transit_tube/station/dispenser/reverse
	icon_state = "open_terminusdispenser0"
	base_icon_state = "terminusdispenser0"
	tube_construction = /obj/structure/c_transit_tube/station/dispenser/reverse
	reverse_launch = TRUE

/obj/structure/transit_tube/station/dispenser/reverse/init_tube_dirs()
	switch(dir)
		if(NORTH)
			tube_dirs = list(EAST)
		if(SOUTH)
			tube_dirs = list(WEST)
		if(EAST)
			tube_dirs = list(SOUTH)
		if(WEST)
			tube_dirs = list(NORTH)
	boarding_dir = flipped ? dir : REVERSE_DIR(dir)

/obj/structure/transit_tube/station/dispenser/reverse/flipped
	icon_state = "open_terminusdispenser1"
	base_icon_state = "terminusdispenser1"
	tube_construction = /obj/structure/c_transit_tube/station/dispenser/reverse/flipped
	flipped = TRUE

#undef OPEN_DURATION
#undef CLOSE_DURATION
