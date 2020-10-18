//grabber renamed to small grabber by nuclearmayhem
/obj/item/integrated_circuit/manipulation/small_grabber
	name = "small grabber"
	desc = "A circuit with its own inventory for items. Used to grab and store small things."
	icon_state = "small grabber"
	extended_desc = "This circuit accepts a reference to an object to be grabbed, and can store up to 10 objects. Modes: 1 to grab, 0 to eject the first object, -1 to eject all objects, and -2 to eject the target. If you throw something from a grabber's inventory with a thrower, the grabber will update its outputs accordingly."
	w_class = WEIGHT_CLASS_SMALL
	size = 3
	cooldown_per_use = 5
	complexity = 10
	max_allowed = 1
	inputs = list("target" = IC_PINTYPE_REF,"mode" = IC_PINTYPE_NUMBER)
	outputs = list("first" = IC_PINTYPE_REF, "last" = IC_PINTYPE_REF, "amount" = IC_PINTYPE_NUMBER,"contents" = IC_PINTYPE_LIST)
	activators = list("pulse in" = IC_PINTYPE_PULSE_IN,"pulse out" = IC_PINTYPE_PULSE_OUT)
	spawn_flags = IC_SPAWN_RESEARCH
	action_flags = IC_ACTION_COMBAT
	power_draw_per_use = 50
	var/max_items = 10

/obj/item/integrated_circuit/manipulation/small_grabber/do_work()
	//There shouldn't be any target required to eject all contents
	var/mode = get_pin_data(IC_INPUT, 2)
	switch(mode)
		if(-1)
			drop_all()
		if(0)
			if(contents.len)
				drop(contents[1])

	var/obj/item/AM = get_pin_data_as_type(IC_INPUT, 1, /obj/item)
	if(!QDELETED(AM) && !istype(AM, /obj/item/electronic_assembly) && !istype(AM, /obj/item/transfer_valve) && !istype(AM, /obj/item/twohanded) && !istype(assembly.loc, /obj/item/implant/storage))
		switch(mode)
			if(1)
				grab(AM)
			if(-2)
				drop(AM)
	update_outputs()
	activate_pin(2)

/obj/item/integrated_circuit/manipulation/small_grabber/proc/grab(obj/item/AM)
	var/max_w_class = assembly.w_class
	if(check_target(AM))
		if(contents.len < max_items && AM.w_class <= max_w_class)
			var/atom/A = get_object()
			A.investigate_log("picked up ([AM]) with [src].", INVESTIGATE_CIRCUIT)
			AM.forceMove(src)

/obj/item/integrated_circuit/manipulation/small_grabber/proc/drop(obj/item/AM, turf/T = drop_location())
	if(!(AM in contents))
		return
	var/atom/A = get_object()
	A.investigate_log("dropped ([AM]) from [src].", INVESTIGATE_CIRCUIT)
	AM.forceMove(T)

/obj/item/integrated_circuit/manipulation/small_grabber/proc/drop_all()
	if(contents.len)
		var/turf/T = drop_location()
		var/obj/item/U
		for(U in src)
			drop(U, T)

/obj/item/integrated_circuit/manipulation/small_grabber/proc/update_outputs()
	if(contents.len)
		set_pin_data(IC_OUTPUT, 1, WEAKREF(contents[1]))
		set_pin_data(IC_OUTPUT, 2, WEAKREF(contents[contents.len]))
	else
		set_pin_data(IC_OUTPUT, 1, null)
		set_pin_data(IC_OUTPUT, 2, null)
	set_pin_data(IC_OUTPUT, 3, contents.len)
	set_pin_data(IC_OUTPUT, 4, contents)
	push_data()

/obj/item/integrated_circuit/manipulation/small_grabber/attack_self(var/mob/user)
	drop_all()
	update_outputs()
	push_data()

//New normal grabber by nuclearmayhem
/obj/item/integrated_circuit/manipulation/normal_grabber
	name = "normal grabber"
	desc = "A circuit with its own inventory for items. Used to grab and store normal sized things."
	icon_state = "normal grabber"
	extended_desc = "This circuit accepts a reference to an object to be grabbed, and can store up to 5 objects. Modes: 1 to grab, 0 to eject the first object, -1 to eject all objects, and -2 to eject the target. If you throw something from a grabber's inventory with a thrower, the grabber will update its outputs accordingly."
	w_class = WEIGHT_CLASS_NORMAL
	size = 10
	cooldown_per_use = 10
	complexity = 25
	inputs = list("target" = IC_PINTYPE_REF,"mode" = IC_PINTYPE_NUMBER)
	outputs = list("first" = IC_PINTYPE_REF, "last" = IC_PINTYPE_REF, "amount" = IC_PINTYPE_NUMBER,"contents" = IC_PINTYPE_LIST)
	activators = list("pulse in" = IC_PINTYPE_PULSE_IN,"pulse out" = IC_PINTYPE_PULSE_OUT)
	spawn_flags = IC_SPAWN_RESEARCH
	action_flags = IC_ACTION_COMBAT
	power_draw_per_use = 150
	var/max_items = 5

