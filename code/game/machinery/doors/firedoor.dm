#define CONSTRUCTION_PANEL_OPEN 1 //Maintenance panel is open, still functioning
#define CONSTRUCTION_NO_CIRCUIT 2 //Circuit board removed, can safely weld apart
#define DEFAULT_STEP_TIME 20 /// default time for each step
#define REACTIVATION_DELAY (3 SECONDS) // Delay on reactivation, used to prevent dumb crowbar things. Just trust me

/obj/machinery/door/firedoor
	name = "firelock"
	desc = "A convenable firelock. It has a card reader and a set of indicator lights on the side."
	icon = 'icons/obj/doors/firelocks/doorfireglass.dmi'
	icon_state = "door_open"
	opacity = FALSE
	density = FALSE
	z_flags = NONE // reset zblock
	max_integrity = 300
	resistance_flags = FIRE_PROOF
	heat_proof = TRUE
	glass = TRUE
	sub_door = TRUE
	explosion_block = 1
	safe = FALSE
	layer = BELOW_OPEN_DOOR_LAYER
	closingLayer = CLOSED_FIREDOOR_LAYER
	armor = list(MELEE = 10,  BULLET = 30, LASER = 20, ENERGY = 20, BOMB = 30, BIO = 100, RAD = 100, FIRE = 95, ACID = 70, STAMINA = 0, BLEED = 0)
	interaction_flags_machine = INTERACT_MACHINE_WIRES_IF_OPEN | INTERACT_MACHINE_ALLOW_SILICON | INTERACT_MACHINE_OPEN_SILICON | INTERACT_MACHINE_REQUIRES_SILICON | INTERACT_MACHINE_OPEN
	air_tight = TRUE
	open_speed = 2
	req_one_access = list(ACCESS_ENGINE, ACCESS_ATMOSPHERICS)
	processing_flags = START_PROCESSING_MANUALLY
	assemblytype = /obj/structure/firelock_frame

	COOLDOWN_DECLARE(activation_cooldown)

	///X offset for the overlay lights, so that they line up with the thin border firelocks
	var/light_xoffset = 0
	///Y offset for the overlay lights, so that they line up with the thin border firelocks
	var/light_yoffset = 0


	var/boltslocked = TRUE
	///List of areas we handle. See CalculateAffectingAreas()
	var/list/affecting_areas
	///For the few times we affect only the area we're actually in. Set during Init. If we get moved, we don't update, but this is consistant with fire alarms and also kinda funny so call it intentional.
	var/area/my_area
	///List of problem turfs with bad temperature
	var/list/turf/issue_turfs
	///Tracks if the firelock is being held open by a crowbar. If so, we don't close until they walk away
	var/being_held_open = FALSE
	///Should the firelock ignore atmosphere when choosing to stay open/closed?
	var/ignore_alarms = FALSE
	///Type of alarm we're under. See code/defines/firealarm.dm for the list. This var being null means there is no alarm.
	var/alarm_type = null
	///Is this firelock active/closed?
	var/active = FALSE
	///The merger_id and merger_typecache variables are used to make rows of firelocks activate at the same time.
	var/merger_id = "firelocks"
	var/static/list/merger_typecache

	///Overlay object for the warning lights. This and some plane settings allows the lights to glow in the dark.
	var/mutable_appearance/warn_lights

	///looping sound datum for our fire alarm siren.
	var/datum/looping_sound/firealarm/soundloop
	///Keeps track of if we're playing the alarm sound loop (as only one firelock per group should be). Used during power changes.
	var/is_playing_alarm = FALSE



/obj/machinery/door/firedoor/Initialize(mapload)
	. = ..()
	id_tag = assign_random_name()
	soundloop = new(src, FALSE)
	CalculateAffectingAreas()
	my_area = get_area(src)
	if(name == initial(name))
		update_name()
	if(!merger_typecache)
		merger_typecache = typecacheof(/obj/machinery/door/firedoor)

	RegisterSignal(src, COMSIG_MACHINERY_POWER_RESTORED, PROC_REF(on_power_restore))
	RegisterSignal(src, COMSIG_MACHINERY_POWER_LOST, PROC_REF(on_power_loss))
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/door/firedoor/LateInitialize()
	. = ..()
	RegisterSignal(src, COMSIG_MERGER_ADDING, PROC_REF(merger_adding))
	RegisterSignal(src, COMSIG_MERGER_REMOVING, PROC_REF(merger_removing))
	GetMergeGroup(merger_id, merger_typecache)
	register_adjacent_turfs()

	if(alarm_type) // Fucking subtypes fucking mappers fucking hhhhhhhh
		start_activation_process(alarm_type)

/**
 * Sets the offset for the warning lights.
 *
 * Used for special firelocks with light overlays that don't line up to their sprite.
 */
/obj/machinery/door/firedoor/proc/adjust_lights_starting_offset()
	return

