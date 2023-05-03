/obj/machinery/door/poddoor
	name = "blast door"
	desc = "A heavy duty blast door that opens mechanically."
	icon = 'icons/obj/doors/blastdoor.dmi'

	var/id = 1
	layer = BLASTDOOR_LAYER
	closingLayer = CLOSED_BLASTDOOR_LAYER
	sub_door = TRUE
	explosion_block = 3
	heat_proof = TRUE
	safe = FALSE
	max_integrity = 600
	armor = list(MELEE = 50, BULLET = 100, LASER = 100, ENERGY = 100, BOMB = 50, BIO = 100, RAD = 100, FIRE = 100, ACID = 70, STAMINA = 0)
	resistance_flags = FIRE_PROOF
	damage_deflection = 70
	var/datum/crafting_recipe/recipe_type = /datum/crafting_recipe/blast_doors
	var/deconstruction = BLASTDOOR_FINISHED // deconstruction step
	var/base_state = "blast"
	var/pod_open_sound  = 'sound/machines/blastdoor.ogg'
	var/pod_close_sound = 'sound/machines/blastdoor.ogg'
	icon_state = "blast_closed"

/obj/machinery/door/poddoor/attackby(obj/item/W, mob/user, params)
	. = ..()

	if(W.tool_behaviour == TOOL_SCREWDRIVER)
		if(density)
			to_chat(user, "<span class='warning'>You need to open [src] before opening its maintenance panel.</span>")
			return
		else if(default_deconstruction_screwdriver(user, icon_state, icon_state, W))
			to_chat(user, "<span class='notice'>You [panel_open ? "open" : "close"] the maintenance hatch of [src].</span>")
			return TRUE

	if(panel_open)
		if(W.tool_behaviour == TOOL_MULTITOOL && deconstruction == BLASTDOOR_FINISHED)
			var/change_id = input("Set the shutters/blast door controller's ID. It must be a number between 1 and 100.", "ID", id) as num|null
			if(change_id)
				id = clamp(round(change_id, 1), 1, 100)
				to_chat(user, "<span class='notice'>You change the ID to [id].</span>")

		if(W.tool_behaviour == TOOL_CROWBAR &&deconstruction == BLASTDOOR_FINISHED)
			to_chat(user, "<span class='notice'>You start to remove the airlock electronics.</span>")
			if(do_after(user, 10 SECONDS, target = src))
				new /obj/item/electronics/airlock(loc)
				id = null
				deconstruction = BLASTDOOR_NEEDS_ELECTRONICS

		else if(W.tool_behaviour == TOOL_WIRECUTTER && deconstruction == BLASTDOOR_NEEDS_ELECTRONICS)
			to_chat(user, "<span class='notice'>You start to remove the internal cables.</span>")
			if(do_after(user, 10 SECONDS, target = src))
				deconstruction = TRUE
				var/datum/crafting_recipe/recipe = locate(recipe_type) in GLOB.crafting_recipes
				var/amount = recipe.reqs[/obj/item/stack/cable_coil]
				new /obj/item/stack/cable_coil(loc, amount)
				deconstruction = BLASTDOOR_NEEDS_WIRES

		else if(W.tool_behaviour == TOOL_WELDER && deconstruction == BLASTDOOR_NEEDS_WIRES)
			if(!W.tool_start_check(user, amount=0))
				return

			to_chat(user, "<span class='notice'>You start tearing apart the [src].</span>")
			playsound(src.loc, 'sound/items/welder.ogg', 50, 1)
			if(do_after(user, 15 SECONDS, target = src))
				new /obj/item/stack/sheet/plasteel(loc, 15)
				qdel(src)

/obj/machinery/door/poddoor/examine(mob/user)
	. = ..()
	if(panel_open)
		if(deconstruction == BLASTDOOR_FINISHED)
			. += "<span class='notice'>The maintenance panel is opened and the electronics could be <b>pried</b> out.</span>"
		else if(deconstruction == BLASTDOOR_NEEDS_ELECTRONICS)
			. += "<span class='notice'>The <i>electronics</i> are missing and there are some <b>wires</b> sticking out.</span>"
		else if(deconstruction == BLASTDOOR_NEEDS_WIRES)
			. += "<span class='notice'>The <i>wires</i> have been removed and it's ready to be <b>sliced apart</b>.</span>"

/obj/machinery/door/poddoor/preopen
	icon_state = "blast_open"
	density = FALSE
	opacity = 0
	obj_flags = CAN_BE_HIT // reset zblock

/obj/machinery/door/poddoor/ert
	name = "hardened blast door"
	desc = "A heavy duty blast door that only opens for dire emergencies."
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

//special poddoors that open when emergency shuttle docks at centcom
/obj/machinery/door/poddoor/shuttledock
	var/checkdir = 4	//door won't open if turf in this dir is `turftype`
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

//"BLAST" doors are obviously stronger than regular doors when it comes to BLASTS.
/obj/machinery/door/poddoor/ex_act(severity, target)
	if(severity == 3)
		return
	..()

/obj/machinery/door/poddoor/do_animate(animation)
	switch(animation)
		if("opening")
			flick("[base_state]_opening", src)
			playsound(src, pod_open_sound, 30, 1)
		if("closing")
			flick("[base_state]_closing", src)
			playsound(src, pod_close_sound, 30, 1)

/obj/machinery/door/poddoor/update_icon()
	if(density)
		icon_state = "[base_state]_closed"
	else
		icon_state = "[base_state]_open"

/obj/machinery/door/poddoor/try_to_activate_door(obj/item/I, mob/user)
	return

/obj/machinery/door/poddoor/try_to_crowbar(obj/item/I, mob/user)
	if(machine_stat & NOPOWER)
		open(1)
