/obj/machinery/door/poddoor
	name = "blast door"
	desc = "A heavy duty blast door that opens mechanically."
	icon = 'icons/obj/doors/blastdoor.dmi'
	icon_state = "closed"
	var/id = 1
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
	poddoor = TRUE
	var/ertblast = FALSE //If this is true the blast door cannot be deconstructed
	var/deconstruction = INTACT //For the deconstruction steps

/obj/machinery/door/poddoor/attackby(obj/item/W, mob/user, params)
	. = ..()
	if(ertblast && W.tool_behaviour == TOOL_SCREWDRIVER) // This makes it so ERT members cannot cheese by opening their blast doors.
		to_chat(user, "<span class='warning'>This shutter has a different kind of screw, you cannot unscrew the panel open.</span>")
		return

	if(W.tool_behaviour == TOOL_SCREWDRIVER)
		if(density)
			to_chat(user, "<span class='warning'>You need to open [src] before opening its maintenance panel.</span>")
			return
		else if(default_deconstruction_screwdriver(user, icon_state, icon_state, W))
			to_chat(user, "<span class='notice'>You [panel_open ? "open" : "close"] the maintenance hatch of [src].</span>")
			return TRUE

	if(panel_open)
		if(W.tool_behaviour == TOOL_MULTITOOL)
			var/change_id = input("Set the shutters/blast door/blast door controllers ID. It must be a number between 1 and 100.", "ID", id) as num|null
			if(change_id)
				id = clamp(round(change_id, 1), 1, 100)
				to_chat(user, "<span class='notice'>You change the ID to [id].</span>")

		if(W.tool_behaviour == TOOL_CROWBAR && deconstruction == INTACT)
			to_chat(user, "<span class='notice'>You start to remove the airlock electronics.</span>")
			if(do_after(user, 10 SECONDS, target = src))
				new /obj/item/electronics/airlock(loc)
				id = null
				deconstruction = FALSE

		if(W.tool_behaviour == TOOL_WIRECUTTER && deconstruction == FALSE)
			to_chat(user, "<span class='notice'>You start to remove the internal cables.</span>")
			if(do_after(user, 10 SECONDS, target = src))
				deconstruction = TRUE

		if(W.tool_behaviour == TOOL_WELDER && deconstruction == TRUE)
			to_chat(user, "<span class='notice'>You start tearing apart the [src].</span>")
			playsound(src.loc, 'sound/items/welder.ogg', 50, 1)
			if(do_after(user, 15 SECONDS, target = src))
				new /obj/item/stack/sheet/plasteel(loc, 5)
				qdel(src)

/obj/machinery/door/poddoor/examine(mob/user)
	. = ..()
	if(panel_open)
		. += "<span class='<span class='notice'>The maintenance panel is [panel_open ? "opened" : "closed"].</span>"

/obj/machinery/door/poddoor/preopen
	icon_state = "open"
	density = FALSE
	opacity = 0

/obj/machinery/door/poddoor/ert
	name = "hardened blast door"
	desc = "A heavy duty blast door that only opens for dire emergencies."
	ertblast = TRUE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

//special poddoors that open when emergency shuttle docks at centcom
/obj/machinery/door/poddoor/shuttledock
	var/checkdir = 4	//door won't open if turf in this dir is `turftype`
	var/turftype = /turf/open/space
	ertblast = TRUE


/obj/machinery/door/poddoor/shuttledock/proc/check()
	var/turf/T = get_step(src, checkdir)
	if(!istype(T, turftype))
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