/obj/machinery/door/firedoor/Destroy()
	remove_from_areas()
	QDEL_NULL(soundloop)
	return ..()

/obj/machinery/door/firedoor/examine(mob/user)
	. = ..()
	if(!density)
		. += "<span class='notice'>It is open, but could be <b>pried</b> closed.</span>"
	else if(!welded)
		. += "<span class='notice'>It is closed, but could be <i>pried</i> open. Deconstruction would require it to be <b>welded</b> shut.</span>"
	else if(boltslocked)
		. += "<span class='notice'>It is <i>welded</i> shut. The floor bolts have been locked by <b>screws</b>.</span>"
	else
		. += "<span class='notice'>The bolt locks have been <i>unscrewed</i>, but the bolts themselves are still <b>wrenched</b> to the floor.</span>"

/**
 * Calculates what areas we should worry about.
 *
 * This proc builds a list of areas we are in and areas we border
 * and writes it to affecting_areas.
 */
/obj/machinery/door/firedoor/proc/CalculateAffectingAreas()
	var/list/new_affecting_areas = get_adjacent_open_areas(src) | get_area(src)
	if(compare_list(new_affecting_areas, affecting_areas))
		return //No changes needed

	remove_from_areas()
	affecting_areas = new_affecting_areas
	for(var/area/place in affecting_areas)
		LAZYADD(place.firedoors, src)
	if(active)
		add_as_source()

/obj/machinery/door/firedoor/proc/remove_from_areas()
	remove_as_source()
	for(var/area/place in affecting_areas)
		LAZYREMOVE(place.firedoors, src)

/obj/machinery/door/firedoor/proc/merger_adding(obj/machinery/door/firedoor/us, datum/merger/new_merger)
	SIGNAL_HANDLER
	if(new_merger.id != merger_id)
		return
	RegisterSignal(new_merger, COMSIG_MERGER_REFRESH_COMPLETE, PROC_REF(refresh_shared_turfs))

/obj/machinery/door/firedoor/proc/merger_removing(obj/machinery/door/firedoor/us, datum/merger/old_merger)
	SIGNAL_HANDLER
	if(old_merger.id != merger_id)
		return
	UnregisterSignal(old_merger, COMSIG_MERGER_REFRESH_COMPLETE)

/obj/machinery/door/firedoor/proc/refresh_shared_turfs(datum/source, list/leaving_members, list/joining_members)
	SIGNAL_HANDLER
	var/datum/merger/temp_group = source
	if(temp_group.origin != src)
		return
	var/list/shared_problems = list() // We only want to do this once, this is a nice way of pulling that off
	for(var/obj/machinery/door/firedoor/firelock as anything in temp_group.members)
		firelock.issue_turfs = shared_problems
		for(var/dir in GLOB.cardinals)
			var/turf/checked_turf = get_step(get_turf(firelock), dir)
			if(!checked_turf)
				continue
			if(isclosedturf(checked_turf))
				continue
			process_results(checked_turf)

/obj/machinery/door/firedoor/proc/register_adjacent_turfs()
	if(!loc)
		return

	var/turf/our_turf = get_turf(loc)
	RegisterSignal(our_turf, COMSIG_TURF_CALCULATED_ADJACENT_ATMOS, PROC_REF(process_results))
	for(var/dir in GLOB.cardinals)
		var/turf/checked_turf = get_step(our_turf, dir)

		if(!checked_turf)
			continue

		RegisterSignal(checked_turf, COMSIG_TURF_CHANGE, PROC_REF(adjacent_change))
		RegisterSignal(checked_turf, COMSIG_TURF_EXPOSE, PROC_REF(process_results))
		if(!isopenturf(checked_turf))
			continue
		process_results(checked_turf)

/obj/machinery/door/firedoor/proc/unregister_adjacent_turfs(atom/old_loc)
	if(!loc)
		return

	var/turf/our_turf = get_turf(old_loc)
	UnregisterSignal(our_turf, COMSIG_TURF_CALCULATED_ADJACENT_ATMOS)
	for(var/dir in GLOB.cardinals)
		var/turf/checked_turf = get_step(our_turf, dir)

		if(!checked_turf)
			continue

		UnregisterSignal(checked_turf, COMSIG_TURF_CHANGE)
		UnregisterSignal(checked_turf, COMSIG_TURF_EXPOSE)

// If a turf adjacent to us changes, recalc our affecting areas when it's done yeah?
/obj/machinery/door/firedoor/proc/adjacent_change(turf/changed, path, list/new_baseturfs, flags, list/post_change_callbacks)
	SIGNAL_HANDLER
	post_change_callbacks += CALLBACK(src, PROC_REF(CalculateAffectingAreas))
	post_change_callbacks += CALLBACK(src, PROC_REF(process_results), changed) //check the atmosphere of the changed turf so we don't hold onto alarm if a wall is built

