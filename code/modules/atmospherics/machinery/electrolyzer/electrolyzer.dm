#define ELECTROLYZER_MODE_STANDBY "standby"
#define ELECTROLYZER_MODE_WORKING "working"

/obj/machinery/electrolyzer
	name = "space electrolyzer"
	desc = "Thanks to the fast and dynamic response of our electrolyzers, on-site hydrogen production is guaranteed. Warranty void if used by clowns"
	anchored = FALSE
	density = TRUE
	interaction_flags_machine = INTERACT_MACHINE_ALLOW_SILICON | INTERACT_MACHINE_OPEN
	icon = 'icons/obj/atmospherics/machines.dmi'
	icon_state = "electrolyzer-off"
	max_integrity = 250
	armor_type = /datum/armor/machinery_electrolyzer
	circuit = /obj/item/circuitboard/machine/electrolyzer
	/// We don't use area power, we always use the cell
	use_power = NO_POWER_USE
	///used to check if there is a cell in the machine
	var/obj/item/stock_parts/cell/cell
	///check if the machine is on or off
	var/on = FALSE
	///check what mode the machine should be (WORKING, STANDBY)
	var/mode = ELECTROLYZER_MODE_STANDBY
	///Increase the amount of moles worked on, changed by upgrading the manipulator tier
	var/working_power = 1
	///Decrease the amount of power usage, changed by upgrading the capacitor tier
	var/efficiency = 0.5

/datum/armor/machinery_electrolyzer
	fire = 80
	acid = 10

/obj/machinery/electrolyzer/get_cell()
	return cell

/obj/machinery/electrolyzer/Initialize(mapload)
	. = ..()
	if(ispath(cell))
		cell = new cell(src)
	SSair.start_processing_machine(src)
	update_appearance()

/obj/machinery/electrolyzer/add_context_self(datum/screentip_context/context, mob/user)
	context.add_alt_click_action("Turn [on ? "off" : "on"]")
	context.add_left_click_tool_action("[panel_open ? "Close" : "Open"] panel", TOOL_SCREWDRIVER)
	context.add_left_click_tool_action(anchored ? "Unanchor" : "Anchor", TOOL_WRENCH)

/obj/machinery/electrolyzer/Destroy()
	if(cell)
		QDEL_NULL(cell)
	. = ..()

/obj/machinery/electrolyzer/on_deconstruction(disassembled)
	if(cell)
		LAZYADD(component_parts, cell)
		cell = null
	. = ..()

