//blast door (de)construction states
#define BLASTDOOR_NEEDS_WIRES 0
#define BLASTDOOR_NEEDS_ELECTRONICS 1
#define BLASTDOOR_FINISHED 2

/obj/machinery/door/poddoor
	name = "blast door"
	desc = "A heavy duty blast door that opens mechanically."
	icon = 'icons/obj/doors/blastdoor.dmi'
	icon_state = "closed"
	layer = BLASTDOOR_LAYER
	closingLayer = CLOSED_BLASTDOOR_LAYER
	sub_door = TRUE
	explosion_block = 3
	heat_proof = TRUE
	safe = FALSE
	max_integrity = 600
	armor = list("melee" = 50, "bullet" = 100, "laser" = 100, "energy" = 100, "bomb" = 50, "bio" = 100, "rad" = 100, "fire" = 100, "acid" = 70, "stamina" = 0)
	resistance_flags = FIRE_PROOF
	damage_deflection = 70
	var/datum/crafting_recipe/recipe_type = /datum/crafting_recipe/blast_doors
	var/deconstruction = BLASTDOOR_FINISHED // deconstruction step
	var/id = 1

/obj/machinery/door/poddoor/screwdriver_act(mob/living/user, obj/item/tool)
	. = ..()
	if (density)
		balloon_alert(user, "open the door first!")
		return TOOL_ACT_TOOLTYPE_SUCCESS
	else if (default_deconstruction_screwdriver(user, icon_state, icon_state, tool))
		return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/machinery/door/poddoor/multitool_act(mob/living/user, obj/item/tool)
	. = ..()
	if (density)
		balloon_alert(user, "open the door first!")
		return TOOL_ACT_TOOLTYPE_SUCCESS
	if (!panel_open)
		return
	if (deconstruction != BLASTDOOR_FINISHED)
		return
	var/change_id = input("Set the shutters/blast door/blast door controllers ID. It must be a number between 1 and 100.", "ID", id) as num|null
	if(!change_id || QDELETED(usr) || QDELETED(src) || !usr.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
		return
	id = clamp(round(change_id, 1), 1, 100)
	to_chat(user, span_notice("You change the ID to [id]."))
	balloon_alert(user, "ID changed")
	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/machinery/door/poddoor/crowbar_act(mob/living/user, obj/item/tool)
	. = ..()
	if(machine_stat & NOPOWER)
		open(TRUE)
		return TOOL_ACT_TOOLTYPE_SUCCESS
	if (density)
		balloon_alert(user, "open the door first!")
		return TOOL_ACT_TOOLTYPE_SUCCESS
	if (!panel_open)
		return
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
	if (density)
		balloon_alert(user, "open the door first!")
		return TOOL_ACT_TOOLTYPE_SUCCESS
	if (!panel_open)
		return
	if (deconstruction != BLASTDOOR_NEEDS_ELECTRONICS)
		return
	balloon_alert(user, "removing internal cables...")
	if(tool.use_tool(src, user, 10 SECONDS, volume = 50))
		var/datum/crafting_recipe/recipe = locate(recipe_type) in GLOB.crafting_recipes
		var/amount = recipe.reqs[/obj/item/stack/cable_coil]
		new /obj/item/stack/cable_coil(loc, amount)
		deconstruction = BLASTDOOR_NEEDS_WIRES
		balloon_alert(user, "removed internal cables")
	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/machinery/door/poddoor/welder_act(mob/living/user, obj/item/tool)
	. = ..()
	if (density)
		balloon_alert(user, "open the door first!")
		return TOOL_ACT_TOOLTYPE_SUCCESS
	if (!panel_open)
		return
	if (deconstruction != BLASTDOOR_NEEDS_WIRES)
		return
	balloon_alert(user, "tearing apart...") //You're tearing me apart, Lisa!
	if(tool.use_tool(src, user, 15 SECONDS, volume = 50))
		var/datum/crafting_recipe/recipe = locate(recipe_type) in GLOB.crafting_recipes
		var/amount = recipe.reqs[/obj/item/stack/sheet/plasteel]
		new /obj/item/stack/sheet/plasteel(loc, amount)
		user.balloon_alert(user, "torn apart")
		qdel(src)
	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/machinery/door/poddoor/examine(mob/user)
	. = ..()
	if(panel_open)
		if(deconstruction == BLASTDOOR_FINISHED)
			. += span_notice("The maintenance panel is opened and the electronics could be <b>pried</b> out.")
		else if(deconstruction == BLASTDOOR_NEEDS_ELECTRONICS)
			. += span_notice("The <i>electronics</i> are missing and there are some <b>wires</b> sticking out.")
		else if(deconstruction == BLASTDOOR_NEEDS_WIRES)
			. += span_notice("The <i>wires</i> have been removed and it's ready to be <b>sliced apart</b>.")

/obj/machinery/door/poddoor/preopen
	icon_state = "open"
	density = FALSE
	opacity = 0

/obj/machinery/door/poddoor/ert
	name = "hardened blast door"
	desc = "A heavy duty blast door that only opens for dire emergencies."
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

//special poddoors that open when emergency shuttle docks at centcom
/obj/machinery/door/poddoor/shuttledock
	var/checkdir = 4	//door won't open if turf in this dir is `turftype`
	var/turftype = /turf/open/space

/obj/machinery/door/poddoor/shuttledock/proc/check()
	var/turf/turf = get_step(src, checkdir)
	if(!istype(turf, turftype))
		INVOKE_ASYNC(src, .proc/open)
	else
		INVOKE_ASYNC(src, .proc/close)

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

//"BLAST" doors are obviously stronger than regular doors when it comes to BLASTS.
/obj/machinery/door/poddoor/ex_act(severity, target)
	if(severity == 3)
		return
	..()

/obj/machinery/door/poddoor/do_animate(animation)
	switch(animation)
		if("opening")
			flick("opening", src)
			playsound(src, 'sound/machines/blastdoor.ogg', 30, 1)
		if("closing")
			flick("closing", src)
			playsound(src, 'sound/machines/blastdoor.ogg', 30, 1)

/obj/machinery/door/poddoor/update_icon()
	if(density)
		icon_state = "closed"
	else
		icon_state = "open"

/obj/machinery/door/poddoor/try_to_activate_door(obj/item/I, mob/user)
	return

/obj/machinery/door/poddoor/try_to_crowbar(obj/item/I, mob/user)
	if(machine_stat & NOPOWER)
		open(1)
