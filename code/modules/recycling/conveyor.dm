/// Maximum amount of items a conveyor can move at once.
#define MAX_CONVEYOR_ITEMS_MOVE 30
/// Conveyor is currently off.
#define CONVEYOR_OFF 0
/// Conveyor is currently configured to move items forward.
#define CONVEYOR_FORWARD 1
/// Conveyor is currently configured to move items backwards.
#define CONVEYOR_BACKWARDS -1
/// Conveyor default delay for convey movement
#define CONVEYOR_DELAY 0.2 SECONDS

GLOBAL_LIST_EMPTY(conveyors_by_id)

/obj/machinery/conveyor
	icon = 'icons/obj/recycling.dmi'
	icon_state = "conveyor_map"
	base_icon_state = "conveyor"
	name = "conveyor belt"
	desc = "A conveyor belt."
	layer = BELOW_OPEN_DOOR_LAYER
	processing_flags = NONE
	/// The current state of the switch.
	var/operating = CONVEYOR_OFF
	/// This is the default (forward) direction, set by the map dir.
	var/forwards
	/// The opposite of forwards. It's set in a special var for corner belts, which aren't using the opposite direction when in reverse.
	var/backwards
	/// The actual direction to move stuff in.
	var/movedir
	/// The time between movements of the conveyor belts, default 0.2 seconds
	var/delay = CONVEYOR_DELAY
	/// The control ID - must match at least one conveyor switch's ID to be useful.
	var/id = ""
	/// Inverts the direction the conveyor belt moves when true.
	var/inverted = FALSE
	/// Is the conveyor's belt flipped? Useful mostly for conveyor belt corners. It makes the belt point in the other direction, rather than just going in reverse.
	var/flipped = FALSE
	/// Are we currently conveying items?
	var/conveying = FALSE
	//Direction -> if we have a conveyor belt in that direction
	var/list/neighbors

/obj/machinery/conveyor/examine(mob/user)
	. = ..()
	if(inverted)
		. += "<span class='notice'>It is currently set to go in reverse."
	. += "\nLeft-click with a <b>wrench</b> to rotate."
	. += "Left-click with a <b>screwdriver</b> to invert its direction."
	. += "Right-click with a <b>screwdriver</b> to flip its belt around."

/obj/machinery/conveyor/centcom_auto
	id = "round_end_belt"

/obj/machinery/conveyor/inverted //Directions inverted so you can use different corner pieces.
	icon_state = "conveyor_map_inverted"
	flipped = TRUE

/obj/machinery/conveyor/inverted/Initialize(mapload)
	. = ..()
	if(mapload && !(dir in GLOB.diagonals))
		log_mapping("[src] at [AREACOORD(src)] spawned without using a diagonal dir. Please replace with a normal version.")


// Auto conveyor is always on unless unpowered
/obj/machinery/conveyor/auto/Initialize(mapload, newdir)
	. = ..()
	set_operating(TRUE)
	update_icon()
	begin_processing()

/obj/machinery/conveyor/auto/update()
	. = ..()
	if(.)
		set_operating(TRUE)

// create a conveyor
/obj/machinery/conveyor/Initialize(mapload, new_dir, new_id)
	. = ..()
	if(new_dir)
		setDir(new_dir)
	if(new_id)
		id = new_id
	neighbors = list()
	///Leaving onto conveyor detection won't work at this point, but that's alright since it's an optimization anyway
	///Should be fine without it
	var/static/list/loc_connections = list(
		COMSIG_ATOM_EXITED = PROC_REF(conveyable_exit),
		COMSIG_ATOM_ENTERED = PROC_REF(conveyable_enter),
		COMSIG_ATOM_CREATED = PROC_REF(conveyable_enter)
	)
	AddElement(/datum/element/connect_loc, loc_connections)
	update_move_direction()
	LAZYADD(GLOB.conveyors_by_id[id], src)
	update_icon()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/conveyor/LateInitialize()
	. = ..()
	build_neighbors()

