#define MAXIMUM_EMP_WIRES 3

/proc/is_wire_tool(obj/item/I)
	if(!I)
		return

	if(I.tool_behaviour == TOOL_WIRECUTTER || I.tool_behaviour == TOOL_MULTITOOL)
		return TRUE
	if(istype(I, /obj/item/assembly))
		var/obj/item/assembly/A = I
		if(A.attachable)
			return TRUE

/atom/var/datum/wires/wires = null

/atom/proc/attempt_wire_interaction(mob/user)
	if(isnull(wires))
		return WIRE_INTERACTION_FAIL
	if(!user.CanReach(src))
		return WIRE_INTERACTION_FAIL
	wires.interact(user)
	return WIRE_INTERACTION_BLOCK

/datum/wires
	/// The holder (atom that contains these wires).
	var/atom/holder = null
	/// The holder's typepath (used for sanity checks to make sure the holder is the appropriate type for these wire sets).
	var/holder_type = null
	/// The display name for the wire set shown in station blueprints. Not shown in blueprints if randomize is TRUE or it's an item NT wouldn't know about (Explosives/Nuke). Also used in the hacking interface.
	var/proper_name = "Unknown"

	/// List of all wires.
	var/list/wires
	/// List of cut wires.
	var/list/cut_wires
	/// Dictionary of colours to wire.
	var/list/colors
	/// List of attached assemblies.
	var/list/assemblies
	/// Associative List of wires that have labels. Key = wire, Value = Bool (Revealed) [To be refactored into skills]
	var/list/labelled_wires

	/// If every instance of these wires should be random. Prevents wires from showing up in station blueprints.
	var/randomize = FALSE

/datum/wires/New(atom/holder)
	..()
	if(!istype(holder, holder_type))
		CRASH("Wire holder is not of the expected type!")

	src.holder = holder
	if(randomize)
		randomize()
	else
		if(!GLOB.wire_color_directory[holder_type])
			randomize()
			GLOB.wire_color_directory[holder_type] = colors
			GLOB.wire_name_directory[holder_type] = proper_name
		else
			colors = GLOB.wire_color_directory[holder_type]

/datum/wires/Destroy()
	holder = null
	//properly clear refs to avoid harddels & other problems
	for(var/color in assemblies)
		var/obj/item/assembly/assembly = LAZYACCESS(assemblies, color)
		assembly.holder = null
		assembly.connected = null
	LAZYNULL(assemblies)
	return ..()

/datum/wires/proc/add_duds(duds)
	while(duds)
		var/dud = WIRE_DUD_PREFIX + "[--duds]"
		if(dud in wires)
			continue
		LAZYADD(wires, dud)

/datum/wires/proc/randomize()
	var/static/list/possible_colors
	possible_colors ||= list(
		"blue",
		"brown",
		"crimson",
		"cyan",
		"gold",
		"grey",
		"green",
		"magenta",
		"orange",
		"pink",
		"purple",
		"red",
		"silver",
		"violet",
		"white",
		"yellow"
	)

	var/list/my_possible_colors = possible_colors.Copy()

	for(var/wire in shuffle(wires))
		if(!length(my_possible_colors))
			my_possible_colors = possible_colors.Copy()
		LAZYSET(colors, pick_n_take(my_possible_colors), wire)

/datum/wires/proc/shuffle_wires()
	LAZYCLEARLIST(colors)
	randomize()
	ui_update()

/datum/wires/proc/repair()
	cut_wires.Cut()
	ui_update()

/datum/wires/proc/get_wire(color)
	return LAZYACCESS(colors, color)

/datum/wires/proc/get_color_of_wire(wire_type)
	for(var/color, other_type in colors)
		if(wire_type == other_type)
			return color

/datum/wires/proc/get_attached(color)
	if(LAZYACCESS(assemblies, color))
		return LAZYACCESS(assemblies, color)
	return null

/datum/wires/proc/is_attached(color)
	if(LAZYACCESS(assemblies, color))
		return TRUE

