
/**********************Ore box**************************/

/obj/structure/ore_box
	icon = 'icons/obj/mining.dmi'
	icon_state = "orebox"
	name = "ore box"
	desc = "A heavy wooden box, which can be filled with a lot of ores."
	density = TRUE
	pressure_resistance = 5*ONE_ATMOSPHERE
	var/static/list/typecache_to_take

/obj/structure/ore_box/Initialize(mapload)
	. = ..()
	if(!typecache_to_take)
		typecache_to_take = typecacheof(/obj/item/stack/ore)

/obj/structure/ore_box/attackby(obj/item/W, mob/user, params)
	if (istype(W, /obj/item/stack/ore))
		user.transferItemToLoc(W, src)
		ui_update()
	else if(W.atom_storage)
		W.atom_storage.remove_type(/obj/item/stack/ore, src, INFINITY, TRUE, FALSE, user, null)
		to_chat(user, span_notice("You empty the ore in [W] into \the [src]."))
		ui_update()
	else
		return ..()

/obj/structure/ore_box/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/rad_insulation, 0.01) //please datum mats no more cancer

/obj/structure/ore_box/crowbar_act(mob/living/user, obj/item/I)
	if(I.use_tool(src, user, 50, volume=50))
		user.visible_message("[user] pries \the [src] apart.",
			span_notice("You pry apart \the [src]."),
			span_italics("You hear splitting wood."))
		deconstruct(TRUE, user)
	return TRUE

/obj/structure/ore_box/examine(mob/living/user)
	if(Adjacent(user) && istype(user))
		ui_interact(user)
	. = ..()

/obj/structure/ore_box/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(Adjacent(user))
		ui_interact(user)

/obj/structure/ore_box/attack_robot(mob/user)
	if(Adjacent(user))
		ui_interact(user)

/obj/structure/ore_box/proc/dump_box_contents()
	var/drop = drop_location()
	for(var/obj/item/stack/ore/O in src)
		if(QDELETED(O))
			continue
		if(QDELETED(src))
			break
		O.forceMove(drop)
		if(TICK_CHECK)
			stoplag()
			drop = drop_location()


/obj/structure/ore_box/ui_state(mob/user)
	return GLOB.default_state

/obj/structure/ore_box/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "OreBox")
		ui.open()

/obj/structure/ore_box/ui_data()
	var/contents = list()
	for(var/obj/item/stack/ore/O in src)
		contents[O.type] += O.amount

	var/data = list()
	data["materials"] = list()
	for(var/type in contents)
		var/obj/item/stack/ore/O = type
		var/name = initial(O.name)
		data["materials"] += list(list("name" = name, "amount" = contents[type], "id" = type))

	return data

/obj/structure/ore_box/ui_act(action, params)
	if(..())
		return

	switch(action)
		if("removeall")
			dump_box_contents()
			to_chat(usr, span_notice("You open the release hatch on the box.."))
			. = TRUE

/obj/structure/ore_box/deconstruct(disassembled = TRUE, mob/user)
	var/obj/item/stack/sheet/wood/WD = new (loc, 4)
	if(user)
		WD.add_fingerprint(user)
	dump_box_contents()
	qdel(src)

/obj/structure/ore_box/onTransitZ()
	return
