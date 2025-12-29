
//All devices that link into the R&D console fall into thise type for easy identification and some shared procs.


/obj/machinery/rnd
	name = "R&D Device"
	icon = 'icons/obj/machines/research.dmi'
	density = TRUE
	use_power = IDLE_POWER_USE

	/// Are we currently printing a machine
	var/busy = FALSE
	/// Is this machne hacked via wires
	var/hacked = FALSE
	/// Is this machine disabled via wires
	var/disabled = FALSE
	/// Ref to the linked techweb
	var/datum/techweb/stored_research
	/// The item loaded inside the machine, used by the destructive analyzer
	var/obj/item/loaded_item

/obj/machinery/rnd/Initialize(mapload)
	. = ..()
	wires = new /datum/wires/rnd(src)

/obj/machinery/rnd/LateInitialize()
	. = ..()
	if(!stored_research)
		CONNECT_TO_RND_SERVER_ROUNDSTART(stored_research, src)

/obj/machinery/rnd/Destroy()
	stored_research = null
	QDEL_NULL(wires)
	return ..()

/obj/machinery/rnd/examine(mob/user)
	. = ..()
	if(!in_range(user, src) && !isobserver(user))
		return

	. += span_notice("A <b>multitool</b> with techweb designs can be uploaded here.")
	. += span_notice("Its maintainence panel can be <b>screwed</b> [panel_open ? "closed" : "open"].")
	if(panel_open)
		. += span_notice("Use a <b>multitool</b> or <b>wirecutters</b> to interact with wires.")
		. += span_notice("The machine can be <b>pried</b> apart.")

/obj/machinery/rnd/add_context_self(datum/screentip_context/context, mob/user)
	context.add_left_click_tool_action("[panel_open ? "Close" : "Open"] Panel", TOOL_SCREWDRIVER)
	if(panel_open)
		context.add_left_click_tool_action("Deconstruct", TOOL_CROWBAR)
		context.add_left_click_tool_action("Open Wires", TOOL_WIRECUTTER)
		context.add_left_click_tool_action("Open Wires", TOOL_MULTITOOL)
	else if(iscarbon(user))
		var/mob/living/carbon/carbon_user = user
		var/obj/item/tool = carbon_user.get_active_held_item()
		var/datum/component/buffer/buffer_component = tool?.GetComponent(/datum/component/buffer)
		if(istype(buffer_component?.target, /datum/techweb))
			context.add_left_click_action("Upload Techweb")

/// Called when attempting to connect the machine to a techweb, forgetting the old.
/obj/machinery/rnd/proc/connect_techweb(datum/techweb/new_techweb)
	stored_research = new_techweb
	if(!isnull(stored_research))
		on_connected_techweb()

/// Called post-connection to a new techweb.
/obj/machinery/rnd/proc/on_connected_techweb()
	SHOULD_CALL_PARENT(FALSE)

/// Reset the state of this machine
/obj/machinery/rnd/proc/reset_busy()
	busy = FALSE

/obj/machinery/rnd/crowbar_act(mob/living/user, obj/item/tool)
	return default_deconstruction_crowbar(tool)

/obj/machinery/rnd/crowbar_act_secondary(mob/living/user, obj/item/tool)
	return crowbar_act(user, tool)

/obj/machinery/rnd/screwdriver_act(mob/living/user, obj/item/tool)
	return default_deconstruction_screwdriver(user, "[initial(icon_state)]_t", initial(icon_state), tool)

/obj/machinery/rnd/screwdriver_act_secondary(mob/living/user, obj/item/tool)
	return screwdriver_act(user, tool)

/obj/machinery/rnd/multitool_act(mob/living/user, obj/item/multitool/tool)
	if(panel_open)
		wires.interact(user)
		return TRUE

/obj/machinery/rnd/multitool_act_secondary(mob/living/user, obj/item/tool)
	return multitool_act(user, tool)

/obj/machinery/rnd/wirecutter_act(mob/living/user, obj/item/tool)
	if(panel_open)
		wires.interact(user)
		return TRUE

/obj/machinery/rnd/wirecutter_act_secondary(mob/living/user, obj/item/tool)
	return wirecutter_act(user, tool)

REGISTER_BUFFER_HANDLER(/obj/machinery/rnd)
DEFINE_BUFFER_HANDLER(/obj/machinery/rnd)
	if(istype(buffer, /datum/techweb))
		balloon_alert(user, "techweb connected")
		connect_techweb(buffer)
		return COMPONENT_BUFFER_RECEIVED
	return NONE

/// Whether the machine can have an item inserted in its current state.
/obj/machinery/rnd/proc/is_insertion_ready(mob/user)
	if(panel_open)
		balloon_alert(user, "panel open!")
		return FALSE
	if(disabled)
		balloon_alert(user, "belts disabled!")
		return FALSE
	if(busy)
		balloon_alert(user, "still busy!")
		return FALSE
	if(machine_stat & BROKEN)
		balloon_alert(user, "machine broken!")
		return FALSE
	if(machine_stat & NOPOWER)
		balloon_alert(user, "no power!")
		return FALSE
	if(loaded_item)
		balloon_alert(user, "item already loaded!")
		return FALSE
	return TRUE

//we eject the loaded item when deconstructing the machine
/obj/machinery/rnd/on_deconstruction()
	loaded_item?.forceMove(drop_location())
	return ..()
