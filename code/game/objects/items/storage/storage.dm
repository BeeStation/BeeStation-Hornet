/obj/item/storage
	name = "storage"
	icon = 'icons/obj/storage/storage.dmi'
	w_class = WEIGHT_CLASS_NORMAL
	var/rummage_if_nodrop = TRUE
	var/empty = FALSE
	/// Should we preload the contents of this type?
	/// BE CAREFUL, THERE'S SOME REALLY NASTY SHIT IN THIS TYPEPATH
	/// SANTA IS EVIL
	var/preload = FALSE
	/// What storage type to use for this item
	var/datum/storage/storage_type = /datum/storage

/obj/item/storage/get_dumping_location(obj/item/storage/source,mob/user)
	return src

/obj/item/storage/Initialize(mapload)
	. = ..()

	create_storage(storage_type = storage_type)

	if(empty)
		return

	PopulateContents()

	for (var/obj/item/item in src)
		item.item_flags |= IN_STORAGE

/obj/item/storage/AllowDrop()
	return FALSE

/obj/item/storage/contents_explosion(severity, target)
	for(var/thing in contents)
		switch(severity)
			if(EXPLODE_DEVASTATE)
				SSexplosions.high_mov_atom += thing
			if(EXPLODE_HEAVY)
				SSexplosions.med_mov_atom += thing
			if(EXPLODE_LIGHT)
				SSexplosions.low_mov_atom += thing

/obj/item/storage/canStrip(mob/who)
	. = ..()
	if(!. && rummage_if_nodrop)
		return TRUE

/obj/item/storage/doStrip(mob/who)
	if(HAS_TRAIT(src, TRAIT_NODROP) && rummage_if_nodrop)
		atom_storage.remove_all()
		return TRUE
	return ..()

/obj/item/storage/contents_explosion(severity, target)
//Cyberboss says: "USE THIS TO FILL IT, NOT INITIALIZE OR NEW"

/obj/item/storage/proc/PopulateContents()

/obj/item/storage/proc/emptyStorage()
	atom_storage.remove_all()

/obj/item/storage/on_object_saved(var/depth = 0)
	if(depth >= 10)
		return ""
	var/dat = ""
	for(var/obj/item in contents)
		var/metadata = generate_tgm_metadata(item)
		dat += "[dat ? ",\n" : ""][item.type][metadata]"
		//Save the contents of things inside the things inside us, EG saving the contents of bags inside lockers
		var/custom_data = item.on_object_saved(depth++)
		dat += "[custom_data ? ",\n[custom_data]" : ""]"
	return dat

/obj/item/storage/compile_monkey_icon()
	var/identity = "[type]_[icon_state]" //Allows using multiple icon states for piece of clothing
	//If the icon, for this type of item, is already made by something else, don't make it again
	if(GLOB.monkey_icon_cache[identity])
		monkey_icon = GLOB.monkey_icon_cache[identity]
		return

	//Start with two sides
	var/icon/main = icon('icons/mob/clothing/back.dmi', icon_state) //This takes the icon and uses the worn version of the icon
	var/icon/sub = icon('icons/mob/clothing/back.dmi', icon_state)

	//merge the sub side with the main, after masking off the middle pixel line
	var/icon/mask = new('icons/mob/monkey.dmi', "monkey_mask_right") //masking
	main.AddAlphaMask(mask)
	mask = new('icons/mob/monkey.dmi', "monkey_mask_left")
	sub.AddAlphaMask(mask)
	sub.Shift(EAST, 1)
	main.Blend(sub, ICON_OVERLAY)

	//Shift it facing west, due to a spriting quirk
	sub = icon(main, dir = WEST)
	sub.Shift(WEST, 1)
	main.Insert(sub, dir = WEST)

	//Shift it down one, backpack specific quirk
	main.Shift(SOUTH, 1)

	//Mix in GAG color
	if(greyscale_colors)
		main.Blend(greyscale_colors, ICON_MULTIPLY)

	//Finished
	monkey_icon = main
	GLOB.monkey_icon_cache[identity] = icon(monkey_icon)

/// Returns a list of object types to be preloaded by our code
/// I'll say it again, be very careful with this. We only need it for a few things
/// Don't do anything stupid, please
/obj/item/storage/proc/get_types_to_preload()
	return

/obj/item/storage/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	var/obj/item/modular_computer/comp
	for(var/obj/item/modular_computer/M in contents)
		comp = M
		break
	if(!comp)
		return
	var/obj/item/computer_hardware/processor_unit/cpu = comp.all_components[MC_CPU]
	if(!cpu)
		return
	if(!cpu.hacked)
		return
	if(!comp.enabled)
		return
	var/turf/target = comp.get_blink_destination(get_turf(src), dir, (cpu.max_idle_programs * 2))
	var/turf/start = get_turf(src)
	if(!target)
		return
	if(comp.use_power((250 * cpu.max_idle_programs) / GLOB.CELLRATE)) // The better the CPU the farther it goes, and the more battery it needs
		playsound(target, 'sound/effects/phasein.ogg', 25, 1)
		playsound(start, "sparks", 50, 1)
		playsound(target, "sparks", 50, 1)
		do_dash(src, start, target, 0, TRUE)
	else
		new /obj/effect/particle_effect/sparks(start)
		playsound(start, "sparks", 50, 1)