/datum/wires/proc/is_cut(wire)
	return (wire in cut_wires)

/datum/wires/proc/is_color_cut(color)
	return is_cut(get_wire(color))

/datum/wires/proc/is_all_cut()
	if(LAZYLEN(cut_wires) == LAZYLEN(wires))
		return TRUE

/datum/wires/proc/is_dud(wire)
	return findtext(wire, WIRE_DUD_PREFIX, 1, length(WIRE_DUD_PREFIX) + 1)

/datum/wires/proc/is_dud_color(color)
	return is_dud(get_wire(color))

/// Cut a specific wire.
/// User may be null
/datum/wires/proc/cut(wire, mob/user_or_null)
	if(is_cut(wire))
		LAZYREMOVE(cut_wires, wire)
		on_cut(wire, user_or_null, mend = TRUE)
	else
		LAZYADD(cut_wires, wire)
		on_cut(wire, user_or_null, mend = FALSE)
	ui_update()

/datum/wires/proc/cut_color(color, mob/user_or_null)
	cut(get_wire(color), user_or_null)
	ui_update()

/datum/wires/proc/cut_random(mob/user_or_null)
	cut(LAZYACCESS(wires, rand(1, LAZYLEN(wires))), user_or_null)
	ui_update()

/datum/wires/proc/cut_all(mob/user_or_null)
	for(var/wire in wires)
		cut(wire, user_or_null)
	ui_update()

/datum/wires/proc/pulse(wire, user)
	if(is_cut(wire))
		return
	on_pulse(wire, user)
	ui_update()

/datum/wires/proc/pulse_color(color, mob/living/user)
	pulse(get_wire(color), user)
	ui_update()

/datum/wires/proc/pulse_assembly(obj/item/assembly/assembly)
	for(var/color, our_assembly in assemblies)
		if(assembly == our_assembly)
			pulse_color(color)
			ui_update()
			return TRUE

/datum/wires/proc/attach_assembly(color, obj/item/assembly/assembly)
	if(istype(assembly) && assembly.attachable && !is_attached(color))
		LAZYSET(assemblies, color, assembly)
		assembly.forceMove(holder)
		/**
		 * special snowflake check for machines
		 * someone attached a signaler to the machines wires
		 * move it to the machines component parts so it doesn't get moved out in dump_inventory_contents() which gets called a lot
		 */
		if(ismachinery(holder))
			var/obj/machinery/machine = holder
			LAZYADD(machine.component_parts, assembly)
		assembly.connected = src
		assembly.on_attach() // Notify assembly that it is attached
		ui_update()
		return assembly

/datum/wires/proc/detach_assembly(color)
	var/obj/item/assembly/assembly = get_attached(color)
	if(istype(assembly))
		LAZYREMOVE(assemblies, color)
		assembly.on_detach() // Notify the assembly. This should remove the reference to our holder
		ui_update()
		return assembly

/datum/wires/proc/emp_pulse()
	var/list/possible_wires = shuffle(wires)
	var/remaining_pulses = MAXIMUM_EMP_WIRES

	for(var/wire in possible_wires)
		if(prob(33))
			pulse(wire)
			remaining_pulses--
			if(!remaining_pulses)
				break
	ui_update()

// Overridable Procs
/datum/wires/proc/interactable(mob/user)
	SHOULD_CALL_PARENT(TRUE)
	if((SEND_SIGNAL(user, COMSIG_TRY_WIRES_INTERACT, holder) & COMPONENT_CANT_INTERACT_WIRES))
		return FALSE
	return TRUE

/datum/wires/proc/get_status()
	return list()

/// Called when a wire is asked to be cut
/// User accepts null
/datum/wires/proc/on_cut(wire, mob/user, mend = FALSE)
	return

/datum/wires/proc/on_pulse(wire, user)
	return
// End Overridable Procs