/obj/machinery/door/firedoor/proc/check_atmos(turf/checked_turf)
	var/datum/gas_mixture/environment = checked_turf.return_air()
	if(!environment)
		stack_trace("We tried to check a gas_mixture that doesn't exist for its firetype, what are you DOING")
		return

	if(environment.temperature >= FIRE_MINIMUM_TEMPERATURE_TO_EXIST)
		return FIRELOCK_ALARM_TYPE_HOT
	if(environment.temperature <= BODYTEMP_COLD_DAMAGE_LIMIT)
		return FIRELOCK_ALARM_TYPE_COLD
	return

/obj/machinery/door/firedoor/proc/process_results(datum/source)
	SIGNAL_HANDLER

	for(var/area/place in affecting_areas)
		if(!place.fire_detect) //if any area is set to disable detection
			return

	var/turf/checked_turf = source
	var/result = check_atmos(checked_turf)

	if(result && TURF_SHARES(checked_turf))
		issue_turfs |= checked_turf
		if(alarm_type) // If you've already got an alarm, go away
			return
		// Store our alarm type, in case we can't activate for some reason
		alarm_type = result
		if(!ignore_alarms)
			start_activation_process(result)
	else if(length(issue_turfs))
		issue_turfs -= checked_turf
		if(length(issue_turfs) && alarm_type != FIRELOCK_ALARM_TYPE_GENERIC)
			return
		alarm_type = null
		if(!ignore_alarms)
			start_deactivation_process()



/**
 * Begins activation process of us and our neighbors.
 *
 * This proc will call activate() on every fire lock (including us) listed
 * in the merge group datum. Returns without doing anything if our alarm_type
 * was already set, as that means that we're already active.
 *
 * Arguments:
 * code should be one of three defined alarm types, or can be not supplied. Will dictate the color of the fire alarm lights, and defults to "firelock_alarm_type_generic"
 */
/obj/machinery/door/firedoor/proc/start_activation_process(code = FIRELOCK_ALARM_TYPE_GENERIC)
	if(active)
		return //We're already active
	soundloop.start()
	is_playing_alarm = TRUE
	my_area.fault_status = AREA_FAULT_AUTOMATIC
	my_area.fault_location = name
	var/datum/merger/merge_group = GetMergeGroup(merger_id, merger_typecache)
	for(var/obj/machinery/door/firedoor/buddylock as anything in merge_group.members)
		buddylock.activate(code)

/**
 * Begins deactivation process of us and our neighbors.
 *
 * This proc will call reset() on every fire lock (including us) listed
 * in the merge group datum. sets our alarm type to null, signifying no alarm.
 */
/obj/machinery/door/firedoor/proc/start_deactivation_process()
	soundloop.stop()
	is_playing_alarm = FALSE
	my_area.fault_status = AREA_FAULT_NONE
	my_area.fault_location = null
	var/datum/merger/merge_group = GetMergeGroup(merger_id, merger_typecache)
	for(var/obj/machinery/door/firedoor/buddylock as anything in merge_group.members)
		buddylock.reset()

/**
 * Proc that handles activation of the firelock and all this details
 *
 * Sets the alarm_type variable based on the single arg, which is in turn
 * used by several procs to understand the intended state of the fire lock.
 * Also calls set_status() on all fire alarms in all affected areas, tells
 * the area the firelock sits in to report the event (AI, alarm consoles, etc)
 * and finally calls correct_state(), which will handle opening or closing
 * this fire lock.
 */
/obj/machinery/door/firedoor/proc/activate(code = FIRELOCK_ALARM_TYPE_GENERIC)
	SIGNAL_HANDLER
	if(active)
		return //Already active
	if(ignore_alarms && code != FIRELOCK_ALARM_TYPE_GENERIC)
		return
	if(code != FIRELOCK_ALARM_TYPE_GENERIC && !COOLDOWN_FINISHED(src, activation_cooldown)) // Non generic activation, subject to crowbar safety
		// Properly activate once the timeleft's up
		addtimer(CALLBACK(src, PROC_REF(activate), code), COOLDOWN_TIMELEFT(src, activation_cooldown))
		return
	active = TRUE
	alarm_type = code
	add_as_source()
	update_icon() //Sets the door lights even if the door doesn't move.
	correct_state()


/// Adds this fire door as a source of trouble to all of its areas
/obj/machinery/door/firedoor/proc/add_as_source()
	for(var/area/place in affecting_areas)
		LAZYADD(place.active_firelocks, src)
		if(LAZYLEN(place.active_firelocks) != 1)
			continue
		//if we're the first to activate in this particular area
		place.set_fire_effect(TRUE, AREA_FAULT_AUTOMATIC, name) //bathe in red
		if(place == my_area)
			// We'll limit our reporting to just the area we're on. If the issue affects bordering areas, they can report it themselves
			place.alarm_manager.send_alarm(ALARM_FIRE, place)

/**
 * Proc that handles reset steps
 *
 * Clears the alarm state and attempts to open the firelock.
 */
