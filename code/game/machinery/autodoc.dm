/obj/machinery/autodoc
	name = "autodoc"
	desc = "An advanced machine used for inserting organs and implants into the occupant."
	density = TRUE
	state_open = FALSE
	icon = 'icons/obj/machines/fat_sucker.dmi'
	icon_state = "fat"
	verb_say = "states"
	state_open = FALSE
	idle_power_usage = 50
	circuit = /obj/item/circuitboard/machine/autodoc
	var/obj/item/organ/storedorgan
	var/organ_type = /obj/item/organ

/obj/machinery/autodoc/Initialize()
	. = ..()
	update_icon()

/obj/machinery/autodoc/proc/insert_organ(var/obj/item/I)
	storedorgan = I
	I.forceMove(src)

/obj/machinery/autodoc/close_machine(mob/user)
	..()
	playsound(src, 'sound/machines/click.ogg', 50)
	if(occupant)
		if(!iscarbon(occupant))
			occupant.forceMove(drop_location())
			occupant = null
			return
		to_chat(occupant, "<span class='notice'>You enter [src]</span>")

		if(!storedorgan)
			to_chat(occupant, "<span class='notice'>[src] currently has no implant stored.</span>")
			return
		storedorgan.Insert(occupant)//insert stored organ into the user
		user.visible_message("<span class='notice'>[user] presses a button on [src], and you hear a short mechanical noise.</span>", "<span class='notice'>You feel a sharp sting as [src] plunges into your body.</span>")
		playsound(get_turf(occupant), 'sound/weapons/circsawhit.ogg', 50, 1)
		storedorgan = null


/obj/machinery/autodoc/open_machine(mob/user)
	if(occupant)
		occupant.forceMove(drop_location())
		occupant = null
	..(FALSE)

/obj/machinery/autodoc/interact(mob/user)
	if(panel_open)
		to_chat(user, "<span class='notice'>Close the maintenance panel first.</span>")
		return

	if(state_open)
		close_machine()
		return

	open_machine()

/obj/machinery/autodoc/attackby(obj/item/I, mob/user, params)
	if(istype(I, organ_type))
		if(storedorgan)
			to_chat(user, "<span class='notice'>[src] already has an implant stored.</span>")
			return
		if(!user.transferItemToLoc(I, src))
			return
		storedorgan = I
		to_chat(user, "<span class='notice'>You insert the [I] into [src].</span>")
	else
		return ..()

/obj/machinery/autodoc/screwdriver_act(mob/living/user, obj/item/I)
	. = TRUE
	if(..())
		return
	if(occupant)
		to_chat(user, "<span class='warning'>[src] is currently occupied!</span>")
		return
	if(state_open)
		to_chat(user, "<span class='warning'>[src] must be closed to [panel_open ? "close" : "open"] its maintenance hatch!</span>")
		return
	if(default_deconstruction_screwdriver(user, icon_state, icon_state, I))
		update_icon()
		return
	return FALSE

/obj/machinery/autodoc/crowbar_act(mob/living/user, obj/item/I)
	if(default_deconstruction_crowbar(I))
		return TRUE


/obj/machinery/autodoc/update_icon()
	overlays.Cut()
	if(!state_open)
		overlays += "[icon_state]_door_off"
		if(occupant)
			if(powered(EQUIP))
				overlays += "[icon_state]_stack"
				overlays += "[icon_state]_yellow"
		else
			overlays += "[icon_state]_red"
	else if(powered(EQUIP))
		overlays += "[icon_state]_red"
	if(panel_open)
		overlays += "[icon_state]_panel"