/obj/item/integrated_circuit/manipulation/normal_grabber/do_work()
	//There shouldn't be any target required to eject all contents
	var/mode = get_pin_data(IC_INPUT, 2)
	switch(mode)
		if(-1)
			drop_all()
		if(0)
			if(contents.len)
				drop(contents[1])

	var/obj/item/AM = get_pin_data_as_type(IC_INPUT, 1, /obj/item)
	if(!QDELETED(AM) && !istype(AM, /obj/item/electronic_assembly) && !istype(AM, /obj/item/transfer_valve) && !istype(AM, /obj/item/twohanded) && !istype(assembly.loc, /obj/item/implant/storage))
		switch(mode)
			if(1)
				grab(AM)
			if(-2)
				drop(AM)
	update_outputs()
	activate_pin(2)

/obj/item/integrated_circuit/manipulation/normal_grabber/proc/grab(obj/item/AM)
	var/max_w_class = assembly.w_class
	if(check_target(AM))
		if(contents.len < max_items && AM.w_class <= max_w_class)
			var/atom/A = get_object()
			A.investigate_log("picked up ([AM]) with [src].", INVESTIGATE_CIRCUIT)
			AM.forceMove(src)

/obj/item/integrated_circuit/manipulation/normal_grabber/proc/drop(obj/item/AM, turf/T = drop_location())
	if(!(AM in contents))
		return
	var/atom/A = get_object()
	A.investigate_log("dropped ([AM]) from [src].", INVESTIGATE_CIRCUIT)
	AM.forceMove(T)

/obj/item/integrated_circuit/manipulation/normal_grabber/proc/drop_all()
	if(contents.len)
		var/turf/T = drop_location()
		var/obj/item/U
		for(U in src)
			drop(U, T)

/obj/item/integrated_circuit/manipulation/normal_grabber/proc/update_outputs()
	if(contents.len)
		set_pin_data(IC_OUTPUT, 1, WEAKREF(contents[1]))
		set_pin_data(IC_OUTPUT, 2, WEAKREF(contents[contents.len]))
	else
		set_pin_data(IC_OUTPUT, 1, null)
		set_pin_data(IC_OUTPUT, 2, null)
	set_pin_data(IC_OUTPUT, 3, contents.len)
	set_pin_data(IC_OUTPUT, 4, contents)
	push_data()

/obj/item/integrated_circuit/manipulation/normal_grabber/attack_self(var/mob/user)
	drop_all()
	update_outputs()
	push_data()

//New large grabber by nuclearmayhem
/obj/item/integrated_circuit/manipulation/large_grabber
	name = "large grabber"
	desc = "A circuit with its own inventory for items. Used to grab and store large things."
	icon_state = "large grabber"
	extended_desc = "This circuit accepts a reference to an object to be grabbed, and can store up to 2 objects. Modes: 1 to grab, 0 to eject the first object, -1 to eject all objects, and -2 to eject the target. If you throw something from a grabber's inventory with a thrower, the grabber will update its outputs accordingly."
	w_class = WEIGHT_CLASS_BULKY
	size = 20
	cooldown_per_use = 20
	complexity = 50
	inputs = list("target" = IC_PINTYPE_REF,"mode" = IC_PINTYPE_NUMBER)
	outputs = list("first" = IC_PINTYPE_REF, "last" = IC_PINTYPE_REF, "amount" = IC_PINTYPE_NUMBER,"contents" = IC_PINTYPE_LIST)
	activators = list("pulse in" = IC_PINTYPE_PULSE_IN,"pulse out" = IC_PINTYPE_PULSE_OUT)
	spawn_flags = IC_SPAWN_RESEARCH
	action_flags = IC_ACTION_COMBAT
	power_draw_per_use = 250
	var/max_items = 2