/obj/machinery/door/firedoor/proc/reset()
	SIGNAL_HANDLER
	alarm_type = null
	active = FALSE
	remove_as_source()
	soundloop.stop()
	is_playing_alarm = FALSE
	update_icon() //Sets the door lights even if the door doesn't move.
	correct_state()

/**
 * Open the firedoor without resetting existing alarms
 *
 * * delay - Reconsider if this door should be open or closed after some period
 *
 */
/obj/machinery/door/firedoor/proc/crack_open(delay)
	active = FALSE
	ignore_alarms = TRUE
	if(!length(issue_turfs)) // Generic alarms get out
		alarm_type = null

	soundloop.stop()
	is_playing_alarm = FALSE
	remove_as_source()
	update_icon() //Sets the door lights even if the door doesn't move.
	correct_state()

	/// Please be called 3 seconds after the LAST open, rather then 3 seconds after the first
	addtimer(CALLBACK(src, PROC_REF(release_constraints)), 3 SECONDS, TIMER_UNIQUE | TIMER_OVERRIDE)

/**
 * Reset our temporary alarm ignoring
 * Consider if we should close ourselves/our neighbors or not
 */
/obj/machinery/door/firedoor/proc/release_constraints()
	ignore_alarms = FALSE
	if(!alarm_type || active) // If we have no alarm type, or are already active, go away
		return
	// Do we even care about temperature?
	for(var/area/place in affecting_areas)
		if(!place.fire_detect) // If any area is set to disable detection
			return
	// Otherwise, reactivate ourselves
	start_activation_process(alarm_type)

/// Removes this firedoor from all areas it's serving as a source of problems for
/obj/machinery/door/firedoor/proc/remove_as_source()
	for(var/area/place in affecting_areas)
		if(!LAZYLEN(place.active_firelocks)) // If it has no active firelocks, do nothing
			continue
		LAZYREMOVE(place.active_firelocks, src)
		if(LAZYLEN(place.active_firelocks)) // If we were the last firelock still active, clear the area effects
			continue
		place.set_fire_effect(FALSE, AREA_FAULT_NONE, name)
		if(place == my_area)
			place.alarm_manager.clear_alarm(ALARM_FIRE, place)

/obj/machinery/door/firedoor/on_emag(mob/user)
	. = ..()
	if(obj_flags & EMAGGED)
		return
	obj_flags |= EMAGGED
	INVOKE_ASYNC(src, PROC_REF(open))

/obj/machinery/door/firedoor/Bumped(atom/movable/AM)
	if(panel_open || operating)
		return
	if(!density)
		return ..()
	return FALSE

/obj/machinery/door/firedoor/bumpopen(mob/living/user)
	return FALSE //No bumping to open, not even in mechs


/obj/machinery/door/firedoor/proc/on_power_loss()
	SIGNAL_HANDLER

	soundloop.stop()

/obj/machinery/door/firedoor/proc/on_power_restore()
	SIGNAL_HANDLER

	correct_state()

	if(is_playing_alarm)
		soundloop.start()

/obj/machinery/door/firedoor/attack_hand(mob/user)
	. = ..()
	if(.)
		return

	if(operating || !density)
		return

	user.changeNext_move(CLICK_CD_MELEE)

	user.visible_message("[user] bangs on \the [src].",
						"You bang on \the [src].")
	playsound(loc, 'sound/effects/glassknock.ogg', 10, FALSE, frequency = 32000)

/obj/machinery/door/firedoor/attackby(obj/item/C, mob/user, params)
	add_fingerprint(user)
	if(operating)
		return

	if(welded)
		if(C.tool_behaviour == TOOL_WRENCH)
			if(boltslocked)
				to_chat(user, "<span class='notice'>There are screws locking the bolts in place!</span>")
				return
			C.play_tool_sound(src)
			user.visible_message("<span class='notice'>[user] starts undoing [src]'s bolts...</span>", \
								"<span class='notice'>You start unfastening [src]'s floor bolts...</span>")
			if(!C.use_tool(src, user, DEFAULT_STEP_TIME))
				return
			playsound(get_turf(src), 'sound/items/deconstruct.ogg', 50, 1)
			user.visible_message("<span class='notice'>[user] unfastens [src]'s bolts.</span>", \
								"<span class='notice'>You undo [src]'s floor bolts.</span>")
			deconstruct(TRUE)
			return
		if(C.tool_behaviour == TOOL_SCREWDRIVER)
			user.visible_message("<span class='notice'>[user] [boltslocked ? "unlocks" : "locks"] [src]'s bolts.</span>", \
								"<span class='notice'>You [boltslocked ? "unlock" : "lock"] [src]'s floor bolts.</span>")
			C.play_tool_sound(src)
			boltslocked = !boltslocked
			return
	return ..()