/obj/machinery/conveyor/Destroy()
	set_operating(FALSE)
	LAZYREMOVE(GLOB.conveyors_by_id[id], src)
	return ..()

/obj/machinery/conveyor/vv_edit_var(var_name, var_value)
	if (var_name == NAMEOF(src, id))
		// if "id" is varedited, update our list membership
		LAZYREMOVE(GLOB.conveyors_by_id[id], src)
		. = ..()
		LAZYADD(GLOB.conveyors_by_id[id], src)
	else
		return ..()

/obj/machinery/conveyor/setDir(newdir)
	. = ..()
	update_move_direction()

/obj/machinery/conveyor/Moved(atom/OldLoc, Dir)
	. = ..()
	if(!.)
		return
	//Now that we've moved, rebuild our neighbors list
	neighbors = list()
	build_neighbors()

/obj/machinery/conveyor/proc/build_neighbors()
	//This is acceptable because conveyor belts only move sometimes. Otherwise would be n^2 insanity
	var/turf/our_turf = get_turf(src)
	for(var/direction in GLOB.cardinals)
		var/turf/new_turf = get_step(our_turf, direction)
		var/obj/machinery/conveyor/valid = locate(/obj/machinery/conveyor) in new_turf
		if(QDELETED(valid))
			continue
		neighbors["[direction]"] = TRUE
		valid.neighbors["[DIRFLIP(direction)]"] = TRUE
		RegisterSignal(valid, COMSIG_MOVABLE_MOVED, PROC_REF(nearby_belt_changed), override=TRUE)
		RegisterSignal(valid, COMSIG_PARENT_QDELETING, PROC_REF(nearby_belt_changed), override=TRUE)
		valid.RegisterSignal(src, COMSIG_MOVABLE_MOVED, PROC_REF(nearby_belt_changed), override=TRUE)
		valid.RegisterSignal(src, COMSIG_PARENT_QDELETING, PROC_REF(nearby_belt_changed), override=TRUE)

/obj/machinery/conveyor/proc/nearby_belt_changed(datum/source)
	SIGNAL_HANDLER
	neighbors = list()
	build_neighbors()

/**
 * Proc to handle updating the directions in which the conveyor belt is moving items.
 */
/obj/machinery/conveyor/proc/update_move_direction()
	switch(dir)
		if(NORTH)
			forwards = NORTH
			backwards = SOUTH
		if(SOUTH)
			forwards = SOUTH
			backwards = NORTH
		if(EAST)
			forwards = EAST
			backwards = WEST
		if(WEST)
			forwards = WEST
			backwards = EAST
		if(NORTHEAST)
			forwards = EAST
			backwards = SOUTH
		if(NORTHWEST)
			forwards = NORTH
			backwards = EAST
		if(SOUTHEAST)
			forwards = SOUTH
			backwards = WEST
		if(SOUTHWEST)
			forwards = WEST
			backwards = NORTH

	if(inverted)
		var/temp = forwards
		forwards = backwards
		backwards = temp
	// We need to do this this way to ensure good functionality on corner belts.
	// Basically, this allows the conveyor belts that used a flipped belt sprite to
	// still convey items in the direction of their arrows. It's different from inverted,
	// which makes them go backwards so they need to be ran separately, so a flipped conveyor
	// can also be reversed.
	if(flipped)
		var/temp = forwards
		forwards = backwards
		backwards = temp
	if(operating == CONVEYOR_FORWARD)
		movedir = forwards
	else
		movedir = backwards
	update()

/obj/machinery/conveyor/update_icon_state()
	icon_state = "[base_icon_state][inverted ? -operating : operating ][flipped ? "-flipped" : ""]"
	return ..()