/obj/item/integrated_circuit/manipulation/large_grabber/do_work()
	//There shouldn't be any target required to eject all contents
	var/mode = get_pin_data(IC_INPUT, 2)
	switch(mode)
		if(-1)
			drop_all()
		if(0)
			if(contents.len)
				drop(contents[1])

	var/obj/item/AM = get_pin_data_as_type(IC_INPUT, 1, /obj/item)
	if(!QDELETED(AM) && !istype(AM, /obj/item/electronic_assembly) && !istype(AM, /obj/item/transfer_valve) && !istype(AM, /obj/item/twohanded) && !istype(assembly.loc, /obj/item/implant/storage))
		switch(mode)
			if(1)
				grab(AM)
			if(-2)
				drop(AM)
	update_outputs()
	activate_pin(2)

/obj/item/integrated_circuit/manipulation/large_grabber/proc/grab(obj/item/AM)
	var/max_w_class = assembly.w_class
	if(check_target(AM))
		if(contents.len < max_items && AM.w_class <= max_w_class)
			var/atom/A = get_object()
			A.investigate_log("picked up ([AM]) with [src].", INVESTIGATE_CIRCUIT)
			AM.forceMove(src)

/obj/item/integrated_circuit/manipulation/large_grabber/proc/drop(obj/item/AM, turf/T = drop_location())
	if(!(AM in contents))
		return
	var/atom/A = get_object()
	A.investigate_log("dropped ([AM]) from [src].", INVESTIGATE_CIRCUIT)
	AM.forceMove(T)

/obj/item/integrated_circuit/manipulation/large_grabber/proc/drop_all()
	if(contents.len)
		var/turf/T = drop_location()
		var/obj/item/U
		for(U in src)
			drop(U, T)

/obj/item/integrated_circuit/manipulation/large_grabber/proc/update_outputs()
	if(contents.len)
		set_pin_data(IC_OUTPUT, 1, WEAKREF(contents[1]))
		set_pin_data(IC_OUTPUT, 2, WEAKREF(contents[contents.len]))
	else
		set_pin_data(IC_OUTPUT, 1, null)
		set_pin_data(IC_OUTPUT, 2, null)
	set_pin_data(IC_OUTPUT, 3, contents.len)
	set_pin_data(IC_OUTPUT, 4, contents)
	push_data()

/obj/item/integrated_circuit/manipulation/large_grabber/attack_self(var/mob/user)
	drop_all()
	update_outputs()
	push_data()

/obj/item/integrated_circuit/manipulation/thrower
	name = "thrower"
	desc = "A compact launcher to throw things from inside or nearby tiles."
	extended_desc = "The first and second inputs need to be numbers which correspond to coordinates to throw objects at relative to the machine itself. \
	The 'fire' activator will cause the mechanism to attempt to throw objects at the coordinates, if possible. Note that the \
	projectile need to be inside the machine, or to be on an adjacent tile, and must be medium sized or smaller."
	icon_state = "small grabber"
	complexity = 15
	w_class = WEIGHT_CLASS_SMALL
	size = 2
	cooldown_per_use = 10
	ext_cooldown = 1
	inputs = list(
		"target X rel" = IC_PINTYPE_NUMBER,
		"target Y rel" = IC_PINTYPE_NUMBER,
		"projectile" = IC_PINTYPE_REF
		)
	outputs = list()
	activators = list(
		"fire" = IC_PINTYPE_PULSE_IN
	)
	spawn_flags = IC_SPAWN_RESEARCH
	action_flags = IC_ACTION_COMBAT
	power_draw_per_use = 50

/obj/item/integrated_circuit/manipulation/thrower/do_work()
	var/max_w_class = assembly.w_class
	var/target_x_rel = round(get_pin_data(IC_INPUT, 1))
	var/target_y_rel = round(get_pin_data(IC_INPUT, 2))
	var/obj/item/A = get_pin_data_as_type(IC_INPUT, 3, /obj/item)

	if(!A || A.anchored || A.throwing)
		return

	if(max_w_class && (A.w_class > max_w_class))
		return

	// Is the target inside the assembly or close to it?
	if(!check_target(A, exclude_components = TRUE))
		return

	var/turf/T = get_turf(get_object())
	if(!T)
		return

	// If the item is in mob's inventory, try to remove it from there.
	if(ismob(A.loc))
		var/mob/living/M = A.loc
		if(!M.temporarilyRemoveItemFromInventory(A))
			return

	var/x_abs = CLAMP(T.x + target_x_rel, 0, world.maxx)
	var/y_abs = CLAMP(T.y + target_y_rel, 0, world.maxy)
	var/range = round(CLAMP(sqrt(target_x_rel*target_x_rel+target_y_rel*target_y_rel),0,8),1)

	A.forceMove(drop_location())
	A.throw_at(locate(x_abs, y_abs, T.z), range, 3)