/obj/machinery/door/firedoor/try_to_activate_door(obj/item/I, mob/user)
	if(!density || welded)
		return

	var/obj/item/card/id/id_card = I.GetID()
	if(istype(id_card))
		if((alarm_type != FIRELOCK_ALARM_TYPE_GENERIC) || check_access(id_card))
			playsound(src, 'sound/machines/beep.ogg', 50, 1)
			open()
			return
		else
			to_chat(user, "<span class='danger'>Access Denied, User not authorized to override alarms or pressure checks.</span>")
			playsound(src, 'sound/machines/terminal_error.ogg', 50, 1)
			return
	to_chat(user, "<span class='warning'>You try to pull the card reader. Nothing happens.</span>")

/obj/machinery/door/firedoor/try_to_weld(obj/item/weldingtool/W, mob/user)
	if(!W.tool_start_check(user, amount=0))
		return
	user.visible_message("<span class='notice'>[user] starts [welded ? "unwelding" : "welding"] [src].</span>", "<span class='notice'>You start welding [src].</span>")
	if(W.use_tool(src, user, DEFAULT_STEP_TIME, volume=50))
		welded = !welded
		to_chat(user, "<span class='danger'>[user] [welded?"welds":"unwelds"] [src].</span>", "<span class='notice'>You [welded ? "weld" : "unweld"] [src].</span>")
		update_icon()
		correct_state()


/obj/machinery/door/firedoor/try_to_crowbar(obj/item/crowbar, mob/user)
	if(welded || operating)
		return

	if(density)
		if(!(machine_stat & NOPOWER))
			to_chat(user, "<span class='warning'>You begin forcing open \the [src], the motors whine...</span>")
			playsound(src, 'sound/machines/airlock_alien_prying.ogg', 100, TRUE)
			if(!crowbar.use_tool(src, user, 10 SECONDS))
				return
		else
			to_chat(user, "<span class='notice'>You begin forcing open \the [src], the motors don't resist...</span>")
			playsound(src, 'sound/machines/airlock_alien_prying.ogg', 100, TRUE)
			if(!crowbar.use_tool(src, user, 1 SECONDS))
				return
		if(!(alarm_type != FIRELOCK_ALARM_TYPE_GENERIC))
			log_game("[key_name(user)] has opened a firelock with a pressure difference or a fire alarm at [AREACOORD(loc)], using a crowbar")
			user.log_message("has opened a firelock with a pressure difference or a fire alarm at [AREACOORD(loc)], using a crowbar", LOG_ATTACK)
		open()
		if(alarm_type)
			addtimer(CALLBACK(src, PROC_REF(correct_state)), 2 SECONDS, TIMER_UNIQUE)
	else
		close()

/obj/machinery/door/firedoor/attack_silicon(mob/user)
	add_fingerprint(user)
	if(welded || operating || machine_stat & NOPOWER)
		return TRUE
	if(density)
		open()
		if(alarm_type)
			addtimer(CALLBACK(src, PROC_REF(correct_state)), 2 SECONDS, TIMER_UNIQUE)
	else
		close()
	return TRUE

/obj/machinery/door/firedoor/attack_alien(mob/user)
	add_fingerprint(user)
	if(welded)
		to_chat(user, "<span class='warning'>[src] refuses to budge!</span>")
		return
	open()
	if(alarm_type)
		addtimer(CALLBACK(src, PROC_REF(correct_state)), 2 SECONDS, TIMER_UNIQUE)

/obj/machinery/door/firedoor/do_animate(animation)
	switch(animation)
		if("opening")
			flick("door_opening", src)
		if("closing")
			flick("door_closing", src)

/obj/machinery/door/firedoor/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state]_[density ? "closed" : "open"]"

/obj/machinery/door/firedoor/update_overlays()
	. = ..()
	if(welded)
		. += density ? "welded" : "welded_open"
	if(alarm_type && powered() && !ignore_alarms)
		var/mutable_appearance/hazards
		hazards = mutable_appearance(icon, "[(obj_flags & EMAGGED) ? "firelock_alarm_type_emag" : alarm_type]")
		hazards.pixel_x = light_xoffset
		hazards.pixel_y = light_yoffset
		. += hazards
		hazards = emissive_appearance(icon, "[(obj_flags & EMAGGED) ? "firelock_alarm_type_emag" : alarm_type]", layer, alpha = src.alpha)
		hazards.pixel_x = light_xoffset
		hazards.pixel_y = light_yoffset
		. += hazards

/**
 * Corrects the current state of the door, based on if alarm_type is set.
 *
 * This proc is called after weld and power restore events. Gives the
 * illusion that the door is constantly attempting to move without actually
 * having to process it. Timers also call this, so that if alarm_type
 * changes during the timer, the door doesn't close or open incorrectly.
 */
/obj/machinery/door/firedoor/proc/correct_state()
	if(obj_flags & EMAGGED || being_held_open)
		return //Unmotivated, indifferent, we have no real care what state we're in anymore.
	if(alarm_type && !density) //We should be closed but we're not
		INVOKE_ASYNC(src, PROC_REF(close))
		return
	if(!alarm_type && density) //We should be open but we're not
		INVOKE_ASYNC(src, PROC_REF(open))
		return

