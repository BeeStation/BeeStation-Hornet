/obj/structure/light_construct
	name = "light fixture frame"
	desc = "A light fixture under construction."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "tube-construct-stage1"
	anchored = TRUE
	layer = WALL_OBJ_LAYER
	max_integrity = 200
	armor = list(MELEE = 50, BULLET = 10, LASER = 10, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 80, ACID = 50)

	///Light construction stage (LIGHT_CONSTRUCT_EMPTY, LIGHT_CONSTRUCT_WIRED, LIGHT_CONSTRUCT_CLOSED)
	var/stage = LIGHT_CONSTRUCT_EMPTY
	///Type of fixture for icon state
	var/fixture_type = "tube"
	///Amount of sheets gained on deconstruction
	var/sheets_refunded = 2
	///Reference for light object
	var/obj/machinery/light/new_light = null
	///Reference for the internal cell
	var/obj/item/stock_parts/cell/cell
	///Can we support a cell?
	var/cell_connectors = TRUE

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
		if(LIGHT_CONSTRUCT_EMPTY)
			. += "It's an empty frame."
		if(LIGHT_CONSTRUCT_WIRED)
			. += "It's wired."
		if(LIGHT_CONSTRUCT_CLOSED)
			. += "The casing is closed."
	if(cell_connectors)
		if(cell)
			. += "You see [cell] inside the casing."
		else
			. += "The casing has no power cell for backup power."
	else
		. += "<span class='danger'>This casing doesn't support power cells for backup power.</span>"

/obj/structure/light_construct/attack_hand(mob/user, list/modifiers)
	if(!cell)
		return
	user.visible_message("<span class='notice'>[user] removes [cell] from [src]!</span>", "<span class='notice'>You remove [cell].</span>")
	user.put_in_hands(cell)
	cell.update_appearance()
	remove_cell()
	add_fingerprint(user)

/obj/structure/light_construct/attack_tk(mob/user)
	if(!cell)
		return
	to_chat(user, "<span class='notice'>You telekinetically remove [cell].</span>")
	var/obj/item/stock_parts/cell/cell_reference = cell
	remove_cell()
	cell_reference.forceMove(drop_location())
	return cell_reference.attack_tk(user)

/obj/structure/light_construct/attackby(obj/item/tool, mob/user, params)
	add_fingerprint(user)
	if(istype(tool, /obj/item/stock_parts/cell))
		if(!cell_connectors)
			to_chat(user, "span class='warning'>This [name] can't support a power cell!</span>")
			return
		if(HAS_TRAIT(tool, TRAIT_NODROP))
			to_chat(user, "span class='warning'>[tool] is stuck to your hand!</span>")
			return
		if(cell)
			to_chat(user, "span class='warning'>There is a power cell already installed!</span>")
			return
		if(user.temporarilyRemoveItemFromInventory(tool))
			user.visible_message("<span class='notice'>[user] hooks up [tool] to [src].</span>", \
			"<span class='notice'>You add [tool] to [src].</span>")
			playsound(src, 'sound/machines/click.ogg', 50, TRUE)
			tool.forceMove(src)
			store_cell(tool)
			add_fingerprint(user)
			return
	if(istype(tool, /obj/item/light))
		to_chat(user, "span class='warning'>This [name] isn't finished being setup!</span>")
		return

	switch(stage)
		if(LIGHT_CONSTRUCT_EMPTY)
			if(tool.tool_behaviour == TOOL_WRENCH)
				if(cell)
					to_chat(user, "span class='warning'>You have to remove the cell first!</span>")
					return
				to_chat(user, "<span class='notice'>You begin deconstructing [src]...</span>")
				if (tool.use_tool(src, user, 30, volume=50))
					new /obj/item/stack/sheet/iron(drop_location(), sheets_refunded)
					user.visible_message("<span class='notice'>[user.name] deconstructs [src].</span>", \
						"<span class='notice'>You deconstruct [src].</span>", "<span class='hear'>You hear a ratchet.</span>")
					playsound(src, 'sound/items/deconstruct.ogg', 75, TRUE)
					qdel(src)
				return

			if(istype(tool, /obj/item/stack/cable_coil))
				var/obj/item/stack/cable_coil/coil = tool
				if(coil.use(1))
					icon_state = "[fixture_type]-construct-stage2"
					stage = LIGHT_CONSTRUCT_WIRED
					user.visible_message("<span class='notice'>[user.name] adds wires to [src].</span>", \
						"<span class='notice'>You add wires to [src].</span>")
				else
					to_chat(user, "span class='warning'>You need one length of cable to wire [src]!</span>")
				return
		if(LIGHT_CONSTRUCT_WIRED)
			if(tool.tool_behaviour == TOOL_WRENCH)
				to_chat(usr, "<span class='warning'>You have to remove the wires first!</span>")
				return

			if(tool.tool_behaviour == TOOL_WIRECUTTER)
				stage = LIGHT_CONSTRUCT_EMPTY
				icon_state = "[fixture_type]-construct-stage1"
				new /obj/item/stack/cable_coil(drop_location(), 1, "red")
				user.visible_message("<span class='notice'>[user.name] removes the wiring from [src].</span>",
					"<span class='notice'>You remove the wiring from [src].</span>", "<span class='hear'>You hear clicking.</span>")
				tool.play_tool_sound(src, 100)
				return

			if(tool.tool_behaviour == TOOL_SCREWDRIVER)
				user.visible_message("<span class='notice'>[user.name] closes [src]'s casing.",
					"<span class='notice'>You close [src]'s casing.", "<span class='hear'>You hear screwing.")
				tool.play_tool_sound(src, 75)
				switch(fixture_type)
					if("tube")
						new_light = new /obj/machinery/light/built(loc)
					if("bulb")
						new_light = new /obj/machinery/light/small/built(loc)
				new_light.setDir(dir)
				transfer_fingerprints_to(new_light)
				if(!QDELETED(cell))
					new_light.store_cell(cell)
					cell.forceMove(new_light)
					remove_cell()
				qdel(src)
				return
	return ..()

/obj/structure/light_construct/blob_act(obj/structure/blob/attacking_blob)
	if(attacking_blob && attacking_blob.loc == loc)
		qdel(src)

/obj/structure/light_construct/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		new /obj/item/stack/sheet/iron(loc, sheets_refunded)
	qdel(src)

/obj/structure/light_construct/proc/store_cell(new_cell)
	if(cell)
		UnregisterSignal(cell, COMSIG_PARENT_QDELETING)
	cell = new_cell
	if(cell)
		RegisterSignal(cell, COMSIG_PARENT_QDELETING, .proc/remove_cell)

/obj/structure/light_construct/proc/remove_cell()
	SIGNAL_HANDLER
	if(cell)
		UnregisterSignal(cell, COMSIG_PARENT_QDELETING)
		cell = null

/obj/structure/light_construct/small
	name = "small light fixture frame"
	icon_state = "bulb-construct-stage1"
	fixture_type = "bulb"
	sheets_refunded = 1
