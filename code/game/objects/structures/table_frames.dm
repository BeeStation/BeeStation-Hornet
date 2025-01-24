/* Table Frames
 * Contains:
 *		Frames
 *		Wooden Frames
 */


/*
 * Normal Frames
 */

/obj/structure/table_frame
	name = "table frame"
	desc = "Four metal legs with four framing rods for a table. You could easily pass through this."
	icon = 'icons/obj/structures.dmi'
	icon_state = "table_frame"
	density = FALSE
	anchored = FALSE
	layer = PROJECTILE_HIT_THRESHOLD_LAYER
	max_integrity = 100
	var/framestack = /obj/item/stack/rods
	var/framestackamount = 2

/obj/structure/table_frame/wrench_act(mob/living/user, obj/item/I)
	to_chat(user, "<span class='notice'>You start disassembling [src]...</span>")
	I.play_tool_sound(src)
	if(!I.use_tool(src, user, 3 SECONDS))
		return
	playsound(src.loc, 'sound/items/deconstruct.ogg', 50, TRUE)
	deconstruct(TRUE)
	return

/obj/structure/table_frame/attackby(obj/item/I, mob/user, params)
	if(isstack(I))
		var/obj/item/stack/material = I
		if(material.tableVariant)
			if(material.get_amount() < 1)
				to_chat(user, "<span class='warning'>You need one [material.name] sheet to do this!</span>")
				return
			if(locate(/obj/structure/table) in loc)
				to_chat(user, "<span class='warning'>There's already a table built here!</span>")
				return
			to_chat(user, "<span class='notice'>You start adding [material] to [src]...</span>")
			if(!do_after(user, 2 SECONDS, target = src) || !material.use(1) || (locate(/obj/structure/table) in loc))
				return
			make_new_table(material.tableVariant)
		else if(istype(material, /obj/item/stack/sheet))
			if(material.get_amount() < 1)
				to_chat(user, "<span class='warning'>You need one sheet to do this!</span>")
				return
			if(locate(/obj/structure/table) in loc)
				to_chat(user, "<span class='warning'>There's already a table built here!</span>")
				return
			to_chat(user, "<span class='notice'>You start adding [material] to [src]...</span>")
			if(!do_after(user, 2 SECONDS, target = src) || !material.use(1) || (locate(/obj/structure/table) in loc))
				return
			var/list/material_list = list()
			if(material.material_type)
				material_list[material.material_type] = MINERAL_MATERIAL_AMOUNT
			make_new_table(/obj/structure/table/greyscale, material_list)
		return
	return ..()

/obj/structure/table_frame/proc/make_new_table(table_type, custom_materials, carpet_type, user = null) //makes sure the new table made retains what we had as a frame
	var/obj/structure/table/T = new table_type(loc)
	T.frame = type
	T.framestack = framestack
	T.framestackamount = framestackamount
	if (carpet_type)
		T.buildstack = carpet_type
	if(custom_materials)
		T.set_custom_materials(custom_materials)
	qdel(src)

/obj/structure/table_frame/deconstruct(disassembled = TRUE)
	new framestack(get_turf(src), framestackamount)
	qdel(src)

/obj/structure/table_frame/narsie_act()
	new /obj/structure/table_frame/wood(src.loc)
	qdel(src)

/*
 * Wooden Frames
 */

/obj/structure/table_frame/wood
	name = "wooden table frame"
	desc = "Four wooden legs with four framing wooden rods for a wooden table. You could easily pass through this."
	icon_state = "wood_frame"
	framestack = /obj/item/stack/sheet/wood
	framestackamount = 2
	resistance_flags = FLAMMABLE

/obj/structure/table_frame/wood/attackby(obj/item/I, mob/user, params)
	if (istype(I, /obj/item/stack))
		var/obj/item/stack/material = I
		var/toConstruct // stores the table variant
		var/carpet_type // stores the carpet type used for construction in case of poker tables
		if(istype(I, /obj/item/stack/sheet/wood))
			toConstruct = /obj/structure/table/wood
		else if(istype(I, /obj/item/stack/tile/carpet))
			toConstruct = /obj/structure/table/wood/poker
			carpet_type = I.type
		if (toConstruct)
			if(material.get_amount() < 1)
				to_chat(user, "<span class='warning'>You need one [material.name] sheet to do this!</span>")
				return
			if(locate(/obj/structure/table) in loc)
				to_chat(user, "<span class='warning'>There's already a table built here!</span>")
				return
			to_chat(user, "<span class='notice'>You start adding [material] to [src]...</span>")
			if(do_after(user, 20, target = src) && material.use(1))
				make_new_table(toConstruct, null, carpet_type)
	else
		return ..()

/obj/structure/table_frame/brass
	name = "brass table frame"
	desc = "Four pieces of brass arranged in a square. It's slightly warm to the touch."
	icon_state = "brass_frame"
	resistance_flags = FIRE_PROOF | ACID_PROOF
	framestack = /obj/item/stack/sheet/brass
	framestackamount = 1

/obj/structure/table_frame/brass/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/stack/sheet/brass))
		var/obj/item/stack/sheet/brass/W = I
		if(W.get_amount() < 1)
			to_chat(user, "<span class='warning'>You need one brass sheet to do this!</span>")
			return
		if(locate(/obj/structure/table) in loc)
			to_chat(user, "<span class='warning'>There's already a table built here!</span>")
			return
		to_chat(user, "<span class='notice'>You start adding [W] to [src]...</span>")
		if(do_after(user, 20, target = src) && W.use(1))
			make_new_table(/obj/structure/table/brass)
	else
		return ..()

/obj/structure/table_frame/brass/narsie_act()
	..()
	if(src) //do we still exist?
		var/previouscolor = color
		color = "#960000"
		animate(src, color = previouscolor, time = 8)
		addtimer(CALLBACK(src, /atom/proc/update_atom_colour), 8)
