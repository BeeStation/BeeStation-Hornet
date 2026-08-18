/obj/machinery/door/poddoor
	name = "blast door"
	desc = "A heavy duty blast door that opens mechanically."
	icon = 'icons/obj/doors/blastdoors/blastdoor.dmi'
	base_icon_state = "blast"
	icon_state = "blast_closed"
	layer = BLASTDOOR_LAYER
	closingLayer = CLOSED_BLASTDOOR_LAYER
	sub_door = TRUE
	explosion_block = 3
	heat_proof = TRUE
	safe = FALSE
	max_integrity = 600
	armor_type = /datum/armor/door_poddoor
	resistance_flags = FIRE_PROOF
	damage_deflection = 70
	/// The recipe for this door
	var/datum/crafting_recipe/recipe_type = /datum/crafting_recipe/blast_doors
	/// The current deconstruction step
	var/deconstruction = BLASTDOOR_FINISHED
	/// The door's ID (used for buttons, etc to control the door)
	var/id = null
	/// The sound that plays when the door opens
	var/pod_open_sound  = 'sound/machines/blastdoor.ogg'
	/// The sound that plays when the door closes
	var/pod_close_sound = 'sound/machines/blastdoor.ogg'

/datum/armor/door_poddoor
	melee = 50
	bullet = 100
	laser = 100
	energy = 100
	bomb = 50
	fire = 100
	acid = 70

/obj/machinery/door/poddoor/examine(mob/user)
	. = ..()
	if(panel_open)
		if(deconstruction == BLASTDOOR_FINISHED)
			. += span_notice("The maintenance panel is opened and the electronics could be <b>pried</b> out.")
			. += span_notice("\The [src] could be calibrated to a blast door controller ID with a <b>multitool</b>.")
			. += span_notice("You can scan another <b>blast door controller</b> and copy its ID.")
		else if(deconstruction == BLASTDOOR_NEEDS_ELECTRONICS)
			. += span_notice("The <i>electronics</i> are missing and there are some <b>wires</b> sticking out.")
		else if(deconstruction == BLASTDOOR_NEEDS_WIRES)
			. += span_notice("The <i>wires</i> have been removed and it's ready to be <b>sliced apart</b>.")