/obj/machinery/door/firedoor/open()
	if(welded)
		return
	var/alarm = alarm_type
	if(density && !operating) //This is hacky but gets the sound to play on time.
		playsound(src, 'sound/machines/firedoor_open.ogg', 30, 1)
	. = ..()
	if(alarm != alarm_type) //Something changed while we were sleeping
		correct_state() //So we should re-evaluate our state

/obj/machinery/door/firedoor/close()
	if(HAS_TRAIT(loc, TRAIT_FIREDOOR_STOP))
		return
	var/alarm = alarm_type
	. = ..()
	if(alarm != alarm_type) //Something changed while we were sleeping
		correct_state() //So we should re-evaluate our state

/obj/machinery/door/firedoor/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		var/turf/targetloc = get_turf(src)
		if(disassembled || prob(40))
			var/obj/structure/firelock_frame/unbuilt_lock = new assemblytype(targetloc)
			if(disassembled)
				unbuilt_lock.constructionStep = CONSTRUCTION_PANEL_OPEN
			else
				unbuilt_lock.constructionStep = CONSTRUCTION_NO_CIRCUIT
				unbuilt_lock.update_integrity(unbuilt_lock.max_integrity * 0.5)
			unbuilt_lock.update_icon()
		else
			new /obj/item/electronics/firelock (targetloc)
	qdel(src)

/obj/machinery/door/firedoor/closed
	icon_state = "door_closed"
	density = TRUE
	alarm_type = FIRELOCK_ALARM_TYPE_GENERIC

/obj/machinery/door/firedoor/border_only
	icon = 'icons/obj/doors/firelocks/edge_Doorfire.dmi'
	flags_1 = ON_BORDER_1
	can_atmos_pass = ATMOS_PASS_PROC

/obj/machinery/door/firedoor/border_only/closed
	icon_state = "door_closed"
	density = TRUE
	alarm_type = FIRELOCK_ALARM_TYPE_GENERIC

/obj/machinery/door/firedoor/border_only/Initialize(mapload)
	. = ..()
	adjust_lights_starting_offset()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_EXIT = PROC_REF(on_exit),
	)

	AddElement(/datum/element/connect_loc, loc_connections)

/obj/machinery/door/firedoor/border_only/adjust_lights_starting_offset()
	light_xoffset = 0
	light_yoffset = 0
	switch(dir)
		if(NORTH)
			light_yoffset = 2
		if(SOUTH)
			light_yoffset = -2
		if(EAST)
			light_xoffset = 2
		if(WEST)
			light_xoffset = -2
	update_icon()

/obj/machinery/door/firedoor/border_only/Moved()
	. = ..()
	adjust_lights_starting_offset()

/obj/machinery/door/firedoor/border_only/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(!(border_dir == dir)) //Make sure looking at appropriate border
		return TRUE

/obj/machinery/door/firedoor/border_only/proc/on_exit(datum/source, atom/movable/leaving, direction)
	SIGNAL_HANDLER
	if(leaving.movement_type & PHASING)
		return
	if(leaving == src)
		return // Let's not block ourselves.

	if(direction == dir && density)
		leaving.Bump(src)
		return COMPONENT_ATOM_BLOCK_EXIT

/obj/machinery/door/firedoor/border_only/can_atmos_pass(turf/T, vertical = FALSE)
	if(get_dir(loc, T) == dir)
		return !density
	else
		return TRUE

/obj/machinery/door/firedoor/heavy
	name = "heavy firelock"
	icon = 'icons/obj/doors/firelocks/doorfire.dmi'
	glass = FALSE
	explosion_block = 2
	assemblytype = /obj/structure/firelock_frame/heavy
	max_integrity = 550

/obj/machinery/door/firedoor/window
	name = "firelock window shutter"
	icon = 'icons/obj/doors/firelocks/doorfirewindow.dmi'
	desc = "A second window that slides in when the original window is broken, designed to protect against hull breaches. Truly a work of genius by NT engineers."
	glass = TRUE
	explosion_block = 0
	max_integrity = 100
	resistance_flags = 0 // not fireproof
	heat_proof = FALSE
	assemblytype = /obj/structure/firelock_frame/window

/obj/machinery/door/firedoor/window/attack_alien(mob/living/carbon/alien/humanoid/user)
	playsound(src.loc, 'sound/weapons/slash.ogg', 100, 1)
	return attack_generic(user, 60, BRUTE, MELEE, 0)

/obj/machinery/door/firedoor/window/process(delta_time)
	set waitfor = FALSE
	return PROCESS_KILL

/obj/item/electronics/firelock
	name = "firelock circuitry"
	custom_price = 5
	desc = "A circuit board used in construction of firelocks."
	icon_state = "mainboard"

