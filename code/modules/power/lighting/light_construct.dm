/obj/structure/light_construct
	name = "light fixture frame"
	desc = "A light fixture under construction."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "tube-construct-stage1"
	anchored = TRUE
	layer = WALL_OBJ_LAYER
	max_integrity = 200
	armor_type = /datum/armor/structure_light_construct

	var/stage = 1
	var/fixture_type = "tube"
	var/sheets_refunded = 2
	var/obj/machinery/light/newlight = null
	var/obj/item/stock_parts/cell/cell

	var/cell_connectors = TRUE

CREATION_TEST_IGNORE_SUBTYPES(/obj/structure/light_construct)


/datum/armor/structure_light_construct
	melee = 50
	bullet = 10
	laser = 10
	fire = 80
	acid = 50

/obj/structure/light_construct/Initialize(mapload, ndir, building)
	. = ..()
	if(building)
		setDir(ndir)

/obj/structure/light_construct/Destroy()
	QDEL_NULL(cell)
	return ..()

/obj/structure/light_construct/get_cell()
	return cell

/obj/structure/light_construct/examine(mob/user)
	. = ..()
	switch(stage)
		if(1)
			. += "It's an empty frame."
		if(2)
			. += "It's wired."
		if(3)
			. += "The casing is closed."
	if(cell_connectors)
		if(cell)
			. += "You see [cell] inside the casing."
		else
			. += "The casing has no power cell for backup power."
	else
		. += span_danger("This casing doesn't support power cells for backup power.")

/obj/structure/light_construct/attack_hand(mob/user, list/modifiers)
	if(cell)
		user.visible_message("[user] removes [cell] from [src]!",span_notice("You remove [cell]."))
		user.put_in_hands(cell)
		cell.update_icon()
		remove_cell()
		add_fingerprint(user)

/obj/structure/light_construct/attack_tk(mob/user)
	if(!cell)
		return
	to_chat(user, span_notice("You telekinetically remove [cell]."))
	var/obj/item/stock_parts/cell/cell_reference = cell
	cell = null
	cell_reference.forceMove(drop_location())
	remove_cell()
	return cell_reference.attack_tk(user)

/obj/structure/light_construct/attackby(obj/item/W, mob/user, params)
	add_fingerprint(user)
	if(istype(W, /obj/item/stock_parts/cell))
		if(!cell_connectors)
			to_chat(user, span_warning("This [name] can't support a power cell!"))
			return
		if(HAS_TRAIT(W, TRAIT_NODROP))
			to_chat(user, span_warning("[W] is stuck to your hand!"))
			return
		if(cell)
			to_chat(user, span_warning("There is a power cell already installed!"))
		else if(user.temporarilyRemoveItemFromInventory(W))
			user.visible_message(span_notice("[user] hooks up [W] to [src]."), \
			span_notice("You add [W] to [src]."))
			playsound(src, 'sound/machines/click.ogg', 50, TRUE)
			W.forceMove(src)
			store_cell(W)
			add_fingerprint(user)
		return
	switch(stage)
		if(1)
			if(W.tool_behaviour == TOOL_WRENCH)
				if(cell)
					to_chat(user, span_warning("You have to remove the cell first!"))
					return
				else
					to_chat(user, span_notice("You begin deconstructing [src]..."))
					if (W.use_tool(src, user, 30, volume=50))
						new /obj/item/stack/sheet/iron(drop_location(), sheets_refunded)
						user.visible_message("[user.name] deconstructs [src].", \
							span_notice("You deconstruct [src]."), span_italics("You hear a ratchet."))
						playsound(src, 'sound/items/deconstruct.ogg', 75, 1)
						qdel(src)
					return

			if(istype(W, /obj/item/stack/cable_coil))
				var/obj/item/stack/cable_coil/coil = W
				if(coil.use(1))
					icon_state = "[fixture_type]-construct-stage2"
					stage = 2
					user.visible_message("[user.name] adds wires to [src].", \
						span_notice("You add wires to [src]."))
				else
					to_chat(user, span_warning("You need one length of cable to wire [src]!"))
				return
		if(2)
			if(W.tool_behaviour == TOOL_WRENCH)
				to_chat(usr, span_warning("You have to remove the wires first!"))
				return

			if(W.tool_behaviour == TOOL_WIRECUTTER)
				stage = 1
				icon_state = "[fixture_type]-construct-stage1"
				new /obj/item/stack/cable_coil(drop_location(), 1, "red")
				user.visible_message("[user.name] removes the wiring from [src].", \
					span_notice("You remove the wiring from [src]."), span_italics("You hear clicking."))
				W.play_tool_sound(src, 100)
				return

			if(W.tool_behaviour == TOOL_SCREWDRIVER)
				user.visible_message("[user.name] closes [src]'s casing.", \
					span_notice("You close [src]'s casing."), span_italics("You hear screwing."))
				W.play_tool_sound(src, 75)
				switch(fixture_type)
					if("tube")
						newlight = new /obj/machinery/light/built(loc)
					if("bulb")
						newlight = new /obj/machinery/light/small/built(loc)
				newlight.setDir(dir)
				transfer_fingerprints_to(newlight)
				if(cell)
					newlight.store_cell(cell)
					cell.forceMove(newlight)
					remove_cell()
				qdel(src)
				return
	return ..()

/obj/structure/light_construct/blob_act(obj/structure/blob/B)
	if(B && B.loc == loc)
		qdel(src)


/obj/structure/light_construct/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		new /obj/item/stack/sheet/iron(loc, sheets_refunded)
	qdel(src)

/obj/structure/light_construct/proc/store_cell(new_cell)
	if(cell)
		UnregisterSignal(cell, COMSIG_QDELETING)
	cell = new_cell
	if(cell)
		RegisterSignal(cell, COMSIG_QDELETING, PROC_REF(remove_cell))

/obj/structure/light_construct/proc/remove_cell()
	SIGNAL_HANDLER
	if(cell)
		UnregisterSignal(cell, COMSIG_QDELETING)
		cell = null

/obj/structure/light_construct/small
	name = "small light fixture frame"
	icon_state = "bulb-construct-stage1"
	fixture_type = "bulb"
	sheets_refunded = 1

