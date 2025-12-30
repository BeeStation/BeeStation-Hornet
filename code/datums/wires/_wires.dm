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
	if(!wires)
		return WIRE_INTERACTION_FAIL
	if(!user.CanReach(src))
		return WIRE_INTERACTION_FAIL
	wires.interact(user)
	return WIRE_INTERACTION_BLOCK

/datum/wires
	var/atom/holder = null // The holder (atom that contains these wires).
	var/holder_type = null // The holder's typepath (used to make wire colors common to all holders).
	var/proper_name = "Unknown" // The display name for the wire set shown in station blueprints. Not used if randomize is true or it's an item NT wouldn't know about (Explosives/Nuke)

	var/list/wires = list() // Dictionary of wires to colours.
	var/list/cut_wires = list() // List of wires that have been cut.
	var/list/colors = list() // Dictionary of colors to wire.
	var/list/wire_to_colors = list() // Dictionary of colors to wire.
	var/list/assemblies = list() // List of attached assemblies.
	var/randomize = 0 // If every instance of these wires should be random.
						// Prevents wires from showing up in station blueprints
	var/list/labelled_wires = list() // Associative List of wires that have labels. Key = wire, Value = Bool (Revealed) [To be refactored into skills]

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

	for (var/colour in colors)
		var/wire = colors[colour]
		wire_to_colors[wire] = colour

/datum/wires/Destroy()
	holder = null
	//properly clear refs to avoid harddels & other problems
	for(var/color in assemblies)
		var/obj/item/assembly/assembly = assemblies[color]
		assembly.holder = null
		assembly.connected = null
	LAZYCLEARLIST(assemblies)
	return ..()

/datum/wires/proc/add_duds(duds)
	while(duds)
		var/dud = WIRE_DUD_PREFIX + "[--duds]"
		if(dud in wires)
			continue
		wires += dud

/datum/wires/proc/randomize()
	var/static/list/possible_colors = list(
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
		colors[pick_n_take(my_possible_colors)] = wire

/datum/wires/proc/shuffle_wires()
	colors.Cut()
	randomize()
	ui_update()

/datum/wires/proc/repair()
	cut_wires.Cut()
	ui_update()

/datum/wires/proc/get_wire(color)
	return colors[color]

/datum/wires/proc/get_color_of_wire(wire_type)
	return wire_to_colors[wire_type]

/datum/wires/proc/get_attached(color)
	if(assemblies[color])
		return assemblies[color]
	return null

/datum/wires/proc/is_attached(color)
	if(assemblies[color])
		return TRUE

/datum/wires/proc/is_cut(wire)
	return (wire in cut_wires)

/datum/wires/proc/is_color_cut(color)
	return is_cut(get_wire(color))

/datum/wires/proc/is_all_cut()
	if(cut_wires.len == wires.len)
		return TRUE

/datum/wires/proc/is_dud(wire)
	return findtext(wire, WIRE_DUD_PREFIX, 1, length(WIRE_DUD_PREFIX) + 1)

/datum/wires/proc/is_dud_color(color)
	return is_dud(get_wire(color))

/// Cut a specific wire.
/// User may be null
/datum/wires/proc/cut(wire, mob/user_or_null)
	if(is_cut(wire))
		cut_wires -= wire
		on_cut(wire, user_or_null, mend = TRUE)
	else
		cut_wires += wire
		on_cut(wire, user_or_null, mend = FALSE)
	ui_update()

/datum/wires/proc/cut_color(color, mob/user_or_null)
	cut(get_wire(color), user_or_null)
	ui_update()

/datum/wires/proc/cut_random(mob/user_or_null)
	cut(wires[rand(1, wires.len)], user_or_null)
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

/datum/wires/proc/pulse_assembly(obj/item/assembly/S)
	for(var/color in assemblies)
		if(S == assemblies[color])
			pulse_color(color)
			ui_update()
			return TRUE

/datum/wires/proc/attach_assembly(color, obj/item/assembly/S)
	if(S && istype(S) && S.attachable && !is_attached(color))
		assemblies[color] = S
		S.forceMove(holder)
		/**
		 * special snowflake check for machines
		 * someone attached a signaler to the machines wires
		 * move it to the machines component parts so it doesn't get moved out in dump_inventory_contents() which gets called a lot
		 */
		if(istype(holder, /obj/machinery))
			var/obj/machinery/machine = holder
			LAZYADD(machine.component_parts, S)
		S.connected = src
		S.on_attach() // Notify assembly that it is attached
		ui_update()
		return S

/datum/wires/proc/detach_assembly(color)
	var/obj/item/assembly/S = get_attached(color)
	if(S && istype(S))
		assemblies -= color
		S.connected = null
		S.on_detach() // Notify the assembly.  This should remove the reference to our holder
		ui_update()
		return S

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
		return
	ui_interact(user)
	for(var/A in assemblies)
		var/obj/item/I = assemblies[A]
		if(istype(I) && I.on_found(user))
			return

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
		ui = new(user, src, "Wires", "Wires")
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
			"wire" = (((reveal_wires || labelled_wires[wire_type]) && !is_dud_color(color)) ? wire_type : null),
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