/obj/structure/firelock_frame
	name = "firelock frame"
	desc = "A partially completed firelock."
	icon = 'icons/obj/doors/firelocks/doorfire.dmi'
	icon_state = "frame1"
	anchored = FALSE
	density = TRUE
	z_flags = Z_BLOCK_IN_DOWN | Z_BLOCK_IN_UP
	var/constructionStep = CONSTRUCTION_NO_CIRCUIT
	var/reinforced = 0
	var/firelock_type = /obj/machinery/door/firedoor

/obj/structure/firelock_frame/examine(mob/user)
	. = ..()
	switch(constructionStep)
		if(CONSTRUCTION_PANEL_OPEN)
			. += "<span class='notice'>It is <i>unbolted</i> from the floor. The circuit could be removed with a <b>crowbar</b>.</span>"
			if(!reinforced)
				. += "<span class='notice'>It could be reinforced with plasteel.</span>"
		if(CONSTRUCTION_NO_CIRCUIT)
			. += "<span class='notice'>There are no <i>firelock electronics</i> in the frame. The frame could be <b>cut</b> apart.</span>"

/obj/structure/firelock_frame/update_icon()
	..()
	icon_state = "frame[constructionStep]"

/obj/structure/firelock_frame/attackby(obj/item/attacking_object, mob/user)
	switch(constructionStep)
		if(CONSTRUCTION_PANEL_OPEN)
			if(attacking_object.tool_behaviour == TOOL_CROWBAR)
				attacking_object.play_tool_sound(src)
				user.visible_message("<span class = 'notice'>[user] begins removing the circuit board from [src]...</span>", \
					"<span class = 'notice'>You begin prying out the circuit board from [src]...</span>")
				if(!attacking_object.use_tool(src, user, DEFAULT_STEP_TIME))
					return
				if(constructionStep != CONSTRUCTION_PANEL_OPEN)
					return
				playsound(get_turf(src), 'sound/items/deconstruct.ogg', 50, TRUE)
				user.visible_message("<span class = 'notice'>[user] removes [src]'s circuit board.</span>", \
					"<span class = 'notice'>You remove the circuit board from [src].</span>")
				new /obj/item/electronics/firelock(drop_location())
				constructionStep = CONSTRUCTION_NO_CIRCUIT
				update_icon()
				return
			if(attacking_object.tool_behaviour == TOOL_WRENCH)
				if(locate(/obj/machinery/door/firedoor) in get_turf(src))
					to_chat(user, "<span class='warning'>There's already a firelock there.</span>")
					return
				attacking_object.play_tool_sound(src)
				user.visible_message("<span class = 'notice'>[user] starts bolting down [src]...</span>", \
					"<span class = 'notice'>You begin bolting [src]...</span>")
				if(!attacking_object.use_tool(src, user, DEFAULT_STEP_TIME))
					return
				if(locate(/obj/machinery/door/firedoor) in get_turf(src))
					return
				user.visible_message("<span class = 'notice'>[user] finishes the firelock.</span>", \
					"<span class = 'notice'>You finish the firelock.</span>")
				playsound(get_turf(src), 'sound/items/deconstruct.ogg', 50, TRUE)
				if(reinforced)
					new /obj/machinery/door/firedoor/heavy(get_turf(src))
				else
					new /obj/machinery/door/firedoor(get_turf(src))
				qdel(src)
				return
			if(istype(attacking_object, /obj/item/stack/sheet/plasteel))
				var/obj/item/stack/sheet/plasteel/plasteel_sheet = attacking_object
				if(reinforced)
					to_chat(user, "<span class='warning'>[src] is already reinforced.</span>")
					return
				if(plasteel_sheet.get_amount() < 2)
					to_chat(user, "<span class='warning'>You need more plasteel to reinforce [src].</span>")
					return
				user.visible_message("<span class = 'notice'>[user] begins reinforcing [src]...</span>", \
					"<span class = 'notice'>You begin reinforcing [src]...</span>")
				playsound(get_turf(src), 'sound/items/deconstruct.ogg', 50, TRUE)
				if(do_after(user, DEFAULT_STEP_TIME, target = src))
					if(constructionStep != CONSTRUCTION_PANEL_OPEN || reinforced || plasteel_sheet.get_amount() < 2 || !plasteel_sheet)
						return
					user.visible_message("<span class = 'notice'>[user] reinforces [src].</span>", \
						"<span class = 'notice'>You reinforce [src].</span>")
					playsound(get_turf(src), 'sound/items/deconstruct.ogg', 50, TRUE)
					plasteel_sheet.use(2)
					reinforced = 1
				return
		if(CONSTRUCTION_NO_CIRCUIT)
			if(istype(attacking_object, /obj/item/electronics/firelock))
				user.visible_message("<span class = 'notice'>[user] starts adding [attacking_object] to [src]...</span>", \
					"<span class = 'notice'>You begin adding a circuit board to [src]...</span>")
				playsound(get_turf(src), 'sound/items/deconstruct.ogg', 50, TRUE)
				if(!do_after(user, DEFAULT_STEP_TIME, target = src))
					return
				if(constructionStep != CONSTRUCTION_NO_CIRCUIT)
					return
				qdel(attacking_object)
				user.visible_message("<span class = 'notice'>[user] adds a circuit to [src].</span>", \
					"<span class = 'notice'>You insert and secure [attacking_object].</span>")
				playsound(get_turf(src), 'sound/items/deconstruct.ogg', 50, TRUE)
				constructionStep = CONSTRUCTION_PANEL_OPEN
				return
			if(attacking_object.tool_behaviour == TOOL_WELDER)
				if(!attacking_object.tool_start_check(user, amount=1))
					return
				user.visible_message("<span class = 'notice'>[user] begins cutting apart [src]'s frame...</span>", \
					"<span class = 'notice'>You begin slicing [src] apart...</span>")

				if(attacking_object.use_tool(src, user, DEFAULT_STEP_TIME, volume=50))
					if(constructionStep != CONSTRUCTION_NO_CIRCUIT)
						return
					user.visible_message("<span class = 'notice'>[user] cuts apart [src]!</span>", \
						"<span class = 'notice'>You cut [src] into metal.</span>")
					var/turf/tagetloc = get_turf(src)
					new /obj/item/stack/sheet/iron(tagetloc, 3)
					if(reinforced)
						new /obj/item/stack/sheet/plasteel(tagetloc, 2)
					qdel(src)
				return
			if(istype(attacking_object, /obj/item/electroadaptive_pseudocircuit))
				var/obj/item/electroadaptive_pseudocircuit/raspberrypi = attacking_object
				if(!raspberrypi.adapt_circuit(user, circuit_cost = DEFAULT_STEP_TIME * 1.5))
					return
				user.visible_message("<span class = 'notice'>[user] fabricates a circuit and places it into [src].</span>", \
				"<span class = 'notice'>You adapt a firelock circuit and slot it into the assembly.</span>")
				constructionStep = CONSTRUCTION_PANEL_OPEN
				update_icon()
				return
	return ..()