/obj/machinery/electrolyzer/examine(mob/user)
	. = ..()
	. += "\The [src] is [on ? "on" : "off"], and the panel is [panel_open ? "open" : "closed"]."

	if(cell)
		. += "The charge meter reads [cell ? round(cell.percent(), 1) : 0]%."
	else
		. += "There is no power cell installed."
	if(in_range(user, src) || isobserver(user))
		. += span_notice("<b>Alt-click</b> to toggle [on ? "off" : "on"].")
		. += span_notice("<b>Anchor</b> to drain power from APC instead of cell")
	. += span_notice("It will drain power from the [anchored ? "area's APC" : "internal power cell"].")


/obj/machinery/electrolyzer/update_icon_state()
	icon_state = "electrolyzer-[on ? "[mode]" : "off"]"
	. = ..()

/obj/machinery/electrolyzer/update_overlays()
	. = ..()
	if(panel_open)
		. += "electrolyzer-open"

/obj/machinery/electrolyzer/process_atmos()
	if(!is_operational && on)
		on = FALSE
	if(!on)
		return PROCESS_KILL

	if((!cell || cell.charge <= 0) && !anchored)
		on = FALSE
		update_appearance()
		return PROCESS_KILL

	var/turf/our_turf = loc
	if(!istype(our_turf))
		if(mode != ELECTROLYZER_MODE_STANDBY)
			mode = ELECTROLYZER_MODE_STANDBY
			update_appearance()
		return

	var/new_mode = on ? ELECTROLYZER_MODE_WORKING : ELECTROLYZER_MODE_STANDBY //change the mode to working if the machine is on

	if(mode != new_mode) //check if the mode is set correctly
		mode = new_mode
		update_appearance()

	if(mode == ELECTROLYZER_MODE_STANDBY)
		return

	var/datum/gas_mixture/enviroment = our_turf.return_air() //get air from the turf
	if(!enviroment)
		return

	call_reactions(enviroment)

	air_update_turf(FALSE, FALSE)

	var/power_to_use = (5 * (3 * working_power) * working_power) / (efficiency + working_power)
	if(anchored)
		use_power(power_to_use)
	else
		cell.use(power_to_use)

/obj/machinery/electrolyzer/proc/call_reactions(datum/gas_mixture/enviroment)
	for(var/reaction in GLOB.electrolyzer_reactions)
		var/datum/electrolyzer_reaction/current_reaction = GLOB.electrolyzer_reactions[reaction]

		if(!current_reaction.reaction_check(enviroment))
			continue

		current_reaction.react(loc, enviroment, working_power)

	enviroment.garbage_collect()

/obj/machinery/electrolyzer/RefreshParts()
	. = ..()
	var/power = 0
	var/cap = 0
	for(var/obj/item/stock_parts/manipulator/manipulator in component_parts)
		power += manipulator.rating
	for(var/obj/item/stock_parts/capacitor/capacitor in component_parts)
		cap += capacitor.rating

	working_power = power //used in the amount of moles processed

	efficiency = (cap + 1) * 0.5 //used in the amount of charge in power cell uses

/obj/machinery/electrolyzer/screwdriver_act(mob/living/user, obj/item/tool)
	tool.play_tool_sound(src, 50)
	panel_open = !panel_open
	balloon_alert(user, "[panel_open ? "opened" : "closed"] panel")
	update_appearance()
	return TRUE

/obj/machinery/electrolyzer/wrench_act(mob/living/user, obj/item/tool)
	return default_unfasten_wrench(user, tool)

/obj/machinery/electrolyzer/crowbar_act(mob/living/user, obj/item/tool)
	return default_deconstruction_crowbar(tool)

/obj/machinery/electrolyzer/attackby(obj/item/attacking_item, mob/user, list/modifiers)
	add_fingerprint(user)
	if(istype(attacking_item, /obj/item/stock_parts/cell))
		if(!panel_open)
			balloon_alert(user, "open panel!")
			return
		if(cell)
			balloon_alert(user, "cell inside!")
			return
		if(!user.transferItemToLoc(attacking_item, src))
			return
		cell = attacking_item
		attacking_item.add_fingerprint(usr)
		balloon_alert(user, "inserted cell")
		SStgui.update_uis(src)
		return

	return ..()

/obj/machinery/electrolyzer/AltClick(mob/user)
	. = ..()
	if(panel_open)
		balloon_alert(user, "close panel!")
		return
	toggle_power(user)

/obj/machinery/electrolyzer/proc/toggle_power(mob/user)
	if(!anchored && !cell)
		balloon_alert(user, "insert cell or anchor!")
		return
	on = !on
	mode = ELECTROLYZER_MODE_STANDBY
	update_appearance()
	balloon_alert(user, "turned [on ? "on" : "off"]")
	if(on)
		SSair.start_processing_machine(src)

/obj/machinery/electrolyzer/ui_state(mob/user)
	return GLOB.physical_state

/obj/machinery/electrolyzer/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Electrolyzer", name)
		ui.set_autoupdate(TRUE)
		ui.open()

/obj/machinery/electrolyzer/ui_data()
	var/list/data = list()
	data["open"] = panel_open
	data["on"] = on
	data["hasPowercell"] = !isnull(cell)
	data["anchored"] = anchored
	if(cell)
		data["powerLevel"] = round(cell.percent(), 1)
	return data

/obj/machinery/electrolyzer/ui_act(action, params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	switch(action)
		if("power")
			toggle_power(ui.user)
			. = TRUE
		if("eject")
			if(panel_open && cell)
				cell.forceMove(drop_location())
				cell = null
				. = TRUE

#undef ELECTROLYZER_MODE_STANDBY
#undef ELECTROLYZER_MODE_WORKING