/obj/machinery/conveyor/proc/set_operating(new_value)
	if(operating == new_value)
		return
	operating = new_value
	update_icon()
	update_move_direction()
	//If we ever turn off, disable moveloops
	if(operating == CONVEYOR_OFF)
		for(var/atom/movable/movable in get_turf(src))
			stop_conveying(movable)

/**
 * Proc to update the conveyor depending on if it's got power or not.
 *
 * Returns TRUE if it is still able to be operating after the update, FALSE if not.
 */
/obj/machinery/conveyor/proc/update()
	if(machine_stat & NOPOWER)
		set_operating(FALSE)
		return FALSE

	// If we're on, start conveying so moveloops on our tile can be refreshed if they stopped for some reason
	if(operating != CONVEYOR_OFF)
		for(var/atom/movable/movable in get_turf(src))
			start_conveying(movable)
	return TRUE

/obj/machinery/conveyor/proc/conveyable_enter(datum/source, atom/convayable)
	SIGNAL_HANDLER
	if(operating == CONVEYOR_OFF)
		SSmove_manager.stop_looping(convayable, SSconveyors)
		return
	start_conveying(convayable)

/obj/machinery/conveyor/proc/conveyable_exit(datum/source, atom/convayable, direction)
	SIGNAL_HANDLER
	var/has_conveyor = neighbors["[direction]"]
	if(!has_conveyor || !isturf(convayable.loc)) //If you've entered something on us, stop moving
		SSmove_manager.stop_looping(convayable, SSconveyors)

/obj/machinery/conveyor/proc/start_conveying(atom/movable/moving)
	var/datum/move_loop/move/moving_loop = SSmove_manager.processing_on(moving, SSconveyors)
	if(moving_loop)
		moving_loop.direction = movedir
		moving_loop.delay = delay * 1 SECONDS
		return

	var/static/list/unconveyables = typecacheof(list(/obj/effect, /mob/dead))
	if(!istype(moving) || is_type_in_typecache(moving, unconveyables) || moving == src)
		return
	moving.AddComponent(/datum/component/convey, movedir, delay * 1 SECONDS)

/obj/machinery/conveyor/proc/stop_conveying(atom/movable/thing)
	if(!ismovable(thing))
		return
	SSmove_manager.stop_looping(thing, SSconveyors)

// attack with item, place item on conveyor
/obj/machinery/conveyor/attackby(obj/item/attacking_item, mob/living/user, params)
	if(attacking_item.tool_behaviour == TOOL_CROWBAR)
		user.visible_message(
							"<span class='notice'>[user] struggles to pry up [src] with [attacking_item].</span>", \
							"<span class='notice'>You struggle to pry up [src] with [attacking_item].</span>"
							)

		if(!attacking_item.use_tool(src, user, 4 SECONDS, volume = 40))
			return
		set_operating(FALSE)
		var/obj/item/stack/conveyor/belt_item = new /obj/item/stack/conveyor(loc, 1, TRUE, null, null, id)
		if(!QDELETED(belt_item)) //God I hate stacks
			transfer_fingerprints_to(belt_item)

		to_chat(user, "<span class='notice'>You remove [src].</span>")
		qdel(src)

	else if(attacking_item.tool_behaviour == TOOL_WRENCH)
		attacking_item.play_tool_sound(src)
		setDir(turn(dir, -45))
		to_chat(user, "<span class='notice'>You rotate [src].</span>")

	else if(attacking_item.tool_behaviour == TOOL_SCREWDRIVER)
		attacking_item.play_tool_sound(src)
		inverted = !inverted
		update_move_direction()
		to_chat(user, "<span class='notice'>You set [src]'s direction [inverted ? "backwards" : "back to default"].</span>")
		update_icon()

	else if(attacking_item.tool_behaviour == TOOL_MULTITOOL)
		attacking_item.play_tool_sound(src)
		flipped = !flipped
		update_move_direction()
		to_chat(user, "<span class='notice'>You flip [src]'s belt [flipped ? "around" : "back to normal"].</span>")
		update_icon()

	else if(user.a_intent != INTENT_HARM)
		user.transferItemToLoc(attacking_item, drop_location())
	else
		return ..()