/obj/machinery/door/poddoor/attackby(obj/item/attacking_item, mob/living/user, params)
	. = ..()
	if(user.combat_mode)
		return

	if(deconstruction == BLASTDOOR_NEEDS_WIRES && istype(attacking_item, /obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/coil = attacking_item
		var/datum/crafting_recipe/recipe = locate(recipe_type) in GLOB.crafting_recipes
		var/amount_needed = recipe.reqs[/obj/item/stack/cable_coil]
		if(coil.get_amount() < amount_needed)
			balloon_alert(user, "not enough cable!")
			return
		balloon_alert(user, "adding cables...")
		if(!coil.use_tool(src, user, 5 SECONDS, amount = amount_needed, volume = 50))
			return TRUE
		deconstruction = BLASTDOOR_NEEDS_ELECTRONICS
		balloon_alert(user, "cables added")
		return TRUE

	if(deconstruction == BLASTDOOR_NEEDS_ELECTRONICS && istype(attacking_item, /obj/item/electronics/airlock))
		balloon_alert(user, "adding electronics...")
		if(!attacking_item.use_tool(src, user, 10 SECONDS, volume = 50))
			return TRUE
		qdel(attacking_item)
		balloon_alert(user, "electronics added")
		deconstruction = BLASTDOOR_FINISHED
		return TRUE

	if(deconstruction == BLASTDOOR_FINISHED && istype(attacking_item, /obj/item/assembly/control))
		if(density)
			balloon_alert(user, "open the door first!")
			return TRUE
		if(!panel_open)
			balloon_alert(user, "open the panel first!")
			return TRUE

		var/obj/item/assembly/control/controller_item = attacking_item
		if(!isnull(controller_item.id))
			id = controller_item.id
			balloon_alert(user, "id changed to [id]")
		return TRUE

/obj/machinery/door/poddoor/screwdriver_act(mob/living/user, obj/item/tool)
	. = ..()
	if (user.combat_mode)
		return

	if (density)
		balloon_alert(user, "open the door first!")
		return TOOL_ACT_TOOLTYPE_SUCCESS
	else if (default_deconstruction_screwdriver(user, icon_state, icon_state, tool))
		return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/machinery/door/poddoor/crowbar_act(mob/living/user, obj/item/tool)
	. = ..()
	// We need to check our parent's return value because it has some snowflake behavior with TRAIT_DOOR_PRYER
	if(!.)
		return

	if (machine_stat & NOPOWER)
		// ..() will have called open()
		return TOOL_ACT_TOOLTYPE_SUCCESS
	if (density)
		balloon_alert(user, "open the door first!")
		return TOOL_ACT_TOOLTYPE_SUCCESS
	if (!panel_open)
		balloon_alert(user, "open the panel first!")
		return TOOL_ACT_TOOLTYPE_SUCCESS
	if (deconstruction != BLASTDOOR_FINISHED)
		return

	balloon_alert(user, "removing airlock electronics...")
	if(tool.use_tool(src, user, 10 SECONDS, volume = 50))
		new /obj/item/electronics/airlock(loc)
		id = null
		deconstruction = BLASTDOOR_NEEDS_ELECTRONICS
		balloon_alert(user, "removed airlock electronics")
	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/machinery/door/poddoor/wirecutter_act(mob/living/user, obj/item/tool)
	. = ..()
	if (user.combat_mode)
		return

	if (density)
		balloon_alert(user, "open the door first!")
		return TOOL_ACT_TOOLTYPE_SUCCESS
	if (!panel_open)
		balloon_alert(user, "open the panel first!")
		return TOOL_ACT_TOOLTYPE_SUCCESS
	if (deconstruction != BLASTDOOR_NEEDS_ELECTRONICS)
		return

	balloon_alert(user, "removing internal cables...")
	if (tool.use_tool(src, user, 10 SECONDS, volume = 50))
		var/datum/crafting_recipe/recipe = locate(recipe_type) in GLOB.crafting_recipes
		var/amount = recipe.reqs[/obj/item/stack/cable_coil]
		new /obj/item/stack/cable_coil(loc, amount)
		deconstruction = BLASTDOOR_NEEDS_WIRES
	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/machinery/door/poddoor/welder_act(mob/living/user, obj/item/tool)
	. = ..()
	if (user.combat_mode)
		return

	if (density)
		balloon_alert(user, "open the door first!")
		return TOOL_ACT_TOOLTYPE_SUCCESS
	if (!panel_open)
		balloon_alert(user, "open the panel first!")
		return TOOL_ACT_TOOLTYPE_SUCCESS
	if (deconstruction != BLASTDOOR_NEEDS_WIRES)
		return

	balloon_alert(user, "slicing apart...")
	if(tool.use_tool(src, user, 15 SECONDS, volume = 50))
		var/datum/crafting_recipe/recipe = locate(recipe_type) in GLOB.crafting_recipes
		var/amount = recipe.reqs[/obj/item/stack/sheet/plasteel]
		new /obj/item/stack/sheet/plasteel(loc, amount)
		qdel(src)
	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/machinery/door/poddoor/multitool_act(mob/living/user, obj/item/tool)
	. = ..()
	if (user.combat_mode)
		return

	if (density)
		balloon_alert(user, "open the door first!")
		return TOOL_ACT_TOOLTYPE_SUCCESS
	if (!panel_open)
		balloon_alert(user, "open the panel first!")
		return TOOL_ACT_TOOLTYPE_SUCCESS
	if (deconstruction != BLASTDOOR_FINISHED)
		return

	var/change_id = tgui_input_number(user, "Set the shutters/blast door controller's ID. It must be a number between 1 and 100.", "Controller ID", min_value = 1, max_value = 100)
	if (isnull(change_id) || QDELETED(src) || QDELETED(user))
		return TOOL_ACT_TOOLTYPE_SUCCESS

	id = change_id
	balloon_alert(user, "id changed to [id]")
	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/machinery/door/poddoor/preopen
	icon_state = "blast_open"
	density = FALSE
	opacity = FALSE
	z_flags = NONE // reset zblock

/obj/machinery/door/poddoor/ert
	name = "hardened blast door"
	desc = "A heavy duty blast door that only opens for dire emergencies."
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

//special poddoors that open when emergency shuttle docks at centcom
/obj/machinery/door/poddoor/shuttledock
	var/checkdir = EAST // door won't open if turf in this dir is `turftype`
	var/turftype = /turf/open/space

/obj/machinery/door/poddoor/shuttledock/proc/check()
	var/turf/T = get_step(src, checkdir)
	if(!istype(T, turftype))
		INVOKE_ASYNC(src, PROC_REF(open))
	else
		INVOKE_ASYNC(src, PROC_REF(close))

/obj/machinery/door/poddoor/incinerator_toxmix
	name = "combustion chamber vent"
	id = INCINERATOR_TOXMIX_VENT

/obj/machinery/door/poddoor/incinerator_atmos_main
	name = "turbine vent"
	id = INCINERATOR_ATMOS_MAINVENT

/obj/machinery/door/poddoor/incinerator_atmos_aux
	name = "combustion chamber vent"
	id = INCINERATOR_ATMOS_AUXVENT

/obj/machinery/door/poddoor/incinerator_syndicatelava_main
	name = "turbine vent"
	id = INCINERATOR_SYNDICATELAVA_MAINVENT

/obj/machinery/door/poddoor/incinerator_syndicatelava_aux
	name = "combustion chamber vent"
	id = INCINERATOR_SYNDICATELAVA_AUXVENT

/obj/machinery/door/poddoor/Bumped(atom/movable/AM)
	if(density)
		return 0
	else
		return ..()

/obj/machinery/door/poddoor/shutters/bumpopen()
	return

//"BLAST" doors are obviously stronger than regular doors when it comes to BLASTS.
/obj/machinery/door/poddoor/ex_act(severity, target)
	if(severity == EXPLODE_LIGHT)
		return
	return ..()

/obj/machinery/door/poddoor/do_animate(animation)
	switch(animation)
		if("opening")
			flick("[base_icon_state]_opening", src)
			playsound(src, pod_open_sound, 30, 1)
		if("closing")
			flick("[base_icon_state]_closing", src)
			playsound(src, pod_close_sound, 30, 1)

/obj/machinery/door/poddoor/update_icon()
	if(density)
		icon_state = "[base_icon_state]_closed"
	else
		icon_state = "[base_icon_state]_open"

/obj/machinery/door/poddoor/try_to_activate_door(obj/item/I, mob/user)
	return

/obj/machinery/door/poddoor/try_to_crowbar(obj/item/I, mob/user)
	if(machine_stat & NOPOWER)
		open(TRUE)