/datum/wires/proc/interact(mob/user)
	if(!interactable(user))
		return FALSE
	ui_interact(user)
	for(var/color, assembly in assemblies)
		var/obj/item/assembly_item = assembly
		if(istype(assembly_item) && assembly_item.on_found(user))
			break
	return TRUE

/**
 * Checks whether wire assignments should be revealed.
 *
 * Returns TRUE if the wires should be revealed, FALSE otherwise.
 * Currently checks for admin ghost AI, abductor multitool and blueprints.
 * Arguments:
 * * user - The mob to check when deciding whether to reveal wires.
 */
/datum/wires/proc/can_reveal_wires(mob/user)
	// Admin ghost can see a purpose of each wire.
	if(IsAdminGhost(user))
		return TRUE

	// Same for anyone with an abductor multitool.
	if(user.is_holding_item_of_type(/obj/item/multitool/abductor))
		return TRUE

	// Station blueprints do that too, but only if the wires are not randomized.
	if(user.is_holding_item_of_type(/obj/item/areaeditor/blueprints) && !randomize)
		return TRUE

	return FALSE

/datum/wires/ui_host()
	return holder

/datum/wires/ui_status(mob/user)
	if(interactable(user))
		return ..()
	return UI_CLOSE

/datum/wires/ui_state(mob/user)
	return GLOB.physical_state

/datum/wires/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "Wires", "[holder.name] Wires")
		ui.open()

/datum/wires/ui_data(mob/user)
	var/list/data = list()
	var/list/payload = list()
	var/reveal_wires = FALSE

	// Admin ghost can see a purpose of each wire.
	if(IsAdminGhost(user))
		reveal_wires = TRUE

	// Same for anyone with an abductor multitool.
	else if(user.is_holding_item_of_type(/obj/item/multitool/abductor))
		reveal_wires = TRUE

	// Station blueprints do that too, but only if the wires are not randomized.
	else if(user.is_holding_item_of_type(/obj/item/areaeditor/blueprints) && (!randomize || holder_type == /obj/machinery/door/airlock))
		reveal_wires = TRUE

	for(var/color in colors)
		var/wire_type = get_wire(color)
		payload.Add(list(list(
			"color" = color,
			"wire" = (((reveal_wires || LAZYACCESS(labelled_wires, wire_type)) && !is_dud_color(color)) ? wire_type : null),
			"cut" = is_color_cut(color),
			"attached" = is_attached(color)
		)))
	data["wires"] = payload
	data["status"] = get_status()
	return data

/datum/wires/ui_act(action, params)
	if(..() || !interactable(usr))
		return
	var/target_wire = params["wire"]
	var/mob/living/L = usr
	var/obj/item/I
	switch(action)
		if("cut")
			I = L.is_holding_tool_quality(TOOL_WIRECUTTER)
			if(I || IsAdminGhost(usr))
				if(I && holder)
					I.play_tool_sound(holder, 20)
				cut_color(target_wire, usr)
				. = TRUE
			else
				to_chat(L, span_warning("You need wirecutters!"))
		if("pulse")
			I = L.is_holding_tool_quality(TOOL_MULTITOOL)
			if(I || IsAdminGhost(usr))
				if(I && holder)
					I.play_tool_sound(holder, 20)
				pulse_color(target_wire, L)
				. = TRUE
			else
				to_chat(L, span_warning("You need a multitool!"))
		if("attach")
			if(is_attached(target_wire))
				I = detach_assembly(target_wire)
				if(I)
					L.put_in_hands(I)
					. = TRUE
			else
				I = L.get_active_held_item()
				if(istype(I, /obj/item/assembly))
					var/obj/item/assembly/A = I
					if(A.attachable)
						if(!L.temporarilyRemoveItemFromInventory(A))
							return
						if(!attach_assembly(target_wire, A))
							A.forceMove(L.drop_location())
						. = TRUE
					else
						to_chat(L, span_warning("You need an attachable assembly!"))

#undef MAXIMUM_EMP_WIRES