/obj/machinery/conveyor/multitool_act(mob/living/user, obj/item/multitool/tool)
	if(!multitool_check_buffer(user, tool)) //make sure it has a data buffer
		return TRUE
	var/obj/machinery/conveyor_switch/cswitch = tool.buffer
	if(!cswitch || !istype(cswitch))
		return TRUE

	// Set up the conveyor with our new ID
	LAZYREMOVE(GLOB.conveyors_by_id[id], src)
	id = cswitch.id
	LAZYADD(GLOB.conveyors_by_id[id], src)
	to_chat(user, "<span class='notice'>You link [src] to [cswitch].</span>")
	return TRUE

// attack with hand, move pulled object onto conveyor
/obj/machinery/conveyor/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	user.Move_Pulled(src)

/obj/machinery/conveyor/power_change()
	. = ..()
	update()

// Conveyor Switch
/obj/machinery/conveyor_switch
	name = "conveyor switch"
	desc = "A conveyor control switch."
	icon = 'icons/obj/recycling.dmi'
	icon_state = "switch-off"
	base_icon_state = "switch"
	processing_flags = START_PROCESSING_MANUALLY

	/// The current state of the switch.
	var/position = CONVEYOR_OFF
	/// Last direction setting.
	var/last_pos = CONVEYOR_BACKWARDS
	/// If the switch only operates the conveyor belts in a single direction.
	var/oneway = FALSE
	/// If the level points the opposite direction when it's turned on.
	var/invert_icon = FALSE
	/// The ID of the switch, must match conveyor IDs to control them.
	var/id = ""
	/// The set time between movements of the conveyor belts
	var/conveyor_delay = CONVEYOR_DELAY

/obj/machinery/conveyor_switch/Initialize(mapload, newid)
	. = ..()
	if (newid)
		id = newid

	update_icon()
	LAZYADD(GLOB.conveyors_by_id[id], src)
	wires = new /datum/wires/conveyor(src)

/obj/machinery/conveyor_switch/Destroy()
	LAZYREMOVE(GLOB.conveyors_by_id[id], src)
	QDEL_NULL(wires)
	. = ..()

/obj/machinery/conveyor_switch/vv_edit_var(var_name, var_value)
	if (var_name == NAMEOF(src, id))
		// if "id" is varedited, update our list membership
		LAZYREMOVE(GLOB.conveyors_by_id[id], src)
		. = ..()
		LAZYADD(GLOB.conveyors_by_id[id], src)

	else
		return ..()

// update the icon depending on the position
/obj/machinery/conveyor_switch/update_icon_state()
	icon_state = "[base_icon_state]-off"
	if(position < CONVEYOR_OFF)
		icon_state = "[base_icon_state]-[invert_icon ? "fwd" : "rev"]"
	else if(position > CONVEYOR_OFF)
		icon_state = "[base_icon_state]-[invert_icon ? "rev" : "fwd"]"
	return ..()

/// Updates all conveyor belts that are linked to this switch, and tells them to start processing.
/obj/machinery/conveyor_switch/proc/update_linked_conveyors()
	for(var/obj/machinery/conveyor/belt in GLOB.conveyors_by_id[id])
		belt.set_operating(position)
		belt.delay = conveyor_delay
		CHECK_TICK

/// Finds any switches with same `id` as this one, and set their position and icon to match us.
/obj/machinery/conveyor_switch/proc/update_linked_switches()
	for(var/obj/machinery/conveyor_switch/belt_switch in GLOB.conveyors_by_id[id])
		belt_switch.invert_icon = invert_icon
		belt_switch.position = position
		belt_switch.conveyor_delay = conveyor_delay
		belt_switch.update_icon()
		CHECK_TICK