/obj/structure/firelock_frame/rcd_vals(mob/user, obj/item/construction/rcd/the_rcd)
	if(the_rcd.mode == RCD_DECONSTRUCT)
		return list("mode" = RCD_DECONSTRUCT, "delay" = 50, "cost" = 16)
	else if((constructionStep == CONSTRUCTION_NO_CIRCUIT) && (the_rcd.upgrade & RCD_UPGRADE_SIMPLE_CIRCUITS))
		return list("mode" = RCD_UPGRADE_SIMPLE_CIRCUITS, "delay" = 20, "cost" = 1)
	return FALSE

/obj/structure/firelock_frame/rcd_act(mob/user, obj/item/construction/rcd/the_rcd, passed_mode)
	switch(passed_mode)
		if(RCD_UPGRADE_SIMPLE_CIRCUITS)
			user.visible_message("<span class='notice'>[user] fabricates a circuit and places it into [src].</span>", \
			"<span class='notice'>You adapt a firelock circuit and slot it into the assembly.</span>")
			constructionStep = CONSTRUCTION_PANEL_OPEN
			update_icon()
			return TRUE
		if(RCD_DECONSTRUCT)
			to_chat(user, "<span class='notice'>You deconstruct [src].</span>")
			qdel(src)
			return TRUE
	return FALSE

/obj/structure/firelock_frame/heavy
	name = "heavy firelock frame"
	reinforced = TRUE
	firelock_type = /obj/machinery/door/firedoor/heavy

/obj/structure/firelock_frame/border
	name = "firelock frame"
	icon = 'icons/obj/doors/firelocks/edge_Doorfire.dmi'
	icon_state = "door_frame"
	density = FALSE
	firelock_type = /obj/machinery/door/firedoor/border_only

/obj/structure/firelock_frame/border/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/simple_rotation, ROTATION_ALTCLICK | ROTATION_CLOCKWISE | ROTATION_COUNTERCLOCKWISE | ROTATION_VERBS, null, CALLBACK(src, PROC_REF(can_be_rotated)))

/obj/structure/firelock_frame/border/proc/can_be_rotated(mob/user, rotation_type)
	if (anchored)
		to_chat(user, "<span class='warning'>It is fastened to the floor!</span>")
		return FALSE
	return TRUE

/obj/structure/firelock_frame/border/update_icon()
	return

/obj/structure/firelock_frame/window
	name = "window firelock frame"
	icon = 'icons/obj/doors/firelocks/doorfirewindow.dmi'
	icon_state = "door_frame"
	firelock_type = /obj/machinery/door/firedoor/window

/obj/structure/firelock_frame/window/update_icon()
	return

#undef CONSTRUCTION_PANEL_OPEN
#undef CONSTRUCTION_NO_CIRCUIT
#undef DEFAULT_STEP_TIME
#undef REACTIVATION_DELAY