/// Updates the switch's `position` and `last_pos` variable. Useful so that the switch can properly cycle between the forwards, backwards and neutral positions.
/obj/machinery/conveyor_switch/proc/update_position()
	if(position == CONVEYOR_OFF)
		if(oneway)   //is it a oneway switch
			position = oneway
		else
			if(last_pos < CONVEYOR_OFF)
				position = CONVEYOR_FORWARD
				last_pos = CONVEYOR_OFF
			else
				position = CONVEYOR_BACKWARDS
				last_pos = CONVEYOR_OFF
	else
		last_pos = position
		position = CONVEYOR_OFF

/// Called when a user clicks on this switch with an open hand.
/obj/machinery/conveyor_switch/interact(mob/user)
	add_fingerprint(user)
	play_click_sound("switch")
	update_position()
	update_icon()
	update_linked_conveyors()
	update_linked_switches()


/obj/machinery/conveyor_switch/attackby(obj/item/attacking_item, mob/user, params)
	if(is_wire_tool(attacking_item))
		wires.interact(user)
		return TRUE

/obj/machinery/conveyor_switch/multitool_act(mob/living/user, obj/item/I)
	var/input_speed = input(user, "Set the speed of the conveyor belts in seconds", "Speed", conveyor_delay) as null|num
	if(!input_speed || QDELETED(user) || QDELETED(src) || !usr.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
		return
	if(input_speed < 0.2 || input_speed > 20)
		to_chat(user, "<span class='warning'>Input speed is out of range of conveyor limitations. Must be between 0.1 and 20.</span>")
		return
	conveyor_delay = input_speed
	to_chat(user, "<span class='notice'>You change the time between moves to [input_speed] seconds.</span>")
	update_linked_conveyors()
	return TRUE

/obj/machinery/conveyor_switch/crowbar_act(mob/user, obj/item/tool)
	tool.play_tool_sound(src, 50)
	var/obj/item/conveyor_switch_construct/switch_construct = new/obj/item/conveyor_switch_construct(src.loc)
	switch_construct.id = id
	transfer_fingerprints_to(switch_construct)
	to_chat(user, "<span class='notice'>You detach [src].</span>")
	qdel(src)
	return TRUE

/obj/machinery/conveyor_switch/screwdriver_act(mob/user, obj/item/tool)
	tool.play_tool_sound(src, 50)
	oneway = !oneway
	to_chat(user, "<span class='notice'>You set [src] to [oneway ? "one way" : "default"] configuration.</span>")
	return TRUE

/obj/machinery/conveyor_switch/wrench_act(mob/user, obj/item/tool)
	tool.play_tool_sound(src, 50)
	invert_icon = !invert_icon
	update_icon()
	to_chat(user, "<span class='notice'>You set [src] to [invert_icon ? "inverted": "normal"] position.</span>")
	return TRUE

/obj/machinery/conveyor_switch/examine(mob/user)
	. = ..()
	. += "<span class='notice'>[src] is set to [oneway ? "one way" : "default"] configuration. It can be changed with a <b>screwdriver</b>.</span>"
	. += "<span class='notice'>[src] is set to [invert_icon ? "inverted": "normal"] position. It can be rotated with a <b>wrench</b>.</span>"
	. += "<span class='notice'>[src] is set to move [conveyor_delay] seconds per belt. It can be changed with a <b>multitool</b>.</span>"

/obj/machinery/conveyor_switch/oneway
	icon_state = "conveyor_switch_oneway"
	desc = "A conveyor control switch. It appears to only go in one direction."
	oneway = TRUE

/obj/machinery/conveyor_switch/oneway/Initialize(mapload)
	. = ..()
	if((dir == NORTH) || (dir == WEST))
		invert_icon = TRUE

/obj/item/conveyor_switch_construct
	name = "conveyor switch assembly"
	desc = "A conveyor control switch assembly."
	icon = 'icons/obj/recycling.dmi'
	icon_state = "switch-off"
	w_class = WEIGHT_CLASS_BULKY
	// ID of the switch-in-the-making, to link conveyor belts to it.
	var/id = ""

/obj/item/conveyor_switch_construct/Initialize(mapload)
	. = ..()
	id = "[rand()]" //this couldn't possibly go wrong

/obj/item/conveyor_switch_construct/attack_self(mob/user)
	for(var/obj/item/stack/conveyor/belt in view())
		belt.id = id
	to_chat(user, "<span class='notice'>You have linked all nearby conveyor belt assemblies to this switch.</span>")

/obj/item/conveyor_switch_construct/afterattack(atom/target, mob/user, proximity)
	. = ..()
	if(!proximity || user.stat || !isfloorturf(target) || istype(target, /area/shuttle))
		return

	var/found = FALSE
	for(var/obj/machinery/conveyor/belt in view())
		if(belt.id == src.id)
			found = TRUE
			break
	if(!found)
		to_chat(user, "[icon2html(src, user)]" + "<span class='notice'>The conveyor switch did not detect any linked conveyor belts in range.</span>")
		return
	var/obj/machinery/conveyor_switch/built_switch = new/obj/machinery/conveyor_switch(target, id)
	transfer_fingerprints_to(built_switch)
	qdel(src)

/obj/item/stack/conveyor
	name = "conveyor belt assembly"
	desc = "A conveyor belt assembly."
	icon = 'icons/obj/recycling.dmi'
	icon_state = "conveyor_construct"
	max_amount = 30
	singular_name = "conveyor belt"
	w_class = WEIGHT_CLASS_BULKY
	merge_type = /obj/item/stack/conveyor
	/// ID for linking a belt to one or more switches, all conveyors with the same ID will be controlled the same switch(es).
	var/id = ""


/obj/item/stack/conveyor/Initialize(mapload, new_amount, merge = TRUE, list/mat_override=null, mat_amt=1, _id)
	. = ..()
	id = _id

/obj/item/stack/conveyor/afterattack(atom/target, mob/user, proximity)
	. = ..()
	if(!proximity || user.stat || !isfloorturf(target) || istype(target, /area/shuttle))
		return
	var/belt_dir = get_dir(target, user)
	if(target == user.loc)
		to_chat(user, "<span class='warning'>You cannot place a conveyor belt under yourself!</span>")
		return
	var/obj/machinery/conveyor/belt = new/obj/machinery/conveyor(target, belt_dir, id)
	transfer_fingerprints_to(belt)
	use(1)

/obj/item/stack/conveyor/attackby(obj/item/item_used, mob/user, params)
	..()
	if(istype(item_used, /obj/item/conveyor_switch_construct))
		to_chat(user, "<span class='notice'>You link the switch to the conveyor belt assembly.</span>")
		var/obj/item/conveyor_switch_construct/switch_construct = item_used
		id = switch_construct.id

/obj/item/stack/conveyor/update_weight()
	return FALSE

/obj/item/stack/conveyor/thirty
	amount = 30

/obj/item/paper/guides/conveyor
	name = "paper- 'Nano-it-up U-build series, #9: Build your very own conveyor belt, in SPACE'"
	info = "<h1>Congratulations!</h1><p>You are now the proud owner of the best conveyor set available for space mail order! We at Nano-it-up know you love to prepare your own structures without wasting time, so we have devised a special streamlined assembly procedure that puts all other mail-order products to shame!</p><p>Firstly, you need to link the conveyor switch assembly to each of the conveyor belt assemblies. After doing so, you simply need to install the belt assemblies onto the floor, et voila, belt built. Our special Nano-it-up smart switch will detected any linked assemblies as far as the eye can see! This convenience, you can only have it when you Nano-it-up. Stay nano!</p>"

#undef CONVEYOR_DELAY
#undef CONVEYOR_BACKWARDS
#undef CONVEYOR_OFF
#undef CONVEYOR_FORWARD
